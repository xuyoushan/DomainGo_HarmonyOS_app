export interface UserInfo {
  id: string;        // 唯一ID (主键)
  username: string;
  email: string;
  password?: string;
  avatar: string;
}

// 保持你原有的接口不变
export interface CommentItem {
  userName: string;
  avatar: Resource;
  content: string;
  timestamp: number;
}

export interface PostItem {
  id: string;
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
}