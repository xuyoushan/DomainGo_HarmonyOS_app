export interface UserInfo {
  id: string;
  username: string;
  email: string;
  password?: string;
  avatar: string;
}

export interface CommentItem {
  userName: string;
  avatar: ResourceStr;
  content: string;
  timestamp: number;
}

export interface PostItem {
  id: string;
  userId: string;
  userName: string;
  avatar: Resource;
  text: string;
  location: string;
  timestamp: number;
  images: (Resource | string)[];
  isLiked: boolean;
  likeCount: number;
  isCollected: boolean;
  comments: CommentItem[];
  tags?: string[];
  likeUserIds?: string[];
  collectUserIds?: string[];
}
export interface MessageItem {
  id: string;
  type: 'like' | 'collect' | 'follow' | 'comment';
  fromUserName: string;
  fromAvatar: ResourceStr;
  targetContent?: string;
  timestamp: number;
}
