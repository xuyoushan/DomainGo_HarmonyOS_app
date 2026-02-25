import { router, promptAction } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';
import { CITY_VENUES_MAP, Venue } from '../../../models/VenueData';
import { EmptyComponent } from '../../../models/EmptyComponent';

interface NameResult {
  main: string;
  bracket: string;
}

@Entry
@Component
struct VenueBookingView {
  @StorageLink('currentCity') currentCity: string = '北京市';
  @State searchText: string = '';
  @State activeIndex: number = 0;
  @State categories: string[] = ['文博馆', '科技馆', '体育馆', '学术殿堂', '其他'];

  getVenueColor(category: string): string[] {
    switch (category) {
      case '文博馆': return ['#FF5E62', '#FF9966'];
      case '学术殿堂': return ['#4facfe', '#00f2fe'];
      case '科技馆': return ['#667eea', '#764ba2'];
      case '体育馆': return ['#11998e', '#38ef7d'];
      case '其他': return ['#FAD961', '#F76B1C'];
      default: return ['#606c88', '#3f4c6b'];
    }
  }

  getFilteredVenues(cat: string): Venue[] {
    const allVenues = CITY_VENUES_MAP[this.currentCity] || [];

    if (cat === '文博馆') {
      return allVenues.filter(v => {
        const vCat = v.category as string;
        return vCat === '文博馆' || vCat === '博物馆' || vCat === '美术馆' ||
        v.name.includes('纪念馆') || v.name.includes('故居');
      });
    }

    if (cat === '学术殿堂') {
      return allVenues.filter(v =>
      v.category === '学术殿堂' || v.isUniversity === true || v.isLibrary === true
      );
    }

    return allVenues.filter(v => v.category === cat);
  }
  getShortName(name: string): string {
    if (name.length <= 7) {
      return name;
    }

    let short = name.replace(/（.*?）/g, '').replace(/\(.*?\)/g, '');

    const areaPrefixes = ['湖北省', '武汉市', '北京市', '天津市', '四川省', '成都市', '上海市', '重庆市'];
    areaPrefixes.forEach(p => {
      if (short.startsWith(p)) short = short.replace(p, '');
    });

    const suffixes = ['博物馆', '美术馆', '纪念馆', '科技馆', '体育馆', '图书馆', '体育中心'];
    for (let s of suffixes) {
      if (short.endsWith(s) && short.length > s.length + 2) {
        short = short.replace(s, '');
      }
    }

    return short.length > 7 ? short.substring(0, 6) : short;
  }
  getSearchVenues() {
    const keyword = this.searchText.trim().toLowerCase();
    return (CITY_VENUES_MAP[this.currentCity] || []).filter(v =>
    v.name.toLowerCase().includes(keyword) ||
    v.description.toLowerCase().includes(keyword) ||
      (keyword.includes('大学') && v.isUniversity) ||
      (keyword.includes('图书') && v.isLibrary)
    );
  }

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

  handleName(fullName: string): NameResult {
    const leftBracket = fullName.indexOf('（') !== -1 ? fullName.indexOf('（') : fullName.indexOf('(');
    const rightBracket = fullName.indexOf('）') !== -1 ? fullName.indexOf('）') : fullName.indexOf(')');

    if (leftBracket !== -1 && rightBracket !== -1) {
      return {
        main: fullName.substring(0, leftBracket),
        bracket: fullName.substring(leftBracket, rightBracket + 1)
      };
    }
    return { main: fullName, bracket: '' };
  }

