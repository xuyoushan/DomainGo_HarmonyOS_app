import router from '@ohos.router';

@Entry
@Component
struct MessageCenterView {
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
      }
      .width('100%')
      .padding(20)

      // 2. 顶部功能区：普通通知分类
      Row() {
        this.MessageCategoryItem($r('sys.symbol.heart_fill'), '赞和收藏', '#FF4D4F')
        this.MessageCategoryItem($r('sys.symbol.person_filled_2_badge_plus_fill'), '新增关注', '#007DFF')
        this.MessageCategoryItem($r('sys.symbol.text_bubble_left_2'), '评论和@', '#52C41A')
        this.MessageCategoryItem($r('sys.symbol.message_badge_gearshape'), '系统通知', '#FAAD14')
      }
      .width('100%')
      .padding({ top: 10, bottom: 25 })
      .justifyContent(FlexAlign.SpaceAround)

      Divider().strokeWidth(8).color('#F1F3F5')

      // 3. 私信列表区
      Text('私信对话')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .padding(20)

      List() {
        ForEach([1, 2, 3], (item: number) => {
          ListItem() {
            this.ChatListItem(item)
          }
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  // 顶部快捷分类组件
  @Builder
  MessageCategoryItem(icon: Resource, label: string, color: string) {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Circle({ width: 50, height: 50 }).fill(color).opacity(0.1)
        SymbolGlyph(icon)
          .fontSize(26)
          .fontColor([color])
          .margin(12)

        // 未读红点示例
        Circle({ width: 10, height: 10 }).fill('#FF4D4F')
          .offset({ x: 5, y: -5 })
      }
      Text(label)
        .fontSize(12)
        .margin({ top: 8 })
        .fontColor('#666666')
    }
  }

  // 私信列表单项
  @Builder
  ChatListItem(index: number) {
    Row() {
      Image($r('app.media.ic_mine_active'))
        .width(50).height(50).borderRadius(25)

      Column() {
        Row() {
          Text('探险队友_' + index).fontSize(16).fontWeight(FontWeight.Medium)
          Blank()
          Text('14:20').fontSize(12).fontColor('#CCCCCC')
        }.width('100%')

        Text('最近在成都太古里点亮了新领域，要一起组队吗？')
          .fontSize(14)
          .fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 5 })
      }
      .layoutWeight(1)
      .margin({ left: 15 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 15, bottom: 15 })
  }
}