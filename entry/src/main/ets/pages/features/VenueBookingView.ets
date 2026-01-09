import { router, promptAction } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';
import { CITY_VENUES_MAP, Venue } from '../../models/VenueData';

@Entry
@Component
struct VenueBookingView {
  @StorageLink('currentCity') currentCity: string = '北京市';
  @State searchText: string = '';
  @State activeIndex: number = 0; // 控制Tab同步
  private categories: string[] = ['博物馆', '美术馆', '科技馆', '体育馆', '其他'];

  // 获取当前Tab分类下的数据
  getCategoryVenues(cat: string) {
    return (CITY_VENUES_MAP[this.currentCity] || []).filter(v => v.category === cat);
  }

  // 获取搜索模式下的全局数据
  getSearchVenues() {
    return (CITY_VENUES_MAP[this.currentCity] || []).filter(v => v.name.includes(this.searchText));
  }

  // 逻辑处理：点击小程序按钮时触发
  copyToClipboard(text: string) {
    const data: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();

    systemPasteboard.setData(data).then(() => {
      promptAction.showDialog({
        title: '已复制小程序名称',
        message: `名称【${text}】已复制。\n请打开微信 -> 搜索并进入小程序。`,
        buttons: [{ text: '好的', color: '#07C160' }]
      })
    }).catch((err: Error) => {
      promptAction.showToast({ message: '复制失败' });
    });
  }

  build() {
    Column() {
      // 1. 顶部导航
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).onClick(() => router.back())
        Text(`${this.currentCity} · 场馆指南`).fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 12 })
        Blank()
        SymbolGlyph($r('sys.symbol.qrcode')).fontSize(24).fontColor(['#007DFF'])
          .onClick(() => promptAction.showToast({ message: '凭证夹：点击场馆页相机图标即可存入' }))
      }.width('100%').padding(15).backgroundColor(Color.White)

      // 2. 搜索框
      Search({ placeholder: '搜索场馆名称...', value: this.searchText })
        .margin({ left: 16, right: 16, bottom: 10 })
        .onChange(v => this.searchText = v)

      if (this.searchText.trim() !== '') {
        // --- 模式A：搜索模式（纯结果，无分类，无空提示） ---
        List({ space: 16 }) {
          ForEach(this.getSearchVenues(), (venue: Venue) => {
            ListItem() { this.VenueCard(venue) }
          }, (item: Venue) => item.id)
        }
        .layoutWeight(1)
        .padding({ bottom: 20 })
      } else {
        // --- 模式B：分类模式（顶部Tab切换） ---
        Tabs({ barPosition: BarPosition.Start }) {
          ForEach(this.categories, (cat: string) => {
            TabContent() {
              this.CategoryList(cat)
            }.tabBar(cat)
          })
        }
        .barMode(BarMode.Fixed)
        .layoutWeight(1)
        .onChange((index) => this.activeIndex = index)
      }
    }.backgroundColor('#F5F7FA').height('100%')
  }

  @Builder CategoryList(cat: string) {
    if (this.getCategoryVenues(cat).length > 0) {
      List({ space: 16 }) {
        ForEach(this.getCategoryVenues(cat), (venue: Venue) => {
          ListItem() { this.VenueCard(venue) }
        }, (item: Venue) => item.id)
      }
      .width('100%')
      .height('100%')
      .padding(16)
    } else {
      // 仅在非搜索的分类为空时显示
      this.EmptyTips(cat)
    }
  }

  @Builder VenueCard(venue: Venue) {
    Column() {
      // --- 顶部图片/占位区 ---
      Stack({ alignContent: Alignment.TopStart }) {
        if (venue.image) {
          Image(venue.image)
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: 12, topRight: 12 })
        } else {
          Rect()
            .width('100%')
            .height(120)
            .fill('#EDF0F5')
            .borderRadius({ topLeft: 12, topRight: 12 })
        }

        if (venue.isHot) {
          Text('热门')
            .fontSize(12)
            .fontColor(Color.White)
            .backgroundColor('#FF4D4F')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius({ topLeft: 12, bottomRight: 8 })
        }
      }

      // --- 内容描述区 ---
      Column() {
        Text(venue.name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(venue.description)
          .fontSize(13)
          .fontColor('#666')
          .margin({ top: 6 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 预约提醒标签
        if (venue.tips) {
          Text(venue.tips)
            .fontSize(12)
            .fontColor('#FF9500')
            .backgroundColor('#FFF8E1')
            .padding(8)
            .borderRadius(6)
            .margin({ top: 10 })
            .width('100%')
        }

        // --- 底部交互按钮区 ---
        Row({ space: 12 }) {
          // 只有配置了官网才显示
          if (venue.officialUrl) {
            Button('官网预约')
              .layoutWeight(1)
              .height(36)
              .fontSize(14)
              .backgroundColor('#007DFF')
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/features/VenueWebView',
                  params: { venue: venue }
                })
              })
          }

          // 只有配置了小程序名才显示
          if (venue.wechatName) {
            Button('小程序')
              .layoutWeight(1)
              .height(36)
              .fontSize(14)
              .fontColor('#07C160')
              .backgroundColor('#E8F7ED') // 浅绿色背景更精致
              .onClick(() => {
                // 这里调用定义在组件顶层的函数
                this.copyToClipboard(venue.wechatName as string);
              })
          }

          // 如果都不需要预约，显示绿色提示
          if (!venue.needBooking) {
            Text('无需预约')
              .fontSize(13)
              .fontColor('#27AE60')
              .fontWeight(FontWeight.Medium)
          }
        }
        .margin({ top: 15 })
        .width('100%')
        .justifyContent(FlexAlign.End)

      }
      .padding(15)
      .alignItems(HorizontalAlign.Start)
    }
    .width('94%')
    .margin({ left: '3%', right: '3%', bottom: 16 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 15, color: '#15000000', offsetX: 0, offsetY: 8 })
  }

  @Builder EmptyTips(cat: string) {
    Column() {
      SymbolGlyph($r('sys.symbol.info_circle')).fontSize(48).fontColor(['#DDD'])
      Text(`暂未收录${this.currentCity}的${cat}`).fontSize(14).fontColor('#BBB').margin({ top: 10 })
    }.width('100%').height('60%').justifyContent(FlexAlign.Center)
  }

  @Builder SmallBtn(text: string, color: string, action: () => void) {
    Button(text)
      .fontSize(14)
      .fontColor(Color.White)
      .backgroundColor(color)
      .height(32)
      .padding({ left: 16, right: 16 })
      .onClick(action)
  }
}