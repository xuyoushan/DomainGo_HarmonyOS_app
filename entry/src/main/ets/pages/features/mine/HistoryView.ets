import router from '@ohos.router';
import { PostItem } from '../../../models/PostItem';
import { PreferenceManager } from '../../../services/PreferenceManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct HistoryView {
  @StorageLink('browseHistory') history: PostItem[] = [];

  async aboutToAppear() {
    if (this.history.length === 0) {
      const context = getContext(this) as common.UIAbilityContext;
      const savedHistory = await PreferenceManager.get(context, 'browseHistory', '[]');
      try {
        const parsed = JSON.parse(savedHistory as string) as PostItem[];
        this.history = parsed;
        AppStorage.setOrCreate('browseHistory', parsed);
      } catch (e) {
        console.error('HistoryView recovery error:', e);
      }
    }
  }

  private async syncToDisk(data: PostItem[]) {
    const context = getContext(this) as common.UIAbilityContext;
    await PreferenceManager.put(context, 'browseHistory', JSON.stringify(data));
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // --- 背景层：MineView 同款蓝色圆环 ---
      Circle()
        .width(400)
        .height(400)
        .fill('#1A007DFF') // 10% 不透明度的蓝色
        .offset({ x: -150, y: -100 }) // 位置稍微下移，避开导航栏

      Column() {
        // --- 导航栏 ---
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .onClick(() => router.back())

          Text('浏览历史')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
            .fontColor('#1A1A1A')

          Blank()

          // 更显眼的清空按钮
          Text('清空')
            .fontSize(13)
            .fontColor(Color.White)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#FF4D4F') // 红色背景
            .borderRadius(15)
            .onClick(async () => {
              this.history = [];
              AppStorage.setOrCreate('browseHistory', []);
              await this.syncToDisk([]);
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.Transparent) // 导航栏透明，透出背景

        if (this.history.length === 0) {
          Column() {
            SymbolGlyph($r('sys.symbol.adjustment_slash'))
              .fontSize(60)
              .fontColor(['#D1D1D1'])
            Text('暂无浏览记录')
              .fontSize(16)
              .fontColor('#BBBBBB')
              .margin({ top: 16 })
          }
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
        } else {
          List({ space: 14 }) { // 增大间距，方便看到背景圆环
            ForEach(this.history, (item: PostItem) => {
              ListItem() {
                Row() {
                  // --- 修正1：显示圆形头像 ---
                  Image(item.avatar || $r('app.media.start'))
                    .width(56)
                    .height(56)
                    .borderRadius(28)
                    .border({ width: 2, color: '#FFFFFF' })
                    .objectFit(ImageFit.Cover)

                  Column() {
                    // --- 修正2：名字黑色加粗 ---
                    Text(item.userName)
                      .fontSize(17)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#1A1A1A')

                    Text(item.text)
                      .fontSize(14)
                      .fontColor('#888888')
                      .margin({ top: 8 })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .layoutWeight(1)
                  .margin({ left: 16 })
                  .alignItems(HorizontalAlign.Start)

                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(14)
                    .fontColor(['#BBBBBB'])
                }
                .padding(16)
                // 背景白色半透明，能隐约透出后面的蓝色圆环
                .backgroundColor('rgba(255, 255, 255, 0.85)')
                .backgroundBlurStyle(BlurStyle.Thin)
                .borderRadius(20)
                .width('100%')
                .shadow({ radius: 10, color: '#0A000000', offsetY: 4 })
              }
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/circle/PostDetailView',
                  params: { postData: item }
                })
              })
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, bottom: 20 })
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor('#F7F8FA')
  }
}