  build() {
    Column() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).onClick(() => router.back())
        Text(`${this.currentCity} · 场馆指南`).fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 12 })
        Blank()
        SymbolGlyph($r('sys.symbol.qrcode')).fontSize(24).fontColor(['#007DFF'])
          .onClick(() => {
            router.pushUrl({
              url: 'pages/features/AllFunctions/ScheduleView',
              params: { showEvidenceOnly: true }
            })
          })
      }.width('100%').padding(15).backgroundColor(Color.White)

      Search({ placeholder: '搜索名称、大学或图书馆...', value: this.searchText })
        .margin({ left: 16, right: 16, bottom: 10 })
        .onChange(v => this.searchText = v)

      if (this.searchText.trim() !== '') {
        if (this.getSearchVenues().length > 0) {
          List({ space: 16 }) {
            ForEach(this.getSearchVenues(), (venue: Venue) => {
              ListItem() { this.VenueCard(venue) }
            }, (item: Venue) => item.id)
          }
          .layoutWeight(1)
          .padding({ bottom: 20 })
        } else {
          EmptyComponent({
            title: '未找到相关场馆',
            subTitle: `尝试搜索其他关键词，例如“大学”或“博物馆”`,
            imageRes: $r('sys.symbol.magnifyingglass')
          })
        }
      } else {
        Tabs({ barPosition: BarPosition.Start }) {
          ForEach(this.categories, (cat: string) => {
            TabContent() {
              this.CategoryList(cat)
            }.tabBar(cat)
          })
        }
        .barMode(BarMode.Scrollable)
        .layoutWeight(1)
        .onChange((index) => this.activeIndex = index)
      }
    }.backgroundColor('#F5F7FA').height('100%')
  }

  @Builder CategoryList(cat: string) {
    if (this.getFilteredVenues(cat).length > 0) {
      List({ space: 16 }) {
        ForEach(this.getFilteredVenues(cat), (venue: Venue) => {
          ListItem() { this.VenueCard(venue) }
        }, (item: Venue) => item.id)
      }
      .width('100%')
      .height('100%')
      .padding({ top: 16, bottom: 16 })
    } else {
      EmptyComponent({
        title: `暂无${cat}数据`,
        subTitle: `我们正在努力收录${this.currentCity}的${cat}信息，请耐心等待。`,
        imageRes: cat === '学术殿堂' ? $r('sys.symbol.book_badge_play') : $r('sys.symbol.exclamationmark_and_minus_plus_batteryblock_stack')
      })
    }
  }
  @Builder TabBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontColor(this.activeIndex === index ? '#007DFF' : '#666')
        .fontSize(this.activeIndex === index ? 16 : 14)
        .fontWeight(this.activeIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .margin({ left: 10, right: 10 })
      Rect()
        .width(20)
        .height(3)
        .fill($r('sys.color.brand'))
        .margin({ top: 4 })
        .opacity(this.activeIndex === index ? 1 : 0)
    }
  }

  @Builder VenueTitleArea(mainName: string, bracket: string) {
    Column() {
      Text(mainName)
        .fontSize(mainName.length > 6 ? 24 : 30)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .shadow({ radius: 10, color: '#44000000', offsetX: 2, offsetY: 2 })

      if (bracket !== '') {
        Text(bracket)
          .fontSize(14)
          .fontColor(Color.White)
          .opacity(0.9)
          .margin({ top: 6 })
      }
    }
    .padding({ left: 15, right: 15 })
  }

  @Builder VenueCard(venue: Venue) {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        if (venue.image) {
          Image(venue.image)
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: 12, topRight: 12 })
        } else {
          Column() {
            this.VenueTitleArea(
              this.handleName(venue.name).main,
              this.handleName(venue.name).bracket
            )
          }
          .width('100%')
          .height(180)
          .justifyContent(FlexAlign.Center)
          .borderRadius({ topLeft: 12, topRight: 12 })
          .linearGradient({
            direction: GradientDirection.LeftTop,
            colors: [
              [this.getVenueColor(venue.category)[0], 0.0],
              [this.getVenueColor(venue.category)[1], 1.0]
            ]
          })
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

      Column() {
        Row() {
          Text(venue.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .layoutWeight(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (venue.isUniversity) {
            SymbolGlyph($r('sys.symbol.medal')).fontColor(['#007DFF']).fontSize(18).margin({ left: 4 })
          } else if (venue.isLibrary) {
            SymbolGlyph($r('sys.symbol.book')).fontColor(['#67C23A']).fontSize(18).margin({ left: 4 })
          }
        }

        Text(venue.description)
          .fontSize(13)
          .fontColor('#666')
          .margin({ top: 6 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

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

        Row({ space: 12 }) {
          if (venue.officialUrl) {
            Button('官网预约')
              .layoutWeight(1)
              .height(36)
              .fontSize(14)
              .backgroundColor('#007DFF')
              .onClick(() => {
                router.pushUrl({
                  url: 'services/VenueWebView',
                  params: { venue: venue }
                })
              })
          }

          if (venue.wechatName) {
            Button('小程序')
              .layoutWeight(1)
              .height(36)
              .fontSize(14)
              .fontColor('#07C160')
              .backgroundColor('#E8F7ED')
              .onClick(() => {
                this.copyToClipboard(venue.wechatName as string);
              })
          }

          if (!venue.needBooking) {
            Text('无需预约')
              .fontSize(13)
              .fontColor('#27AE60')
              .fontWeight(FontWeight.Medium)
          }
        }
        .margin({ top: 15 })
        .width('100%')
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
}