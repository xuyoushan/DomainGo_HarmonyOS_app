import { router, promptAction } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';
import { CITY_VENUES_MAP, Venue } from '../../../models/VenueData';
import { EmptyComponent } from '../../../models/EmptyComponent'; // 导入空状态组件

// 解决 arkts-no-obj-literals-as-types 报错
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

  // 核心辅助方法：根据分类获取动态渐变色
  getVenueColor(category: string): string[] {
    switch (category) {
      case '文博馆': return ['#FF5E62', '#FF9966']; // 砖红系
      case '学术殿堂': return ['#4facfe', '#00f2fe']; // 蓝绿系
      case '科技馆': return ['#667eea', '#764ba2']; // 紫色系
      case '体育馆': return ['#11998e', '#38ef7d']; // 翠绿系
      case '其他': return ['#FAD961', '#F76B1C']; // ✅ 换成鲜艳的橙黄渐变
      default: return ['#606c88', '#3f4c6b']; // 沉稳灰
    }
  }

  // --- 功能2：分类聚合过滤逻辑 ---
  // --- 功能2：分类聚合过滤逻辑（修复版） ---
  getFilteredVenues(cat: string): Venue[] {
    const allVenues = CITY_VENUES_MAP[this.currentCity] || [];

    if (cat === '文博馆') {
      // 聚合：文博馆、博物馆、美术馆、纪念馆、故居
      return allVenues.filter(v => {
        const vCat = v.category as string; // 强制转为 string 避开联合类型检测
        return vCat === '文博馆' || vCat === '博物馆' || vCat === '美术馆' ||
        v.name.includes('纪念馆') || v.name.includes('故居');
      });
    }

    if (cat === '学术殿堂') {
      // 聚合：学术殿堂、大学、图书馆
      return allVenues.filter(v =>
      v.category === '学术殿堂' || v.isUniversity === true || v.isLibrary === true
      );
    }

    // 其他常规分类匹配
    return allVenues.filter(v => v.category === cat);
  }
  // 优化后的缩略名逻辑：去掉省市前缀，提取核心词
  // 优化后的提取逻辑
  getShortName(name: string): string {
    // 1. 7字以内（含7字）直接完整显示，不做任何裁剪
    if (name.length <= 7) {
      return name;
    }

    // 2. 超过7个字，先去掉括号内容（如大学的分校区标识）
    let short = name.replace(/（.*?）/g, '').replace(/\(.*?\)/g, '');

    // 3. 剔除极其冗余的省市行政前缀（只在超长时剔除）
    const areaPrefixes = ['湖北省', '武汉市', '北京市', '天津市'];
    areaPrefixes.forEach(p => {
      if (short.startsWith(p)) short = short.replace(p, '');
    });

    // 4. 后缀精简：如果去掉后缀后仍有3字以上，则去掉，否则保留
    const suffixes = ['博物馆', '美术馆', '纪念馆', '科技馆', '体育馆', '图书馆', '体育中心'];
    for (let s of suffixes) {
      if (short.endsWith(s) && short.length > s.length + 2) {
        short = short.replace(s, '');
      }
    }

    // 5. 兜底逻辑：如果裁完还是太长（比如8字以上），保留前6个字
    return short.length > 7 ? short.substring(0, 6) : short;
  }
  // --- 功能1：多维度搜索优化 ---
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

  // 1. 普通成员函数，返回显式定义的接口类型
  handleName(fullName: string): NameResult {
    // 查找括号位置
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
      // 1. 顶部导航
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).onClick(() => router.back())
        Text(`${this.currentCity} · 场馆指南`).fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 12 })
        Blank()
        // --- 功能4：右上角图标定义为“凭证快捷入口” ---
        SymbolGlyph($r('sys.symbol.qrcode')).fontSize(24).fontColor(['#007DFF'])
          .onClick(() => {
            router.pushUrl({
              url: 'pages/features/ScheduleView',
              params: { showEvidenceOnly: true } // 告诉日程页只看带凭证的
            })
          })      }.width('100%').padding(15).backgroundColor(Color.White)

      // 2. 搜索框
      Search({ placeholder: '搜索名称、大学或图书馆...', value: this.searchText })
        .margin({ left: 16, right: 16, bottom: 10 })
        .onChange(v => this.searchText = v)

      if (this.searchText.trim() !== '') {
        // --- 搜索模式 ---
        if (this.getSearchVenues().length > 0) {
          List({ space: 16 }) {
            ForEach(this.getSearchVenues(), (venue: Venue) => {
              ListItem() { this.VenueCard(venue) }
            }, (item: Venue) => item.id)
          }
          .layoutWeight(1)
          .padding({ bottom: 20 })
        } else {
          // --- 功能4：搜索无结果时使用空状态组件 ---
          EmptyComponent({
            title: '未找到相关场馆',
            subTitle: `尝试搜索其他关键词，例如“大学”或“博物馆”`,
            imageRes: $r('sys.symbol.magnifyingglass')
          })
        }
      } else {
        // --- 分类模式 ---
        Tabs({ barPosition: BarPosition.Start }) {
          ForEach(this.categories, (cat: string) => {
            TabContent() {
              this.CategoryList(cat)
            }.tabBar(cat)
          })
        }
        .barMode(BarMode.Scrollable) // ✅ 改为可滚动模式
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
      // --- 功能4：分类为空时使用你上传的 EmptyComponent ---
      EmptyComponent({
        title: `暂无${cat}数据`,
        subTitle: `我们正在努力收录${this.currentCity}的${cat}信息，请耐心等待。`,
        imageRes: cat === '学术殿堂' ? $r('sys.symbol.book_badge_play') : $r('sys.symbol.exclamationmark_and_minus_plus_batteryblock_stack')
      })
    }
  }
  // 自定义 Tab 样式，增加间距防止拥挤
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



  // 2. 修改 Builder，将样式直接写在内部组件上
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
      // --- 功能3：顶部图片/动态渐变封面 ---
      Stack({ alignContent: Alignment.TopStart }) {
        if (venue.image) {
          Image(venue.image)
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: 12, topRight: 12 })
        } else {
          // 动态渐变封面逻辑
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

      // --- 内容描述区 ---
      Column() {
        Row() {
          Text(venue.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .layoutWeight(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 学术殿堂专属徽章
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

        // --- 底部交互按钮区 ---
        Row({ space: 12 }) {
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