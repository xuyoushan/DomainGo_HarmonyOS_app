import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PostItem, CommentItem } from '../../models/PostItem';

@Entry
@Component
struct PostDetailView {
  @StorageLink('globalPostList') globalPosts: PostItem[] = [];

  private params: Record<string, Object> = (router.getParams() as Record<string, Object>) || {};

  @State postData: PostItem = (this.params.postData as PostItem) ?? {
    id: '0',
    userName: '加载中...',
    avatar: $r('app.media.ic_mine_active'),
    text: '',
    location: '',
    timestamp: Date.now(),
    images: [],
    isLiked: false,
    likeCount: 0,
    isCollected: false,
    comments: []
  };

  @State commentInput: string = '';

  @State showBigImage: boolean = false;
  @State currentPreviewImg: string | Resource = '';

  @State replyPlaceholder: string = '写下你的评论...';
  @State replyingToUser: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.postData) {
      this.postData = params.postData as PostItem;
      if (!this.postData.comments) {
        this.postData.comments = [];
      }
    }
  }

  syncChanges() {
    const index = this.globalPosts.findIndex(p => p.id === this.postData.id);
    if (index !== -1) {
      this.globalPosts[index].isLiked = this.postData.isLiked;
      this.globalPosts[index].likeCount = this.postData.likeCount;
      this.globalPosts[index].isCollected = this.postData.isCollected;
      this.globalPosts[index].comments = [...this.postData.comments];

      this.postData.isLiked = this.postData.isLiked;
      this.postData.isCollected = this.postData.isCollected;
      this.postData.comments = [...this.postData.comments];


      AppStorage.SetOrCreate('globalPostList', [...this.globalPosts]);
    }
  }

  sendComment() {
    if (!this.commentInput.trim()) {
      promptAction.showToast({ message: '评论内容不能为空' });
      return;
    }

    let finalContent = this.commentInput;
    if (this.replyingToUser) {
      finalContent = `回复 @${this.replyingToUser} : ${this.commentInput}`;
    }

    const newComment: CommentItem = {
      userName: '旅行者',
      avatar: $r('app.media.ic_mine_active'),
      content: finalContent,
      timestamp: Date.now()
    };

    if (!this.postData.comments) {
      this.postData.comments = [];
    }

    if (this.replyingToUser) {
      const targetIndex = this.postData.comments.findIndex(c => c.userName === this.replyingToUser);
      if (targetIndex !== -1) {
        this.postData.comments.splice(targetIndex + 1, 0, newComment);
      } else {
        this.postData.comments.unshift(newComment);
      }
    } else {
      this.postData.comments.unshift(newComment);
    }

    this.syncChanges(); // 同步全局并强行刷新 UI

    // 清空状态
    this.commentInput = '';
    this.replyingToUser = '';
    this.replyPlaceholder = '写下你的评论...';
    promptAction.showToast({ message: '评论成功' });
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .onClick(() => router.back())

          Text('帖子正文')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 15 })

          Blank()

          SymbolGlyph($r('sys.symbol.share'))
            .fontSize(24)
            .onClick(() => {
              promptAction.showToast({ message: '链接已复制' })
            })
        }
        .width('100%')
        .padding(15)
        .backgroundColor('#FFFFFF')

        Scroll() {
          Column() {
            // 作者信息
            Row() {
              Image(this.postData.avatar)
                .width(45)
                .height(45)
                .borderRadius(22.5)
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/mine/UserHomeView',
                    params: { postData: this.postData }
                  })
                })
              Column() {
                Text(this.postData.userName)
                  .fontSize(16).fontWeight(FontWeight.Medium)
                Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                  Text('发布于 ')
                    .fontSize(12).fontColor('#999999')

                  Text(this.postData.location || '未知位置')
                    .fontSize(12).fontColor('#999999')
                }
                .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 10 }).layoutWeight(1)
            }
            .width('100%')
            .padding(15)

            // 帖子正文
            Text(this.postData.text)
              .fontSize(16)
              .lineHeight(26)
              .padding(15)
              .width('100%')
              .textAlign(TextAlign.Start)

            // --- 帖子图片：Swiper多图 + 点击唤起大图预览 ---
            if (this.postData.images && this.postData.images.length > 0) {
              Swiper() {
                ForEach(this.postData.images, (img: string | Resource) => {
                  Stack() {
                    Image(img)
                      .width('100%')
                      .height(450)
                      .objectFit(ImageFit.Contain)
                      .onClick(() => {
                        this.currentPreviewImg = img;
                        this.showBigImage = true;
                      })
                  }
                  .width('100%')
                  .height(450)
                  .backgroundColor('#F1F3F5')
                })
              }
              .width('100%')
              .height(450)
              .indicator(this.postData.images.length > 1)
              .loop(false)
              .margin({ bottom: 15 })
            }

            Divider().strokeWidth(8).color('#F1F3F5')

            // 评论列表
            Column() {
              Row() {
                Text(`评论 (${this.postData.comments?.length ?? 0})`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333')
                Blank()
              }
              .width('100%')
              .padding(15)

              if (!this.postData.comments || this.postData.comments.length === 0) {
                Column() {
                  SymbolGlyph($r('sys.symbol.message_badge_plus')).fontSize(40).fontColor(['#EEEEEE'])
                  Text('暂无评论，快来抢沙发').fontSize(12).fontColor('#CCCCCC').margin({ top: 10 })
                }
                .width('100%')
                .padding(40)
              } else {
                ForEach(this.postData.comments, (comment: CommentItem) => {
                  Row() {
                    Image(comment.avatar || $r('app.media.ic_mine_active'))
                      .width(32)
                      .height(32)
                      .borderRadius(16)

                    Column() {
                      Text(comment.userName).fontSize(13).fontColor('#666').fontWeight(FontWeight.Medium)
                      Text(comment.content).fontSize(14).fontColor('#333').margin({ top: 4 }).lineHeight(20)
                    }
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 10 })
                    .layoutWeight(1)
                  }
                  .width('100%')
                  // 【退格罗列修复】如果是回复，则左内边距加大
                  .padding({
                    left: (comment.content.includes('回复 @')) ? 50 : 15,
                    right: 15,
                    bottom: 20
                  })
                  .alignItems(VerticalAlign.Top)
                  // 点击评论触发回复
                  .onClick(() => {
                    this.replyingToUser = comment.userName;
                    this.replyPlaceholder = `回复 @${comment.userName}...`;
                    promptAction.showToast({ message: `回复：${comment.userName}` });
                  })
                })
              }
            }
            .width('100%')
          }
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)

        // 【底部交互区修复版】
        Column() {
          // 评论输入行
          Row() {
            TextInput({ placeholder: this.replyPlaceholder, text: this.commentInput })
              .layoutWeight(1)
              .height(36)
              .fontSize(14)
              .backgroundColor('#F5F5F5')
              .onChange((v) => this.commentInput = v)

            Text('发送')
              .fontColor(this.commentInput.trim() ? '#007DFF' : '#999999')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .margin({ left: 10 })
              .onClick(() => this.sendComment())
          }
          .width('100%')
          .padding({ left: 15, right: 15, top: 10, bottom: 5 })

          // 按钮行
          Row() {
            // 点赞按钮
            Row() {
              this.BottomAction(
                this.postData.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'),
                this.postData.isLiked ? (this.postData.likeCount > 0 ? this.postData.likeCount.toString() : '已赞') : (this.postData.likeCount > 0 ? this.postData.likeCount.toString() : '点赞'),
                this.postData.isLiked ? '#FF4D4F' : '#666666'
              )
            }
            .layoutWeight(1)
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.postData.isLiked = !this.postData.isLiked
              this.postData.likeCount += this.postData.isLiked ? 1 : -1
              this.syncChanges() // 重新赋值 postData，强行刷新颜色和数字
            })

            // 收藏按钮
            Row() {
              this.BottomAction(
                this.postData.isCollected ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'),
                this.postData.isCollected ? '已收藏' : '收藏',
                this.postData.isCollected ? '#FFAD14' : '#666666'
              )
            }
            .layoutWeight(1)
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.postData.isCollected = !this.postData.isCollected
              this.syncChanges() // 重新赋值 postData，强行刷新颜色
              promptAction.showToast({ message: this.postData.isCollected ? '已收藏' : '已取消收藏' })
            })

            // 评论（显示实时数量）
            Row() {
              this.BottomAction($r('sys.symbol.message'),
                (this.postData.comments.length > 0 ? this.postData.comments.length.toString() : '评论'),
                '#666666'
              )
            }
            .layoutWeight(1)
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.replyingToUser = '';
              this.replyPlaceholder = '写下你的评论...';
            })
          }
          .width('100%')
          .height(50)
        }
        .backgroundColor('#FFFFFF')
        .border({ width: { top: 1 }, color: '#F1F3F5' })
      }
      .width('100%')
      .height('100%')

      // 大图预览
      if (this.showBigImage) {
        Stack() {
          Rect().width('100%').height('100%').fill('#FF000000')
            .onClick(() => this.showBigImage = false)

          Image(this.currentPreviewImg)
            .width('100%')
            .objectFit(ImageFit.Contain)
            .onClick(() => this.showBigImage = false)
        }
        .width('100%')
        .height('100%')
        .zIndex(100)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  BottomAction(icon: Resource, label: string, color: string) {
    Column() {
      SymbolGlyph(icon)
        .fontSize(20)
        .fontColor([color])

      // 注意：这里的 label 会随着 BottomAction 调用时传入的 postData 变化而即时更新
      Text(label)
        .fontSize(10)
        .fontColor(color)
        .margin({ top: 2 })
    }
  }
}