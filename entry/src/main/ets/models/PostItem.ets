// src/main/ets/models/PostItem.ets

// 必须有这个 export，PostDetailView 才能认出来
export interface CommentItem {
  userName: string;
  content: string;
}

export interface PostItem {
  id: string;
  userName: string;
  avatar: Resource;
  text: string;
  location: string;
  timestamp: number;
  images: Resource[];
  isLiked: boolean;
  likeCount: number;
  isCollected: boolean;
  comments: CommentItem[]; // 确保这里引用的是上面的接口
}