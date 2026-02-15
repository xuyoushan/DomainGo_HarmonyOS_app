import { router, promptAction, componentSnapshot } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { PostItem, CommentItem } from '../../models/PostItem';
import image from '@ohos.multimedia.image';
import { postRepo } from '../../services/PostRepository';
import { BusinessError } from '@kit.BasicServicesKit';

export interface MessageNotification {
  id: string;
  type: string;
  fromUserName: string;
  fromAvatar: string | Resource;
  targetContent: string;
  timestamp: number;
  isRead: boolean;
}
@Entry
@Component
struct PostDetailView {
  @StorageLink('globalPostList') globalPosts: PostItem[] = [];
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('currentUserId') currentUserId: string = '';
  @StorageLink('unreadMessages') unreadMessages: MessageNotification[] = [];
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

  async saveToAlbum() {
    try {
      await new Promise<void>((resolve: () => void) => {setTimeout(() => {resolve();}, 100);});
      const pixmap: image.PixelMap = await componentSnapshot.get(this.snapshotId);
      if (!pixmap) {
        promptAction.showToast({ message: '截图生成失败' });
        return;
      }
      const imagePacker = image.createImagePacker();
      const packOpts: image.PackingOption = {
        format: 'image/jpeg',
        quality: 100
      };

      const buffer: ArrayBuffer = await imagePacker.packing(pixmap, packOpts);

      const context = getContext(this);
      const helper = photoAccessHelper.getPhotoAccessHelper(context);

      const assetUri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');

      const file = await fs.open(assetUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(file.fd, buffer);
      await fs.close(file.fd);

      promptAction.showToast({ message: '截图已存至相册' });
      pixmap.release();
      imagePacker.release();

    } catch (err) {
      const error = err as BusinessError;
      console.error(`SaveToAlbumFailed: Code: ${error.code}, Message: ${error.message}`);
      if (error.code === 201) {
        promptAction.showToast({ message: '请在设置中开启相册权限' });
      } else {
        promptAction.showToast({ message: `保存失败: ${error.code}` });
      }
    }
  }

  aboutToAppear() {
    this.syncFromGlobal();
  }

  syncFromGlobal() {
    const p = this.globalPosts.find(item => item.id === this.postData.id);
    if (!p) return;

    const uid = this.currentUserId;

    this.postData = {
      id: p.id,
      userId: p.userId,
      userName: p.userName,
      avatar: p.avatar,
      text: p.text,
      images: p.images,
      timestamp: p.timestamp,
      location: p.location,
      comments: p.comments || [],
      likeUserIds: p.likeUserIds || [],
      collectUserIds: p.collectUserIds || [],
      likeCount: (p.likeUserIds || []).length,
      // isLiked: (p.likeUserIds || []).indexOf(this.currentUserId) !== -1,
      // isCollected: (p.collectUserIds || []).indexOf(this.currentUserId) !== -1,
      isLiked: (p.likeUserIds || []).includes(this.currentUserId),
      isCollected: (p.collectUserIds || []).includes(this.currentUserId)
    };
  }

  syncChanges() {
    const index = this.globalPosts.findIndex(p => p.id === this.postData.id);
    if (index !== -1) {
      this.globalPosts[index] = this.postData;
      AppStorage.setOrCreate('globalPostList', this.globalPosts.slice());
    }
  }

  toggleCommentLike(commentIndex: number) {
    if (!this.checkAuth()) return;
    let comments = this.postData.comments;
    if (!comments || !comments[commentIndex]) return;
    let comment = comments[commentIndex];
    if (comment.isLiked) {
      comment.likeCount = (comment.likeCount || 1) - 1;
      comment.isLiked = false;
    } else {
      comment.likeCount = (comment.likeCount || 0) + 1;
      comment.isLiked = true;
    }
    this.postData.comments = [...comments];
    this.syncChanges();
  }

  deleteComment(commentIndex: number) {
    promptAction.showDialog({
      title: '删除评论',
      message: '确定要删除这条评论吗？',
      buttons: [{ text: '取消', color: '#666' }, { text: '删除', color: '#FF4D4F' }]
    }).then(data => {
      if (data.index === 1) {
        this.postData.comments.splice(commentIndex, 1);
        this.postData.comments = [...this.postData.comments];
        this.syncChanges();
        promptAction.showToast({ message: '评论已删除' });
      }
    });
  }

  getRelativeTime(time: number): string {
    const date = new Date(time);
    const h = date.getHours();
    const m = date.getMinutes();
    const mm = m < 10 ? `0${m}` : `${m}`;
    return `${date.getMonth() + 1}月${date.getDate()}日 ${h}:${mm}`;
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

        await postRepo.deletePost(idToDelete);

        const newList = this.globalPosts.filter(p => p.id !== idToDelete);
        this.globalPosts = newList;
        AppStorage.setOrCreate('globalPostList', newList.slice());

        promptAction.showToast({ message: '帖子已删除' });

        setTimeout(() => {
          router.back();
        }, 100);
      }
    });
  }

  async sendComment() {
    if (!this.checkAuth()) return;
    if (!this.commentInput.trim()) return;

    const currentName = AppStorage.get<string>('userName') || '匿名探险家';
    const currentAvatar = AppStorage.get<string>('userAvatar') || $r('app.media.start');
    let content = this.commentInput;

    if (this.replyingToUser) {
      content = `回复 @${this.replyingToUser} : ${this.commentInput}`;
    }

    const newComment: CommentItem = {
      userId: this.currentUserId,
      userName: currentName,
      avatar: currentAvatar,
      content: content,
      timestamp: Date.now()
    };

    const index = this.globalPosts.findIndex(p => p.id === this.postData.id);
    if (index !== -1) {
      const origin = this.globalPosts[index];
      if (!origin.comments) {origin.comments = [];
        origin.comments.unshift(newComment);
        this.postData.comments = [...origin.comments];
        this.globalPosts[index] = origin;
        await postRepo.updatePost(origin);
        AppStorage.setOrCreate('globalPostList', [...this.globalPosts]);}
      if (this.replyingToUser) {
        const targetIndex = origin.comments.findIndex(
          (c: CommentItem) => c.userName === this.replyingToUser
        );
        if (targetIndex !== -1) {
          origin.comments.splice(targetIndex + 1, 0, newComment);
        } else {
          origin.comments.unshift(newComment);
        }
      } else {
        origin.comments.unshift(newComment);
      }
      const refreshedComments: CommentItem[] = [];
      for (let i = 0; i < origin.comments.length; i++) {
        refreshedComments.push(origin.comments[i]);
      }
      origin.comments = refreshedComments;
      this.postData.comments = refreshedComments;
      this.globalPosts[index] = origin;
      AppStorage.setOrCreate('globalPostList', this.globalPosts.slice());
    }
    if (this.postData.userId !== this.currentUserId) {
      let avatarForNotify: string = '';
      if (typeof currentAvatar === 'string') {
        avatarForNotify = currentAvatar;
      } else {
        avatarForNotify = '';
      }
      try {
        await postRepo.sendNotification(
          this.postData.userId,
          this.currentUserId,
          currentName,
          avatarForNotify,
          'comment',
          this.postData.text
        );
      } catch (err) {
        console.error('评论通知发送失败', JSON.stringify(err));
      }
    }
    this.commentInput = '';
    this.replyingToUser = '';
    this.replyPlaceholder = '写下你的评论...';
    promptAction.showToast({ message: '评论成功' });
  }

  build() {
    Stack() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .onClick(() => { router.back() })

          Blank()

          if (this.postData.userId === this.currentUserId) {
            Button() {
              SymbolGlyph($r('sys.symbol.trash'))
                .fontSize(20)
                .fontColor(['#FF4D4F'])
            }
            .width(40).height(40)
            .backgroundColor(Color.Transparent)
            .margin({ right: 10 })
            .onClick(() => {
              this.handleDeletePost();
            })
          }
            SaveButton({
              icon: SaveIconStyle.FULL_FILLED,
              buttonType: ButtonType.Normal
            })
              .height(40)
              .width(40)
              // .backgroundColor('#00FFFFFF')
              .fontColor('#333333')
              .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
                if (result === SaveButtonOnClickResult.SUCCESS) {
                  await this.saveToAlbum();
                } else {
                  promptAction.showToast({ message: '保存授权失败' });
                }
              })
        }
        .width('100%')
        .height(56)
        .padding({ left: 15, right: 15 })
        .width('100%').padding(15).backgroundColor('#FFFFFF')

        Scroll() {
          Column() {
            Row() {
              Image(this.postData.avatar || $r('app.media.start'))
                .width(45).height(45).borderRadius(22.5)
                .onClick(() => {
                  if (!this.checkAuth()) return;
                  if (this.postData.userId === this.currentUserId) {
                    AppStorage.setOrCreate('mainIndex', 4);
                    router.back({ url: 'pages/Index' });
                  } else {
                    router.pushUrl({ url: 'pages/features/mine/UserHomeView', params: { userId: this.postData.userId } });                  }
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
                    .width('100%').height('auto').objectFit(ImageFit.Contain)
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
                ForEach(this.postData.comments, (comment: CommentItem, index: number) => {
                  Row() {
                    Image(comment.avatar || $r('app.media.start'))
                      .width(32).height(32).borderRadius(16)

                    Column() {
                      Row() {
                        Text(comment.userName).fontSize(13).fontColor('#666').fontWeight(FontWeight.Medium)

                        if (comment.userName === AppStorage.get<string>('userName')) {
                          Text('删除')
                            .fontSize(11).fontColor('#999').margin({ left: 10 })
                            .onClick(() => { this.deleteComment(index) })
                        }

                        Blank()

                        Row() {
                          SymbolGlyph(comment.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
                            .fontSize(16)
                            .fontColor([comment.isLiked ? '#FF4D4F' : '#999999'])
                          Text((comment.likeCount || 0).toString())
                            .fontSize(12)
                            .fontColor(comment.isLiked ? '#FF4D4F' : '#999999')
                            .margin({ left: 4 })
                        }.onClick(() => { this.toggleCommentLike(index) })
                      }.width('100%')

                      Text() {
                        if (comment.content.includes('回复 @') && comment.content.includes(' : ')) {
                          Span(comment.content.substring(0, comment.content.indexOf(' : ')))
                            .fontColor('#007DFF')
                            .fontWeight(FontWeight.Medium)
                          Span(comment.content.substring(comment.content.indexOf(' : ')))
                            .fontColor('#333')
                        } else {
                          Span(comment.content)
                            .fontColor('#333')
                        }
                      }.fontSize(14).margin({ top: 4 }).lineHeight(20)
                      if (comment.timestamp) {
                        Text(this.getRelativeTime(comment.timestamp))
                          .fontSize(10)
                          .fontColor('#CCCCCC')
                          .margin({ top: 4 })
                      }
                    }.alignItems(HorizontalAlign.Start).margin({ left: 10 }).layoutWeight(1)
                  }.width('100%')
                  .padding({
                    left: comment.content.includes('回复 @') ? 45 : 15,
                    right: 15,
                    bottom: 20
                  })
                  .alignItems(VerticalAlign.Top)
                  .onClick(() => {
                    if (!this.checkAuth()) return;
                    this.replyingToUser = comment.userName;
                    this.replyPlaceholder = `回复 @${comment.userName}...`;
                    promptAction.showToast({ message: `正在回复 ${comment.userName}` });
                  })
                }, (item: CommentItem) => JSON.stringify(item))
              }
            }.width('100%')
          }
        }.layoutWeight(1).edgeEffect(EdgeEffect.Spring)

        Column() {
          Row() {
            TextInput({ placeholder: this.replyPlaceholder, text: this.commentInput })
              .layoutWeight(1)
              .height(40)
              .fontSize(14)
              .backgroundColor('#F5F5F5')
              .onChange((v) => this.commentInput = v)

            Text('发送')
              .fontColor(this.commentInput.trim() ? '#007DFF' : '#999999')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .margin({ left: 15 })
              .onClick(() => this.sendComment())
          }
          .width('100%')
          .padding({
            left: 15,
            right: 15,
            top: 10,
            bottom: 25
          })
        }
        .backgroundColor('#FFFFFF')
        .border({ width: { top: 1 }, color: '#F1F3F5' })
      }.width('100%').height('100%').id(this.snapshotId).backgroundColor('#FFFFFF')

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