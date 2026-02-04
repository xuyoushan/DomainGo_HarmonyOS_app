import { router, display } from '@kit.ArkUI';
import { CULTURE_SPECIALTY_MAP, SpecialtyItem } from '../../../models/CultureSpecialtyData';

@Entry
@Component
struct SpecialtyView {
  @State currentCity: string = '武汉市';
  @State scrollOffset: number = 0;
  @State columns: number = 1;
  @State foodData: SpecialtyItem[] = [];
  @State isShowPreview: boolean = false;
  @State previewImage: Resource | string = '';
  @State selectedIndex: number = -1;
  // 支持多项同时展开：存储展开项目的ID
  @State expandedIds: number[] = [];

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params.cityName) {
      this.currentCity = params.cityName;
    }

    if (CULTURE_SPECIALTY_MAP && CULTURE_SPECIALTY_MAP[this.currentCity]) {
      const list = CULTURE_SPECIALTY_MAP[this.currentCity].specialtyFoods;
      this.foodData = Array.isArray(list) ? list : [];
    } else {
      this.foodData = [];
    }

    this.updateColumns();
  }

  onPageShow() {
    this.updateColumns();
  }

  private updateColumns() {
    try {
      const displayClass = display.getDefaultDisplaySync();
      this.columns = displayClass.width > 2000 ? 2 : 1;
    } catch (e) {
      this.columns = 1;
    }
  }

  @Builder
  SpecialtyCard(item: SpecialtyItem, index: number) {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(item.image)
            .width(130)
            .height(180)
            .borderRadius(14)
            .objectFit(ImageFit.Cover)
            .shadow({ radius: 15, color: 'rgba(0,0,0,0.12)', offsetY: 8 })
            .geometryTransition(`sharedImage-${index}`)
            .onClick(() => {
              animateTo({ curve: Curve.Sharp, duration: 388 }, () => {
                this.previewImage = item.image;
                this.selectedIndex = index;
                this.isShowPreview = true;
              })
            })

          Text('地道风物')
            .fontSize(9)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#A0522D')
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .borderRadius({ topRight: 10, bottomLeft: 10 })
        }
        .margin({ right: 18 })

        Column() {
          Text(item.name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2C3E50')

          Text(item.price)
            .fontSize(15)
            .fontColor('#E67E22')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 4 })

          Text(item.highlight)
            .fontSize(14)
            .fontColor('#16A085')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 12 })
            .maxLines(2)
            .lineHeight(20)

          Blank()

          Row() {
            Text(this.expandedIds.includes(item.id) ? '收起详情' : '查看百科及建议')
              .fontSize(12)
              .fontColor('#95A5A6')
            SymbolGlyph(this.expandedIds.includes(item.id) ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_right'))
              .fontSize(12)
              .fontColor(['#95A5A6'])
              .margin({ left: 4 })
          }
          .onClick(() => {
            animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
              if (this.expandedIds.includes(item.id)) {
                this.expandedIds = this.expandedIds.filter(id => id !== item.id);
              } else {
                this.expandedIds.push(item.id);
              }
            })
          })
        }
        .layoutWeight(1)
        .height(180)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 百科展示区：移除闪现动画，调大字体
      if (this.expandedIds.includes(item.id)) {
        Column() {
          Column() {
            Row() {
              SymbolGlyph($r('sys.symbol.book')).fontSize(16).fontColor(['#2C3E50'])
              Text('产品百科').fontSize(14).fontWeight(FontWeight.Bold).margin({ left: 6 })
            }
            Text(item.desc)
              .fontSize(14)
              .lineHeight(22)
              .fontColor('#5D6D7E')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FDFEFE')
          .borderRadius(10)
          .margin({ top: 15 })

          Row() {
            SymbolGlyph($r('sys.symbol.lightbulb_fill')).fontSize(16).fontColor(['#D48806'])
            Column() {
              Text('选购建议').fontSize(13).fontWeight(FontWeight.Bold).fontColor('#855D10')
              Text(item.buyTip).fontSize(14).fontColor('#855D10').margin({ top: 4 }).lineHeight(20)
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 10 })
            .layoutWeight(1)
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FFFBE6')
          .borderRadius(10)
          .margin({ top: 12 })
          .border({ width: 0.5, color: '#FFE58F' })
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(18)
    .margin({ bottom: 4 })
    .border({
      width: this.expandedIds.includes(item.id) ? 2 : 0,
      color: '#E67E22'
    })
    .shadow({
      radius: this.expandedIds.includes(item.id) ? 30 : 24,
      color: this.expandedIds.includes(item.id) ? 'rgba(230,126,34,0.1)' : 'rgba(0,0,0,0.06)',
      offsetY: 6
    })
    .offset({ x: index % 2 === 0 ? 0 : 5 })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Text(this.currentCity.substring(0, 2))
          .fontSize(180)
          .fontWeight(FontWeight.Bolder)
          .fontColor('#E8E4E1')
          .opacity(0.6)
          .offset({ y: -this.scrollOffset * 0.2 })
      }
      .width('100%')
      .height(350)
      .backgroundColor('#F5F2F0')
      .alignItems(HorizontalAlign.End)

      Scroll() {
        Column() {
          Column() {
            Text('LOCAL FLAVOR')
              .fontSize(12)
              .letterSpacing(4)
              .fontColor('#A9A9A9')
              .margin({ top: 60 })

            Text(this.currentCity)
              .fontSize(42)
              .fontWeight(FontWeight.Bolder)
              .fontColor('#2C3E50')
              .margin({ top: 10 })

            Text('寻味地道风物')
              .fontSize(16)
              .fontColor('#7F8C8D')
              .margin({ top: 5 })

            Divider()
              .width(40)
              .strokeWidth(3)
              .color('#E67E22')
              .margin({ top: 15, bottom: 40 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column() {
            if (this.foodData.length > 0) {
              List({ space: 20 }) {
                ForEach(
                  this.foodData,
                  (item: SpecialtyItem, index: number) => {
                    ListItem() {
                      this.SpecialtyCard(item, index)
                    }.clip(false)
                  },
                  (item: SpecialtyItem, index: number) => `${item.name}-${index}`
                )
              }
              .lanes(this.columns)
              .width('100%')
              .edgeEffect(EdgeEffect.None)
              .scrollBar(BarState.Off)
              .clip(false)
              .nestedScroll({
                scrollForward: NestedScrollMode.PARENT_FIRST,
                scrollBackward: NestedScrollMode.PARENT_FIRST
              })
            } else {
              Column() {
                Text('我们正在为这座城市寻找最地道的风味').fontColor('#BDC3C7').fontSize(16).margin({ top: 100 })
              }.width('100%')
            }
          }
          .margin({ top: -10 })
          .padding({ bottom: 20 })

          Column() {
            Text('— 寻遍烟火人间 · 城市礼赞 —')
              .fontSize(14)
              .fontColor('#D5DBDB')
              .margin({ top: 50, bottom: 30 })
          }
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
      }
      .scrollBar(BarState.Off)
      .onWillScroll((x, y) => {
        this.scrollOffset = y;
      })

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .fontColor(this.scrollOffset > 50 ? [Color.Black] : ['#2C3E50'])
          .onClick(() => router.back())

        Blank()

        SymbolGlyph($r('sys.symbol.square_and_arrow_down'))
          .fontSize(22)
          .fontColor(this.scrollOffset > 50 ? ['#E67E22'] : ['#2C3E50'])
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor(this.scrollOffset > 50 ? 'rgba(255,255,255,0.95)' : Color.Transparent)
      .backgroundBlurStyle(this.scrollOffset > 50 ? BlurStyle.Thin : BlurStyle.NONE)
      .animation({ duration: 300 })

      if (this.isShowPreview) {
        Stack() {
          Rect().width('100%').height('100%').fill('rgba(0,0,0,0.9)')
            .opacity(this.isShowPreview ? 1 : 0)
            .animation({ duration: 200 })
            .onClick(() => {
              animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
                this.isShowPreview = false;
                this.selectedIndex = -1;
              })
            })

          Image(this.previewImage)
            .width('90%')
            .objectFit(ImageFit.Contain)
            .geometryTransition(`sharedImage-${this.selectedIndex}`)
            .onClick(() => {
              animateTo({ duration: 400, curve: Curve.FastOutSlowIn }, () => {
                this.isShowPreview = false;
                this.selectedIndex = -1;
              })
            })
        }
        .width('100%')
        .height('100%')
        .zIndex(99)
      }
    }
    .width('100%')
    .height('100%')
  }
}