import { relationalStore } from '@kit.ArkData';
import { PostItem, UserInfo } from '../models/PostItem';

export class PostRepository {
  private store: relationalStore.RdbStore | null = null;

  // 生成 ID 格式：DG + 6位随机小写字母数字混合
  private generateCustomId(): string {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    let result = 'DG';
    for (let i = 0; i < 6; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  async init(context: Context) {
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
        TAGS TEXT
      )`);
  }

  async registerUser(user: UserInfo) {
    if (!this.store) return;
    const bucket: relationalStore.ValuesBucket = {
      ID: user.id || this.generateCustomId(),
      USERNAME: user.username,
      EMAIL: user.email,
      PASSWORD: user.password || '',
      AVATAR: user.avatar
    };
    return await this.store.insert('USERS', bucket);
  }

  async checkUser(username: string, password: string): Promise<UserInfo | null> {
    if (!this.store) return null;
    let predicates = new relationalStore.RdbPredicates('USERS');
    predicates.equalTo('USERNAME', username).and().equalTo('PASSWORD', password);
    let resultSet = await this.store.query(predicates);

    if (resultSet && resultSet.goToNextRow()) {
      const userInfo: UserInfo = {
        id: resultSet.getString(resultSet.getColumnIndex('ID')),
        username: resultSet.getString(resultSet.getColumnIndex('USERNAME')),
        email: resultSet.getString(resultSet.getColumnIndex('EMAIL')),
        avatar: resultSet.getString(resultSet.getColumnIndex('AVATAR'))
      };
      resultSet.close();
      return userInfo;
    }
    return null;
  }

  async insertPost(post: PostItem, userId: string) {
    if (!this.store) throw new Error('DB_NOT_INIT'); // 抛出异常方便调试
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

  async fetchAllPosts(): Promise<PostItem[]> {
    if (!this.store) return [];
    let predicates = new relationalStore.RdbPredicates('POSTS');
    predicates.orderByDesc('TIMESTAMP');
    let resultSet = await this.store.query(predicates);

    let posts: PostItem[] = [];
    while (resultSet.goToNextRow()) {
      posts.push({
        id: resultSet.getString(resultSet.getColumnIndex('ID')),
        userName: resultSet.getString(resultSet.getColumnIndex('USER_NAME')),
        avatar: $r('app.media.ic_mine_active'),
        text: resultSet.getString(resultSet.getColumnIndex('TEXT_CONTENT')),
        location: resultSet.getString(resultSet.getColumnIndex('LOCATION')),
        timestamp: resultSet.getLong(resultSet.getColumnIndex('TIMESTAMP')),
        images: JSON.parse(resultSet.getString(resultSet.getColumnIndex('IMAGES'))),
        isLiked: resultSet.getLong(resultSet.getColumnIndex('IS_LIKED')) === 1,
        likeCount: resultSet.getLong(resultSet.getColumnIndex('LIKE_COUNT')),
        isCollected: resultSet.getLong(resultSet.getColumnIndex('IS_COLLECTED')) === 1,
        comments: []
      });
    }
    resultSet.close();
    return posts;
  }

  async updatePostStatus(postId: string, isLiked: boolean, isCollected: boolean, likeCount: number): Promise<void> {
    if (!this.store) {
      return;
    }
    let valueBucket: relationalStore.ValuesBucket = {
      'IS_LIKED': isLiked ? 1 : 0,
      'IS_COLLECTED': isCollected ? 1 : 0,
      'LIKE_COUNT': likeCount
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