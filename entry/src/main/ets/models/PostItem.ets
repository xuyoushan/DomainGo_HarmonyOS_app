// models/PostItem.ts
export interface CommentItem {
  userName: string;
  avatar: Resource;
  content: string;
  timestamp: number; // 确保有这个
}

export interface PostItem {
  id: string;
  userName: string;
  avatar: Resource;
  text: string;
  location: string;
  timestamp: number;
  images: (Resource | string)[]; // 核心：允许 Resource 和 string 混用
  isLiked: boolean;
  likeCount: number;
  isCollected: boolean;
  comments: CommentItem[];
  tags?: string[]; // 别忘了发布页需要的这个标签字段
}