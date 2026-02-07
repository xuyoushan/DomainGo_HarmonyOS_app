import { router, promptAction, componentSnapshot } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { PostItem, CommentItem } from '../../models/PostItem';
import image from '@ohos.multimedia.image';
import { postRepo } from '../../services/PostRepository';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct PostDetailView {
  @StorageLink('globalPostList') globalPosts: PostItem[] = [];
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('currentUserId') currentUserId: string = '';

  private params: Record<string, Object> = (router.getParams() as Record<string, Object>) || {};

  @State postData: PostItem = (this.params.postData as PostItem) ?? {
    id: '0',
    userId: '',
    userName: '加载中...',
    avatar: $r('app.media.start'),
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

  @State isExpanded: boolean = false;
  private readonly MAX_LINES: number = 4;

  private snapshotId: string = 'root_post_detail';

  async toggleCollect() {
    if (!this.checkAuth()) return;

    const index = this.globalPosts.findIndex(p => p.id === this.postData.id);
    if (index === -1) return;

    let p = this.globalPosts[index];
    if (!p.collectUserIds) p.collectUserIds = [];

    const uIdx = p.collectUserIds.indexOf(this.currentUserId);
    if (uIdx === -1) {
      p.collectUserIds.push(this.currentUserId);
    } else {
      p.collectUserIds.splice(uIdx, 1);
    }

    p.isCollected = p.collectUserIds.includes(this.currentUserId);
    this.globalPosts[index] = p;
    AppStorage.setOrCreate('globalPostList', [...this.globalPosts]);

    this.globalPosts[index] = p;
    AppStorage.setOrCreate('globalPostList', this.globalPosts.slice());
    await postRepo.updatePostStatus(p.id, p.isLiked, p.isCollected, p.likeCount);
  }

  async toggleLike() {
    if (!this.checkAuth()) return;

    const index = this.globalPosts.findIndex(p => p.id === this.postData.id);
    if (index === -1) return;

    let p = this.globalPosts[index];
    if (!p.likeUserIds) p.likeUserIds = [];

    const uIdx = p.likeUserIds.indexOf(this.currentUserId);
    if (uIdx === -1) {
      p.likeUserIds.push(this.currentUserId);
    } else {
      p.likeUserIds.splice(uIdx, 1);
    }

    p.likeCount = p.likeUserIds.length;
    p.isLiked = p.likeUserIds.includes(this.currentUserId);

    this.globalPosts[index] = p;
    AppStorage.setOrCreate('globalPostList', [...this.globalPosts]);

    this.globalPosts[index] = p;
    AppStorage.setOrCreate('globalPostList', this.globalPosts.slice());
    await postRepo.updatePostStatus(p.id, p.isLiked, p.isCollected, p.likeCount);
  }

  aboutToAppear() {
    this.syncFromGlobal();
  }

  syncFromGlobal() {
    const p = this.globalPosts.find(item => item.id === this.postData.id);
    if (!p) return;

    const uid = this.currentUserId;
    this.postData.id = p.id;
    this.postData.userId = p.userId;
    this.postData.userName = p.userName;
    this.postData.text = p.text;
    this.postData.images = p.images;
    this.postData.location = p.location;
    this.postData.timestamp = p.timestamp;
    this.postData.comments = p.comments || [];
    this.postData.likeUserIds = p.likeUserIds || [];
    this.postData.collectUserIds = p.collectUserIds || [];

    this.postData.isLiked = this.postData.likeUserIds.includes(uid);
    this.postData.isCollected = this.postData.collectUserIds.includes(uid);
    this.postData.likeCount = this.postData.likeUserIds.length;
  }

  getRelativeTime(time: number): string {
    const date = new Date(time);
    const h = date.getHours();
    const m = date.getMinutes();
    const mm = m < 10 ? `0${m}` : `${m}`;
    return `${date.getMonth() + 1}月${date.getDate()}日 ${h}:${mm}`;
  }

  async saveToAlbum() {
    try {
      const pixmap: image.PixelMap = await componentSnapshot.get(this.snapshotId);
      const imagePacker = image.createImagePacker();
      const buffer = await imagePacker.packing(pixmap, { format: 'image/jpeg', quality: 100 });
      const helper = photoAccessHelper.getPhotoAccessHelper(getContext(this));
      const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
      const file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(file.fd, buffer);
      await fs.close(file.fd);
      promptAction.showToast({ message: '截图已存至相册' });
    } catch (err) {
      promptAction.showToast({ message: '保存失败' });
    }
  }

  checkAuth(): boolean {
    if (!this.isLoggedIn) {
      promptAction.showToast({ message: '请先登录探索更多精彩' });
      router.pushUrl({ url: 'pages/mine/RegisterView' });
      return false;
    }
    return true;
  }

  async handleDeletePost(): Promise<void> {
    if (this.postData.userId !== this.currentUserId) {
      promptAction.showToast({ message: '无权删除他人帖子' });
      return;
    }

    promptAction.showDialog({
      title: '确认删除',
      message: '删除后将无法恢复，确定删除吗？',
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '确定删除', color: '#FF4D4F' }
      ]
    }).then(async (data) => {
      if (data.index === 1) {
        const idToDelete = this.postData.id;

        // 1. 同步数据库 (必须先执行或确保执行)
        await postRepo.deletePost(idToDelete);

        // 2. 同步全局内存 (使用 slice 产生新引用触发所有页面刷新)
        const newList = this.globalPosts.filter((p: PostItem) => p.id !== idToDelete);
        AppStorage.setOrCreate('globalPostList', newList.slice());

        promptAction.showToast({ message: '帖子已删除' });

        // 3. 延迟返回，确保状态已写回
        setTimeout(() => {
          router.back();
        }, 100);
      }
    });
  }

  sendComment() {
    if (!this.checkAuth()) return;
    if (!this.commentInput.trim()) return;

    const userName = AppStorage.get<string>('userName') || '匿名探险家';
    let content = this.commentInput;
    if (this.replyingToUser) {
      content = `回复 @${this.replyingToUser} : ${this.commentInput}`;
    }

    const comment: CommentItem = {
      userName,
      avatar: $r('app.media.start'),
      content,
      timestamp: Date.now()
    };

    const index = this.globalPosts.findIndex(p => p.id === this.postData.id);
    if (index !== -1) {
      if (!this.globalPosts[index].comments) this.globalPosts[index].comments = [];
      this.globalPosts[index].comments.unshift(comment);
      AppStorage.setOrCreate('globalPostList', [...this.globalPosts]);
      this.syncFromGlobal();
    }

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

          if (this.isLoggedIn && this.postData.userId === this.currentUserId) {
            SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
              .fontSize(24)
              .margin({ right: 20 })
              .fontColor(['#333333'])
              .onClick(() => {
                this.handleDeletePost();
              })
          }

          SymbolGlyph($r('sys.symbol.camera_fill'))
            .fontSize(24)
            .onClick(() => this.saveToAlbum())
        }
        .width('100%').padding(15).backgroundColor('#FFFFFF')

        Scroll() {
          Column() {
            // 作者信息
            Row() {
              Image($r('app.media.start'))
                .width(45).height(45).borderRadius(22.5)
                .onClick(() => {
                  if (!this.checkAuth()) return;
                  if (this.postData.userId === this.currentUserId) {
                    router.pushUrl({ url: 'pages/Index', params: { tabIndex: 4 } });
                  } else {
                    router.pushUrl({ url: 'pages/mine/UserHomeView', params: { userId: this.postData.userId } });
                  }
                })
              Column() {
                Text(this.postData.userName).fontSize(16).fontWeight(FontWeight.Medium)
                Text(this.getRelativeTime(this.postData.timestamp))
                  .fontSize(12).fontColor('#999999').margin({ top: 2 })
                Text(this.postData.location || '未知地区·火星').fontSize(12).fontColor('#999999').margin({ top: 2 })
              }.alignItems(HorizontalAlign.Start).margin({ left: 10 }).layoutWeight(1)

            }.width('100%').padding(15)

            Column() {
              Text(this.postData.text)
                .fontSize(16)
                .lineHeight(26)
                .width('100%')
                .maxLines(this.isExpanded ? 1000 : this.MAX_LINES)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              if (!this.isExpanded && this.postData.text.length > 100) {
                Text('展开全文')
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .margin({ top: 5 })
                  .onClick(() => { this.isExpanded = true })
              } else if (this.isExpanded) {
                Text('收起')
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .margin({ top: 5 })
                  .onClick(() => { this.isExpanded = false })
              }
            }.padding({ left: 15, right: 15, bottom: 15 })

            if (this.postData.images && this.postData.images.length > 0) {
              Swiper() {
                ForEach(this.postData.images, (img: string | Resource) => {
                  Image(img)
                    .width('100%').height(450).objectFit(ImageFit.Contain)
                    .backgroundColor('#F1F3F5')
                    .onClick(() => {
                      this.currentPreviewImg = img;
                      this.showBigImage = true;
                    })
                })
              }.width('100%').height(450).indicator(this.postData.images.length > 1).loop(false).margin({ bottom: 15 })
            }

            Divider().strokeWidth(8).color('#F1F3F5')

            Column() {
              Row() {
                Text(`评论 (${this.postData.comments?.length ?? 0})`).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333')
                Blank()
              }.width('100%').padding(15)

              if (!this.postData.comments || this.postData.comments.length === 0) {
                Column() {
                  SymbolGlyph($r('sys.symbol.message_badge_plus')).fontSize(40).fontColor(['#EEEEEE'])
                  Text('暂无评论，快来抢沙发...').fontSize(12).fontColor('#CCCCCC').margin({ top: 10 })
                }.width('100%').padding(40)
              } else {
                ForEach(this.postData.comments, (comment: CommentItem) => {
                  Row() {
                    Image($r('app.media.start')).width(32).height(32).borderRadius(16)
                    Column() {
                      Text(comment.userName).fontSize(13).fontColor('#666').fontWeight(FontWeight.Medium)
                      Text(comment.content).fontSize(14).fontColor('#333').margin({ top: 4 }).lineHeight(20)
                    }.alignItems(HorizontalAlign.Start).margin({ left: 10 }).layoutWeight(1)
                  }.width('100%').padding({ left: 15, right: 15, bottom: 20 }).alignItems(VerticalAlign.Top)
                  .onClick(() => {
                    if (!this.checkAuth()) return;
                    this.replyingToUser = comment.userName;
                    this.replyPlaceholder = `回复 @${comment.userName}...`;
                  })
                })
              }
            }.width('100%')
          }
        }.layoutWeight(1).edgeEffect(EdgeEffect.Spring).id(this.snapshotId)

        Column() {
          Row() {
            TextInput({ placeholder: this.replyPlaceholder, text: this.commentInput })
              .layoutWeight(1).height(38).fontSize(14).backgroundColor('#F5F5F5').onChange((v) => this.commentInput = v)
            Text('发送').fontColor(this.commentInput.trim() ? '#007DFF' : '#999999').fontSize(14).fontWeight(FontWeight.Bold).margin({ left: 10 })
              .onClick(() => this.sendComment())
          }.width('100%').padding({ left: 15, right: 15, top: 10, bottom: 5 })

          Row() {
            this.BottomActionItem(
              this.postData.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'),
              this.postData.likeCount > 0 ? this.postData.likeCount.toString() : '点赞',
              this.postData.isLiked ? '#FF4D4F' : '#666666',
              () => { this.toggleLike(); }
            )

            this.BottomActionItem(
              this.postData.isCollected ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'),
              this.postData.isCollected ? '已收藏' : '收藏',
              this.postData.isCollected ? '#FFAD14' : '#666666',
              () => { this.toggleCollect(); }
            )

            this.BottomActionItem(
              $r('sys.symbol.message'),
              (this.postData.comments.length > 0 ? this.postData.comments.length.toString() : '评论'),
              '#666666',
              () => {
                this.replyingToUser = '';
                this.replyPlaceholder = '写下你的评论...';
              }
            )
          }.width('100%').height(50)
        }.backgroundColor('#FFFFFF').border({ width: { top: 1 }, color: '#F1F3F5' })
      }.width('100%').height('100%')

      if (this.showBigImage) {
        Stack() {
          Rect().width('100%').height('100%').fill('#FF000000').onClick(() => this.showBigImage = false)
          Image(this.currentPreviewImg).width('100%').objectFit(ImageFit.Contain)
        }.width('100%').height('100%').zIndex(100)
      }
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }

  @Builder BottomActionItem(icon: Resource, label: string, color: string, action: () => void) {
    Row() {
      SymbolGlyph(icon).fontSize(22).fontColor([color])
      if (label) {
        Text(label).fontSize(13).fontColor(color).margin({ left: 5 })
      }
    }
    .layoutWeight(1).height('100%').justifyContent(FlexAlign.Center)
    .onClick(() => action())
  }
}
