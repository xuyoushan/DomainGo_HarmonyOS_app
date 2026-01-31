import { router } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { textToSpeech } from '@kit.CoreSpeechKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
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

interface CityStyle {
  theme: string;
  accent: string;
  file: string;
}

const CITY_STYLES: Record<string, CityStyle> = {
  "北京": { theme: "#FDF6E3", accent: "#B58900", file: "beijing.md" },
  "天津": { theme: "#F5F7FA", accent: "#005BB7", file: "tianjin.md" },
  "上海": { theme: "#F2F2F2", accent: "#A52A2A", file: "shanghai.md" },
  "武汉": { theme: "#FDF5E6", accent: "#E64340", file: "wuhan.md" },
  "重庆": { theme: "#F0F0F0", accent: "#2F4F4F", file: "chongqing.md" },
  "成都": { theme: "#F7F9F2", accent: "#1B5E20", file: "chengdu.md" }
};

@Entry
@Component
struct DataDetailView {
  @State params: DetailParam | null = null;
  @State isPlaying: boolean = false;
  @State articleList: ArticleItem[] = [];
  @State themeColor: string = "#FDF6E3";
  @State accentColor: string = "#B58900";
  @State loadingStatus: string = "正在读取文章内容...";

  private ttsEngine?: textToSpeech.TextToSpeechEngine;
  @State currentSwiperIndex: number = 0;

  aboutToAppear() {
    this.params = router.getParams() as DetailParam;
    this.loadArticleContent();
    this.initTts();
  }

  aboutToDisappear() {
    if (this.ttsEngine) {
      this.ttsEngine.stop();
      this.ttsEngine.shutdown();
    }
  }

  initTts() {
    try {
      let initParamsInfo: textToSpeech.CreateEngineParams = {
        language: 'zh-CN',
        person: 0,
        online: 1,
        extraParams: { 'style': 'interaction' }
      };
      textToSpeech.createEngine(initParamsInfo, (err: BusinessError, engine: textToSpeech.TextToSpeechEngine) => {
        if (!err) {
          this.ttsEngine = engine;
          this.ttsEngine.setListener({
            onStart: () => { this.isPlaying = true; },
            onComplete: () => { this.isPlaying = false; },
            onStop: () => { this.isPlaying = false; },
            onError: () => { this.isPlaying = false; }
          });
        }
      });
    } catch (e) {
      console.error('TTS Init Failed', JSON.stringify(e));
    }
  }

  handleSpeech() {
    if (!this.ttsEngine) {
      promptAction.showToast({ message: '语音引擎初始化中...' });
      return;
    }
    if (this.isPlaying) {
      this.ttsEngine.stop();
    } else {
      const currentArticle = this.articleList[this.currentSwiperIndex];
      if (currentArticle) {
        let textToRead = `${currentArticle.title}。作者：${currentArticle.author}。${currentArticle.content}`;
        let speakParams: textToSpeech.SpeakParams = {
          requestId: Date.now().toString(),
          extraParams: { 'speed': 1.0, 'volume': 1.0, 'pitch': 1.0 }
        };
        this.ttsEngine.speak(textToRead, speakParams);
      }
    }
  }

  async loadArticleContent() {
    this.articleList = [];
    const cityName = this.params?.cityName || "";
    const context = getContext(this) as common.UIAbilityContext;

    const cityKey = Object.keys(CITY_STYLES).find(k => cityName.includes(k));
    const config = cityKey ? CITY_STYLES[cityKey] : null;

    if (config) {
      this.themeColor = config.theme;
      this.accentColor = config.accent;
      try {
        const uint8arr = await context.resourceManager.getRawFileContent(config.file);
        this.processRawText(uint8arr);
      } catch (e) {
        this.loadingStatus = `《${cityName}》内容正在整理中...`;
      }
    } else {
      this.loadingStatus = `正在进入${cityName}频道...`;
    }
  }

  processRawText(uint8arr: Uint8Array) {
    const textDecoder = util.TextDecoder.create('utf-8');
    const rawText: string = textDecoder.decodeWithStream(uint8arr);
    this.parseMarkdown(rawText);
  }

  parseMarkdown(allText: string) {
    const parts = allText.split(/##|第[一二]篇文章：/);
    const authors = ["郁达夫", "老舍", "冯骥才", "冯兴东", "茅盾", "王志纲", "池莉", "易中天", "朱自清", "丰子恺", "何其芳"];

    this.articleList = parts.filter(p => p.trim()).map((part): ArticleItem => {
      const lines = part.trim().split('\n');
      const title = lines[0].replace(/#/g, '').trim();
      const content = part.trim().substring(part.trim().indexOf('\n')).trim();
      const foundAuthor = authors.find(a => part.includes(a));

      return {
        title: title,
        author: foundAuthor || "名家散文",
        content: content
      };
    });
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
                  Stack({ alignContent: Alignment.TopStart }) {
                    // 大字底部显示
                    Text(item.content.charAt(0))
                      .fontSize(60)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.accentColor)
                      .margin({ top: -5 }) // 向上微调，视觉对齐

                    Text() {
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
        .onChange((index: number) => {
          this.currentSwiperIndex = index;
          if (this.isPlaying && this.ttsEngine) {
            this.ttsEngine.stop();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColor)
  }
}