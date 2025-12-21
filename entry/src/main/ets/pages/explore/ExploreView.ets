@Component
export struct ExploreView {
  // 定义模拟数据数组，明确指定为 number 类型，解决 ForEach 报错
  private recommendList: number[] = [1, 2, 3, 4];

  build() {
    Column() {
      // 1. 顶部搜索区域
      Row() {
        Search({ placeholder: '搜索地名、行政区划...' })
          .width('90%')
          .height(40)
          .backgroundColor('#FFFFFF')
          .margin({ top: 12, bottom: 12 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          // 2. 地名百科卡片
          Column() {
            Row() {
              Text('成都市 · 锦江区')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Blank()
              Text('行政代码: 510104')
                .fontSize(12)
                .fontColor('#E0E0E0')
            }
            .width('100%')
            .margin({ bottom: 12 })

            Text('【历史沿革】锦江区因著名的锦江流经境内而得名。自古以来，这里便是蜀地的商业繁华中心...')
              .fontSize(14)
              .fontColor('#F5F5F5')
              .lineHeight(20)
              .maxLines(3)

            Divider().color('#40FFFFFF').margin({ top: 12, bottom: 12 })

            Row() {
              this.StatItem('人口', '63.5万')
              this.StatItem('面积', '62.1k㎡')
              this.StatItem('海拔', '500m')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
          }
          .width('94%')
          .padding(20)
          .borderRadius(16)
          .backgroundColor('#007DFF')
          .shadow({ radius: 20, color: '#30007DFF', offsetY: 10 })

          // 3. 热门推荐标题
          Row() {
            Text('附近推荐')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Blank()
            Text('查看更多 >').fontSize(12).fontColor('#666666')
          }
          .width('94%')

          // 4. 瀑布流/列表
          Grid() {
            // 关键修正：给 item 指定明确的类型 number
            ForEach(this.recommendList, (item: number) => {
              GridItem() {
                Column() {
                  // 使用系统默认图标占位，防止图片路径失效
                  Image($r('sys.media.ohos_app_icon'))
                    .width('100%')
                    .height(120)
                    .borderRadius(12)
                    .backgroundColor('#E0E0E0')
                    .objectFit(ImageFit.Contain)
                  Text('景点名称 ' + item.toString())
                    .margin({ top: 8 })
                    .fontSize(14)
                }
                .alignItems(HorizontalAlign.Start)
              }
            }, (item: number) => item.toString()) // 增加 KeyGenerator 提高性能
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .width('94%')
          .padding({ bottom: 20 })
        }
        .width('100%')
      }
      .layoutWeight(1) // 让 Scroll 占据剩余空间
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  @Builder
  StatItem(label: string, value: string) {
    Column() {
      Text(value).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      Text(label).fontSize(12).fontColor('#E0E0E0').margin({ top: 4 })
    }
  }
}