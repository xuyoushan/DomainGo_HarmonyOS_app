import { postRepo, MessageNotification } from '../../../services/PostRepository'
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct MessageCenterView {
  @StorageLink('unreadMessages') unreadMessages: MessageNotification[] = [];
  @StorageLink('currentUserId') currentUserId: string = '';

  // 新增：用于分类显示的过滤状态
  @State selectedCategoryIndex: number = -1; // -1 表示显示全部
  @State filterTypeMap: string[][] = [
    ['like', 'collect'], // 获誉/收藏
    ['follow'],         // 知音/追随
    ['comment']          // 评论
  ];

  // 动态获取当前显示的列表内容
  getFilteredMessages(): MessageNotification[] {
    if (this.selectedCategoryIndex === -1) {
      return [];
    }
    const targetTypes = this.filterTypeMap[this.selectedCategoryIndex];
    return this.unreadMessages.filter(m => targetTypes.includes(m.type));
  }

  getUnreadCount(types: string[]): number {
    return this.unreadMessages.filter(m => types.includes(m.type) && !m.isRead).length;
  }

  async aboutToAppear() {
    await this.refreshMessages();
  }

  async refreshMessages() {
    if (this.currentUserId) {
      const myMsgs = await postRepo.getMyNotifications(this.currentUserId);
      this.unreadMessages = myMsgs;
      AppStorage.setOrCreate('unreadMessages', myMsgs);
    }
  }

  formatTime(timestamp: number): string {
    const now = new Date().getTime();
    const diff = now - timestamp;
    if (diff < 60000) return "刚刚";
    if (diff < 3600000) return Math.floor(diff / 60000) + "分钟前";
    const date = new Date(timestamp);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  getTypeDesc(type: string, userName: string): string {
    switch (type) {
      case 'like': return `${userName} 赞赏了你的动态`;
      case 'collect': return `${userName} 收藏了你的动态`;
      case 'follow': return `${userName} 视你为知音，已追随`;
      case 'comment': return `${userName} 回复了你`;
      default: return `${userName} 传来了消息`;
    }
  }

  build() {
    Column() {
      // --- 顶部导航栏 ---
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(22).fontColor(['#3D3D3D'])
        }
        .width(36).height(36).backgroundColor('rgba(0,0,0,0.05)')
        .borderRadius(18)
        .onClick(() => router.back())

        Text('消息中心')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
          .margin({ left: 15 })

        Blank()

        if (this.unreadMessages.length > 0) {
          Text('全部已读')
            .fontSize(13).fontColor('#B22222').fontWeight(FontWeight.Medium)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#FFF2F0')
            .borderRadius(20)
            .onClick(async () => {
              await postRepo.markAllRead(this.currentUserId);
              await this.refreshMessages();
              promptAction.showToast({ message: '已清除所有未读' });
            })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 45, bottom: 20 })
      .backgroundColor('#FAF9F7')

      // --- 分类功能区：支持点击切换 ---
      Row() {
        this.CategoryItem(0, $r('sys.symbol.heart_fill'), '#B22222', '获誉/收藏', ['like', 'collect'])
        this.CategoryItem(1, $r('sys.symbol.person_2_fill'), '#C0A47E', '知音/追随', ['follow'])
        this.CategoryItem(2, $r('sys.symbol.message_fill'), '#5C5446', '评论', ['comment'])
      }
      .width('92%')
      .margin({ bottom: 20 })
      .padding(15)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 20, color: '#08000000', offsetY: 8 })

      List({ space: 10 }) {
        if (this.selectedCategoryIndex === -1) {
          ListItem() {this.OfficialNotificationItem()
          }
        }

        if (this.getFilteredMessages().length === 0) {
          ListItem() {
            Column() {
              SymbolGlyph($r('sys.symbol.box_ellipsis_message_filled'))
                .fontSize(60).fontColor(['#D1CEC7'])
              Text(this.selectedCategoryIndex === -1 ? '暂无新消息' : '该分类下暂无动态')
                .fontSize(14).fontColor('#BDB9B1').margin({ top: 10 })
            }.width('100%').margin({ top: 80 })
          }
        }

        ForEach(this.getFilteredMessages(), (msg: MessageNotification) => {
          ListItem() {
            this.NotificationItem(msg)
          }
          .swipeAction({ end: this.deleteButton(msg.id) })
        }, (item: MessageNotification) => item.id + item.isRead + this.selectedCategoryIndex)

        ListItem().height(30)
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 16, right: 16 })
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF9F7')
  }

  @Builder
  deleteButton(id: string) {
    Button() {
      SymbolGlyph($r('sys.symbol.trash')).fontSize(20).fontColor([Color.White])
    }
    .backgroundColor('#B22222')
    .width(70)
    .height('85%')
    .borderRadius({ topLeft: 16, bottomLeft: 16 })
    .margin({ top: 5 })
    .onClick(async () => {
      await postRepo.deleteNotification(id);
      await this.refreshMessages();
    })
  }

  @Builder OfficialNotificationItem() {
    Row() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image($r('app.media.start'))
          .width(48).height(48)
          .borderRadius(24)
          .border({ width: 1.5, color: '#B22222' })
      }

      Column() {
        Row() {
          Text('寻域官方')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .layoutWeight(1)
        }
        .width('100%')

        Text('欢迎加入寻域，触摸每座城市的温度。')
          .fontSize(13)
          .fontColor('#5C5446')
          .margin({ top: 6 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .margin({ left: 14 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 10, color: '#05000000', offsetY: 4 })
    .onClick(() => {
      AlertDialog.show({
        title: '寻域公告',
        message: '感谢你来到寻域！在这里，你可以记录探险足迹，结交同道知音。若有任何建议，欢迎通过反馈渠道联系官方。',
        confirm: {
          value: '我知道了',
          action: () => {}
        }
      })
    })
  }

  @Builder NotificationItem(msg: MessageNotification) {
    Row() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(msg.fromAvatar)
          .width(48).height(48)
          .borderRadius(24)
          .border({ width: 1, color: '#F0EDE7' })

        if (!msg.isRead) {
          Circle({ width: 10, height: 10 })
            .fill('#B22222')
            .stroke(Color.White)
            .strokeWidth(2)
            .offset({ x: 2, y: -2 })
        }
      }

      Column() {
        Row() {
          Text(this.getTypeDesc(msg.type, msg.fromUserName))
            .fontSize(15)
            .fontWeight(msg.isRead ? FontWeight.Normal : FontWeight.Bold)
            .fontColor(msg.isRead ? '#666666' : '#1A1A1A')
            .layoutWeight(1)

          Text(this.formatTime(msg.timestamp))
            .fontSize(11)
            .fontColor('#BBBBBB')
        }
        .width('100%')

        Text(msg.targetContent)
          .fontSize(13)
          .fontColor(msg.isRead ? '#999999' : '#5C5446')
          .margin({ top: 6 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .margin({ left: 14 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(msg.isRead ? 'rgba(255,255,255,0.6)' : '#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 10, color: '#05000000', offsetY: 4 })
    .onClick(async () => {
      if (!msg.isRead) {
        await postRepo.markNotificationAsRead(msg.id);
        await this.refreshMessages();
      }
    })
  }

  @Builder CategoryItem(idx: number, icon: Resource, color: string, label: string, types: string[]) {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column() {
          SymbolGlyph(icon)
            .fontSize(24)
            .fontColor([this.selectedCategoryIndex === idx ? Color.White : color])
        }
        .width(54).height(54)
        // 选中时背景变色
        .backgroundColor(this.selectedCategoryIndex === idx ? color : '#F7F8FA')
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
        .animation({ duration: 200 }) // 增加简单动效

        if (this.getUnreadCount(types) > 0) {
          Text(this.getUnreadCount(types) > 99 ? '99+' : this.getUnreadCount(types).toString())
            .fontSize(10).fontColor(Color.White).fontWeight(FontWeight.Bold)
            .backgroundColor('#B22222')
            .padding({ left: 5, right: 5 })
            .height(16).constraintSize({ minWidth: 16 })
            .borderRadius(8)
            .border({ width: 1.5, color: Color.White })
            .offset({ x: 5, y: -5 })
        }
      }
      Text(label)
        .fontSize(12)
        .margin({ top: 8 })
        .fontColor(this.selectedCategoryIndex === idx ? '#1A1A1A' : '#5C5446')
        .fontWeight(this.selectedCategoryIndex === idx ? FontWeight.Bold : FontWeight.Medium)
    }
    .layoutWeight(1)
    .onClick(async () => {
      if (this.selectedCategoryIndex === idx) {
        this.selectedCategoryIndex = -1;
      } else {
        this.selectedCategoryIndex = idx;
      }
    })
  }
}