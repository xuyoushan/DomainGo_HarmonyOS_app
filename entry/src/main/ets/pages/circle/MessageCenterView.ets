import router from '@ohos.router';

// 定义通知消息接口，确保与 CircleView 逻辑一致
interface MessageNotification {
  id: string;
  type: 'like' | 'collect' | 'follow' | 'comment';
  fromUserName: string; // 虽然数据里有，但在 UI 上我们按要求隐藏它
  fromAvatar: ResourceStr;
  targetContent: string;
  timestamp: number;
}

@Entry
@Component
struct MessageCenterView {
  // 监听全局消息列表
  @StorageLink('unreadMessages') unreadMessages: MessageNotification[] = [];

  // 获取特定类型的未读数量
  getUnreadCount(types: string[]): number {
    return this.unreadMessages.filter(m => types.includes(m.type)).length;
  }

  // 清除特定类型的消息
  clearMessages(types: string[]): void {
    this.unreadMessages = this.unreadMessages.filter(m => !types.includes(m.type));
    AppStorage.SetOrCreate('unreadMessages', this.unreadMessages);
  }

  // 格式化时间显示
  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  // MessageCenterView.ets 内部

  // 1. 修改描述文字生成逻辑，把用户名传进去
  getTypeDesc(type: string, userName: string): string {
    switch (type) {
      case 'like': return `${userName} 赞了你的动态`;
      case 'collect': return `${userName} 收藏了你的动态`;
      case 'follow': return `${userName} 关注了你`;
      case 'comment': return `${userName} 评论了你`;
      default: return `${userName} 与你互动了`;
    }
  }

  build() {
    Column() {
      // 1. 顶部标题栏
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .onClick(() => router.back())
        Text('消息中心')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 15 })
        Blank()
        if (this.unreadMessages.length > 0) {
          Text('全部已读')
            .fontSize(14)
            .fontColor('#999999')
            .onClick(() => {
              this.unreadMessages = [];
              AppStorage.SetOrCreate('unreadMessages', []);
            })
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')

      // 2. 分类通知入口
      Row() {
        this.CategoryItem($r('sys.symbol.heart_fill'), '#FF4D4F', '赞和收藏', this.getUnreadCount(['like', 'collect']), () => {
          this.clearMessages(['like', 'collect']);
        })
        this.CategoryItem($r('sys.symbol.person_badge_plus'), '#007DFF', '新增关注', this.getUnreadCount(['follow']), () => {
          this.clearMessages(['follow']);
        })
        this.CategoryItem($r('sys.symbol.message'), '#6236FF', '评论和@', this.getUnreadCount(['comment']), () => {
          this.clearMessages(['comment']);
        })
      }
      .width('100%')
      .padding({ top: 10, bottom: 20 })
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundColor('#FFFFFF')

      // 3. 消息列表
      List() {
        if (this.unreadMessages.length === 0) {
          ListItem() {
            Column() {
              Image($r('app.media.ic_mine_active')) // 假设有一个空状态图
                .width(120).opacity(0.2).grayscale(1)
              Text('暂无新消息')
                .fontSize(14).fontColor('#CCCCCC').margin({ top: 10 })
            }.width('100%').margin({ top: 100 })
          }
        }

        ForEach(this.unreadMessages, (msg: MessageNotification) => {
          ListItem() {
            this.NotificationItem(msg)
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
      .divider({ strokeWidth: 0.5, color: '#F1F3F5', startMargin: 70 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }

  // 2. 在 NotificationItem 中显示该文字
  @Builder
  NotificationItem(msg: MessageNotification) {
    Row() {
      Image(msg.fromAvatar)
        .width(44).height(44).borderRadius(22)

      Column() {
        Row() {
          // --- 修改点：这里调用 getTypeDesc 时传入 msg.fromUserName ---
          Text(this.getTypeDesc(msg.type, msg.fromUserName))
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#181818')

          Blank()
          Text(this.formatTime(msg.timestamp)).fontSize(12).fontColor('#CCCCCC')
        }
        .width('100%')

        Text(msg.targetContent)
          .fontSize(13).fontColor('#888888').margin({ top: 5 })
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
  }

  // 分类图标组件
  @Builder
  CategoryItem(icon: Resource, color: string, label: string, count: number, onClick: () => void) {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Circle({ width: 50, height: 50 }).fill(color).opacity(0.1)
        SymbolGlyph(icon)
          .fontSize(26)
          .fontColor([color])
          .margin(12)

        if (count > 0) {
          Text(count > 99 ? '99+' : count.toString())
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor('#FF4D4F')
            .padding({ left: 5, right: 5 })
            .height(16)
            .constraintSize({ minWidth: 16 })
            .borderRadius(8)
            .textAlign(TextAlign.Center)
            .offset({ x: 5, y: -5 })
        }
      }
      Text(label)
        .fontSize(12)
        .margin({ top: 8 })
        .fontColor('#666666')
    }
    .onClick(() => {
      onClick();
    })
  }
}