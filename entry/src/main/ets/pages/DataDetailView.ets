// entry/src/main/ets/pages/DataDetailView.ets
import { router } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import type common from '@ohos.app.ability.common';

interface DetailParam {
  title: string;
  cityName: string;
  color: string;
  icon: Resource;
}

interface ArticleItem {
  title: string;
  author: string;
  content: string;
}

@Entry
@Component
struct DataDetailView {
  @State params: DetailParam | null = null;
  @State isPlaying: boolean = false;
  @State articleList: ArticleItem[] = [];
  @State themeColor: string = "#FDF6E3";
  @State accentColor: string = "#B58900";
  @State loadingStatus: string = "正在读取文章内容...";

  aboutToAppear() {
    this.params = router.getParams() as DetailParam;
    this.loadArticleContent();
  }

  async loadArticleContent() {
    this.articleList = [];
    // 1. 获取当前定位传过来的城市名
    const cityName = this.params?.cityName || "";
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

    try {
      // 2. 定位逻辑拦截：只有包含“北京”字样才去加载 beijing.md
      if (cityName.includes("北京")) {
        this.themeColor = "#FDF6E3";
        this.accentColor = "#B58900";

        // 只有在这里才真正读取文件
        const uint8arr: Uint8Array = await context.resourceManager.getRawFileContent("beijing.md");
        const textDecoder = util.TextDecoder.create('utf-8');
        const rawText: string = textDecoder.decodeWithStream(uint8arr);
        this.parseMarkdown(rawText);

      } else {
        // 3. 【重点】如果是武汉或其他城市，确保 articleList 为空，并设置 loading 提示
        this.articleList = [];
        this.loadingStatus = `正在进入${cityName}城市印象频道...`;
        // 不执行解析，直接结束，这样 build 里的 if 就会显示 loading 界面
      }
    } catch (e) {
      this.articleList = [];
      this.loadingStatus = `《${cityName}》内容正在整理中...`;
    }
  }

  parseMarkdown(allText: string) {
    // 兼容你新修改的 ## 格式或原来的第X篇文章格式
    const parts = allText.split(/##|第[一二]篇文章：/);
    let tempArray: ArticleItem[] = [];

    parts.forEach(part => {
      const trimmed = part.trim();
      if (trimmed.length > 0) {
        const lines = trimmed.split('\n');
        const title = lines[0].replace(/#/g, '').trim();
        let author = "名家散文";
        if (trimmed.includes("郁达夫")) author = "郁达夫";
        if (trimmed.includes("老舍")) author = "老舍";
        const content = trimmed.substring(trimmed.indexOf('\n')).trim();

        tempArray.push({ title: title, author: author, content: content });
      }
    });
    this.articleList = tempArray;
  }

  handleSpeech() {
    this.isPlaying = !this.isPlaying;
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Stack() {
          Circle({ width: 36, height: 36 }).fill('#1A000000')
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(22)
            .fontColor(['#333333'])
        }
        .onClick(() => router.back())

        Text(this.params?.cityName || "城市印象")
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })

        Blank()

        Row() {
          SymbolGlyph(this.isPlaying ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'))
            .fontSize(20)
            .fontColor([this.accentColor])
          Text(this.isPlaying ? ' 停止' : ' 朗读')
            .fontSize(14)
            .fontColor(this.accentColor)
            .margin({ left: 4 })
        }
        .padding({ left: 15, right: 15, top: 8, bottom: 8 })
        .borderRadius(25)
        .backgroundColor('#1A000000')
        .onClick(() => this.handleSpeech())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 45, bottom: 15 })
      .backgroundColor(this.themeColor)

      // --- 定位逻辑判断显示 ---
      if (this.articleList.length === 0) {
        Column({ space: 20 }) {
          LoadingProgress().width(40).color('#999')
          Text(this.loadingStatus)
            .fontColor('#999')
            .fontSize(16)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .width('100%')
      } else {
        Swiper() {
          ForEach(this.articleList, (item: ArticleItem) => {
            Scroll() {
              Column() {
                Text(item.title)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bolder)
                  .margin({ top: 20 })

                Text(`${item.author} | 城市印象`)
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 10, bottom: 35 })

                if (item.content.length > 0) {
                  // --- 解决首字遮挡方案：使用相对定位避让 ---
                  Stack({ alignContent: Alignment.TopStart }) {
                    // 大字底部显示
                    Text(item.content.charAt(0))
                      .fontSize(60)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.accentColor)
                      .margin({ top: -5 }) // 向上微调，视觉对齐

                    Text() {
                      // 这里的空Span配合文字首行缩进，彻底解决重叠
                      Span('                 \n          ')
                      Span(item.content.substring(1))
                        .fontSize(19)
                        .lineHeight(38)
                        .fontColor('#2C2C2C')
                    }
                   .textAlign(TextAlign.JUSTIFY)
                  }
                }
                Divider().color('#1A000000').margin({ top: 50, bottom: 50 })
              }
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 25, right: 25 })
            }
          })
        }
        .loop(false)
        .indicator(true)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColor)
  }
}