import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PostItem, CommentItem } from '../../models/PostItem';
@Entry
@Component
struct PostDetailView {
  @StorageLink('globalPostList') globalPosts: PostItem[] = [];

  // 1. 修正 router.getParams 类型断言
  private params: Record<string, Object> = (router.getParams() as Record<string, Object>) || {};

  // 1. 初始状态给定完整默认值，防止渲染空数据报错
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

  // 2. 在生命周期中安全获取路由参数
  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.postData) {
      this.postData = params.postData as PostItem;
      // 兼容性检查：确保评论数组存在
      if (!this.postData.comments) {
        this.postData.comments = [];
      }
    }
  }

  // 发送评论逻辑
  sendComment() {
    if (!this.commentInput.trim()) {
      promptAction.showToast({ message: '评论内容不能为空' });
      return;
    }

    const newComment: CommentItem = {
      userName: '我',
      content: this.commentInput
    };

    // 确保 comments 数组存在
    if (this.postData.comments === undefined || this.postData.comments === null) {
      this.postData.comments = [];
    }
    this.postData.comments.push(newComment);

    // 更新本地显示
    this.postData.comments.push(newComment);

    // 同步更新全局 globalPostList
    const index = this.globalPosts.findIndex(p => p.id === this.postData.id);
    if (index !== -1) {
      if (this.globalPosts[index].comments === undefined || this.globalPosts[index].comments === null) {
        this.globalPosts[index].comments = [];
      }
      // 修复这里的 target 报错：直接向全局列表对应项推入评论
      this.globalPosts[index].comments!.push(newComment);

      // 必须重新赋值触发持久化和UI监听
      AppStorage.SetOrCreate('globalPostList', [...this.globalPosts]);
    }

    this.commentInput = '';
    promptAction.showToast({ message: '评论成功' });
  }

  build() {
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
                .fontSize(16)
                .fontWeight(FontWeight.Medium)

              Text('发布于 ' + (this.postData.location || '未知位置'))
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 10 })
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

          // 帖子图片
          if (this.postData.images && this.postData.images.length > 0) {
            Image(this.postData.images[0])
              .width('100%')
              .objectFit(ImageFit.Contain)
              .padding({ left: 15, right: 15, bottom: 15 })
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
              // 修复报错：增加空值保护
              ForEach(this.postData.comments ?? [], (comment: CommentItem) => {
                Row() {
                  Image($r('app.media.ic_mine_active'))
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
                .padding({ left: 15, right: 15, bottom: 20 })
                .alignItems(VerticalAlign.Top)
              })
            }
          }
          .width('100%')
        }
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)

      // 底部互动与输入
      Column() {
        // 评论输入
        Row() {
          TextInput({ placeholder: '写下你的评论...', text: this.commentInput })
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

        // 按钮栏
        Row() {
          Column() {
            this.BottomAction(
              this.postData.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'),
              this.postData.isLiked ? '已赞' : '点赞',
              this.postData.isLiked ? '#FF4D4F' : '#666666'
            )
          }
          .layoutWeight(1)
          .onClick(() => {
            this.postData.isLiked = !this.postData.isLiked
            this.postData.likeCount += this.postData.isLiked ? 1 : -1
            const index = this.globalPosts.findIndex(p => p.id === this.postData.id);
            if(index !== -1) {
              this.globalPosts[index].isLiked = this.postData.isLiked;
              this.globalPosts[index].likeCount = this.postData.likeCount;
              AppStorage.SetOrCreate('globalPostList', [...this.globalPosts]);
            }
          })

          Column() {
            this.BottomAction(
              this.postData.isCollected ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'),
              this.postData.isCollected ? '已收藏' : '收藏',
              this.postData.isCollected ? '#FFAD14' : '#666666'
            )
          }
          .layoutWeight(1)
          .onClick(() => {
            this.postData.isCollected = !this.postData.isCollected
            const index = this.globalPosts.findIndex(p => p.id === this.postData.id);
            if(index !== -1) {
              this.globalPosts[index].isCollected = this.postData.isCollected;
              AppStorage.SetOrCreate('globalPostList', [...this.globalPosts]);
            }
          })

          Column() {
            this.BottomAction($r('sys.symbol.message'), '评论', '#666666')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .height(50)
      }
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 1 }, color: '#F1F3F5' })
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

      Text(label)
        .fontSize(10)
        .fontColor(color)
        .margin({ top: 2 })
    }
  }
}