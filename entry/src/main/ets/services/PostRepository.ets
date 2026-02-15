import { relationalStore } from '@kit.ArkData';
import { PostItem, UserInfo } from '../models/PostItem';

export interface MessageNotification {
  id: string;
  receiverId: string;
  type: string;
  fromUserName: string;
  fromAvatar: string | Resource;
  targetContent: string;
  timestamp: number;
  isRead: boolean;
}

export class PostRepository {
  private store: relationalStore.RdbStore | null = null;

  private generateCustomId(): string {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    let result = 'DG';
    for (let i = 0; i < 6; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    // result += Date.now().toString().slice(-4); // 加时间戳
    return result;
  }

  async init(context: Context) {
    if (this.store) return;
    const CONFIG: relationalStore.StoreConfig = {
      name: 'DomainGo_2.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };

    this.store = await relationalStore.getRdbStore(context, CONFIG);

    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS USERS (
        ID TEXT PRIMARY KEY,
        USERNAME TEXT,
        EMAIL TEXT,
        PASSWORD TEXT,
        AVATAR TEXT
      )`);

    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS POSTS (
        ID TEXT PRIMARY KEY,
        USER_ID TEXT,
        USER_NAME TEXT,
        TEXT_CONTENT TEXT,
        TIMESTAMP INTEGER,
        LOCATION TEXT,
        IMAGES TEXT,
        IS_LIKED INTEGER,
        LIKE_COUNT INTEGER,
        IS_COLLECTED INTEGER,
        TAGS TEXT,
        LIKE_IDS TEXT,
        COLLECT_IDS TEXT
      )`);

    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS NOTIFICATIONS (
        ID TEXT PRIMARY KEY,
        RECEIVER_ID TEXT,
        SENDER_ID TEXT,
        TYPE TEXT,
        SENDER_NAME TEXT,
        SENDER_AVATAR TEXT,
        TARGET_CONTENT TEXT,
        TIMESTAMP INTEGER,
        IS_READ INTEGER
      )`);
  }

  async sendNotification(receiverId: string, senderId: string, senderName: string, senderAvatar: string, type: string, content: string) {
    if (!this.store || receiverId === senderId) return; // 自己给自己点赞不发通知
    let valueBucket: relationalStore.ValuesBucket = {
      'ID': 'MSG_' + Date.now(),
      'RECEIVER_ID': receiverId,
      'SENDER_ID': senderId,
      'SENDER_NAME': senderName,
      'SENDER_AVATAR': senderAvatar,
      'TYPE': type,
      'TARGET_CONTENT': content,
      'TIMESTAMP': Date.now(),
      'IS_READ': 0
    };
    await this.store.insert('NOTIFICATIONS', valueBucket);
  }

  async getMyNotifications(myId: string): Promise<MessageNotification[]> {
    if (!this.store || !myId) return [];

    let predicates = new relationalStore.RdbPredicates('NOTIFICATIONS');
    predicates.equalTo('RECEIVER_ID', myId).orderByDesc('TIMESTAMP');

    let resultSet = await this.store.query(predicates);
    let msgs: MessageNotification[] = [];

    while (resultSet.goToNextRow()) {
      msgs.push({
        id: resultSet.getString(resultSet.getColumnIndex('ID')),
        receiverId: resultSet.getString(resultSet.getColumnIndex('RECEIVER_ID')),
        type: resultSet.getString(resultSet.getColumnIndex('TYPE')),
        fromUserName: resultSet.getString(resultSet.getColumnIndex('SENDER_NAME')),
        fromAvatar: resultSet.getString(resultSet.getColumnIndex('SENDER_AVATAR')),
        targetContent: resultSet.getString(resultSet.getColumnIndex('TARGET_CONTENT')),
        timestamp: resultSet.getLong(resultSet.getColumnIndex('TIMESTAMP')),
        isRead: resultSet.getLong(resultSet.getColumnIndex('IS_READ')) === 1
      });
    }
    resultSet.close();
    return msgs;
  }

  async markNotificationAsRead(msgId: string) {
    if (!this.store) return;
    let predicates = new relationalStore.RdbPredicates('NOTIFICATIONS');
    predicates.equalTo('ID', msgId);
    await this.store.update({ 'IS_READ': 1 }, predicates);
  }

  async deleteNotification(id: string) {
    if (!this.store) return;
    let predicates = new relationalStore.RdbPredicates('NOTIFICATIONS');
    predicates.equalTo('ID', id);
    await this.store.delete(predicates);
  }

  async markAllRead(myId: string) {
    if (!this.store) return;
    let predicates = new relationalStore.RdbPredicates('NOTIFICATIONS');
    predicates.equalTo('RECEIVER_ID', myId);
    await this.store.update({ 'IS_READ': 1 }, predicates);
  }

  async markTypeAsRead(myId: string, types: string[]) {
    if (!this.store) return;
    let predicates = new relationalStore.RdbPredicates('NOTIFICATIONS');
    predicates.equalTo('RECEIVER_ID', myId);
    if (types.length > 0) {
      predicates.and().in('TYPE', types);
    }
    await this.store.update({ 'IS_READ': 1 }, predicates);
  }

  async isEmailRegistered(email: string): Promise<boolean> {
    if (!this.store) return false;
    let predicates = new relationalStore.RdbPredicates('USERS');
    predicates.equalTo('EMAIL', email);
    let resultSet = await this.store.query(predicates);
    const exists = resultSet.rowCount > 0;
    resultSet.close();
    return exists;
  }

  async updateUserInfo(userId: string, username: string, avatar: string, password?: string): Promise<void> {
    if (!this.store) return;
    const bucket: relationalStore.ValuesBucket = { 'USERNAME': username, 'AVATAR': avatar };
    if (password && password.trim().length > 0) {bucket['PASSWORD'] = password;}

    let predicates = new relationalStore.RdbPredicates('USERS');
    predicates.equalTo('ID', userId);
    await this.store.update(bucket, predicates);

    let postPredicates = new relationalStore.RdbPredicates('POSTS');
    postPredicates.equalTo('USER_ID', userId);
    await this.store.update({ 'USER_NAME': username }, postPredicates);
  }

  async deleteUserAccount(userId: string): Promise<void> {
    if (!this.store) return;
    try {
      let userPredicates = new relationalStore.RdbPredicates('USERS');
      userPredicates.equalTo('ID', userId);
      await this.store.delete(userPredicates);

      let postPredicates = new relationalStore.RdbPredicates('POSTS');
      postPredicates.equalTo('USER_ID', userId);
      await this.store.delete(postPredicates);

      console.info(`账号 ${userId} 已注销，相关数据已清理`);
    } catch (err) {
      console.error(`注销失败: ${JSON.stringify(err)}`);
    }
  }

  async registerUser(user: UserInfo) {
    if (!this.store) return;
    const finalId: string = (user.id && user.id.length > 0) ? user.id : this.generateCustomId();
    const bucket: relationalStore.ValuesBucket = {
      // ID: user.id || this.generateCustomId(),
      'ID': finalId,
      USERNAME: user.username,
      EMAIL: user.email,
      PASSWORD: user.password || '',
      AVATAR: user.avatar
    };
    await this.store.insert('USERS', bucket);
    const result: UserInfo = {
      id: finalId,
      username: user.username,
      email: user.email,
      password: user.password,
      avatar: user.avatar
    };
    return result;
  }

  async checkUser(email: string, password: string): Promise<UserInfo | null> {
    if (!this.store) return null;
    let predicates = new relationalStore.RdbPredicates('USERS');
    predicates.equalTo('EMAIL', email).and().equalTo('PASSWORD', password);
    let resultSet = await this.store.query(predicates);
    if (resultSet && resultSet.rowCount > 0 && resultSet.goToFirstRow()) {
      const dbAvatar = resultSet.getString(resultSet.getColumnIndex('AVATAR'));
      const userInfo: UserInfo = {
        id: resultSet.getString(resultSet.getColumnIndex('ID')),
        username: resultSet.getString(resultSet.getColumnIndex('USERNAME')),
        email: resultSet.getString(resultSet.getColumnIndex('EMAIL')),
        avatar: (dbAvatar && dbAvatar !== 'undefined') ? dbAvatar : 'app.media.start'
      };
      resultSet.close();
      return userInfo;
    }
    if (resultSet) resultSet.close();
    return null;
  }

  async insertPost(post: PostItem, userId: string) {
    if (!this.store) throw new Error('DB_NOT_INIT');
    const bucket: relationalStore.ValuesBucket = {
      'ID': post.id,
      'USER_ID': userId,
      'USER_NAME': post.userName,
      'TEXT_CONTENT': post.text,
      'TIMESTAMP': post.timestamp,
      'LOCATION': post.location || '',
      'IMAGES': JSON.stringify(post.images),
      'IS_LIKED': post.isLiked ? 1 : 0,
      'LIKE_COUNT': post.likeCount,
      'IS_COLLECTED': post.isCollected ? 1 : 0,
      'TAGS': JSON.stringify(post.tags || [])
    };
    await this.store.insert('POSTS', bucket);
  }

  async deletePost(id: string): Promise<void> {
    if (!this.store) return;
    try {
      let predicates = new relationalStore.RdbPredicates('POSTS');
      predicates.equalTo('ID', id);
      const rows = await this.store.delete(predicates);
      console.info(`成功从数据库删除帖子: ${id}, 影响行数: ${rows}`);
    } catch (err) {
      console.error(`删除失败: ${JSON.stringify(err)}`);
    }
  }

  async updatePost(post: PostItem): Promise<void> {
    if (!this.store) return;
    let bucket: relationalStore.ValuesBucket = {
      'TEXT_CONTENT': post.text,
      'IMAGES': JSON.stringify(post.images),
      'IS_LIKED': post.isLiked ? 1 : 0,
      'LIKE_COUNT': post.likeCount,
      'IS_COLLECTED': post.isCollected ? 1 : 0,
      'LIKE_IDS': JSON.stringify(post.likeUserIds || []),
      'COLLECT_IDS': JSON.stringify(post.collectUserIds || [])
    };
    let predicates = new relationalStore.RdbPredicates('POSTS');
    predicates.equalTo('ID', post.id);
    await this.store.update(bucket, predicates);
  }

  async getUserById(userId: string): Promise<UserInfo | null> {
    if (!this.store || !userId) return null;
    let predicates = new relationalStore.RdbPredicates('USERS');
    predicates.equalTo('ID', userId);
    let resultSet = await this.store.query(predicates);
    if (resultSet.goToFirstRow()) {
      const userInfo: UserInfo = {
        id: resultSet.getString(resultSet.getColumnIndex('ID')),
        username: resultSet.getString(resultSet.getColumnIndex('USERNAME')),
        avatar: resultSet.getString(resultSet.getColumnIndex('AVATAR')),
        email: resultSet.getString(resultSet.getColumnIndex('EMAIL'))
      };
      resultSet.close();
      return userInfo;    }
    return null;
  }

  async fetchAllPosts(): Promise<PostItem[]> {
    if (!this.store) return [];
    const sql = `
    SELECT
      P.ID, P.USER_ID, P.USER_NAME, P.TEXT_CONTENT, P.TIMESTAMP, P.LOCATION,
      P.IMAGES, P.IS_LIKED, P.LIKE_COUNT, P.IS_COLLECTED,
      U.AVATAR AS USER_REAL_AVATAR
    FROM POSTS P
    LEFT JOIN USERS U ON P.USER_ID = U.ID
    ORDER BY P.TIMESTAMP DESC`;
    let resultSet = await this.store.querySql(sql);
    let posts: PostItem[] = [];
    while (resultSet.goToNextRow()) {
      let avatarUri = "";
      const avatarIndex = resultSet.getColumnIndex('USER_REAL_AVATAR');

      if (!resultSet.isColumnNull(avatarIndex)) {
        avatarUri = resultSet.getString(avatarIndex);
      }
      const isValidPath = avatarUri &&
        avatarUri !== "" &&
        avatarUri !== "app.media.start" &&
        avatarUri !== "undefined" &&
        avatarUri.length > 5;
      posts.push({
        id: resultSet.getString(resultSet.getColumnIndex('ID')),
        userId: resultSet.getString(resultSet.getColumnIndex('USER_ID')),
        userName: resultSet.getString(resultSet.getColumnIndex('USER_NAME')),
        avatar: isValidPath ? avatarUri : $r('app.media.start'),
        text: resultSet.getString(resultSet.getColumnIndex('TEXT_CONTENT')),
        location: resultSet.getString(resultSet.getColumnIndex('LOCATION')),
        timestamp: resultSet.getLong(resultSet.getColumnIndex('TIMESTAMP')),
        images: JSON.parse(resultSet.getString(resultSet.getColumnIndex('IMAGES'))),
        isLiked: resultSet.getLong(resultSet.getColumnIndex('IS_LIKED')) === 1,
        likeCount: resultSet.getLong(resultSet.getColumnIndex('LIKE_COUNT')),
        isCollected: resultSet.getLong(resultSet.getColumnIndex('IS_COLLECTED')) === 1,
        comments: [],
        likeUserIds: [],
        collectUserIds: []
      });
    }
    resultSet.close();
    return posts;
  }

  async updatePostStatus(postId: string, isLiked: boolean, isCollected: boolean, likeCount: number, likeIds: string[], collectIds: string[]): Promise<void> {
    if (!this.store) return;
    let valueBucket: relationalStore.ValuesBucket = {
      'IS_LIKED': isLiked ? 1 : 0,
      'IS_COLLECTED': isCollected ? 1 : 0,
      'LIKE_COUNT': likeCount,
      'LIKE_IDS': JSON.stringify(likeIds || []),
      'COLLECT_IDS': JSON.stringify(collectIds || [])
    };
    let predicates = new relationalStore.RdbPredicates('POSTS');
    predicates.equalTo('ID', postId);

    try {
      await this.store.update(valueBucket, predicates);
      console.info(`Post ${postId} status updated in DB`);
    } catch (err) {
      console.error(`Update_DB_Error: ${JSON.stringify(err)}`);
    }
  }
}

export const postRepo = new PostRepository();