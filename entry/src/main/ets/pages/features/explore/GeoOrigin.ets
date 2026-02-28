import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { GEO_ORIGIN_DATA, CityStory, DistrictStory } from '../../../models/DistrictStoryData';

interface GLMMessage {
  role: string;
  content: string;
}

interface GLMChoice {
  message: GLMMessage;
}

interface GLMChatResponse {
  choices: GLMChoice[];
}

interface AIChatItem {
  role: 'user' | 'assistant'
  content: string
  display?: string
}


@Entry
@Component
struct GeoOriginNewView {
  @StorageLink('currentCity') currentCity: string = '武汉';
  @State selectedDistrict: DistrictStory | null = null;
  @State isShowDetail: boolean = false;

  @State aiChats: AIChatItem[] = []
  @State showAI: boolean = false;
  @State aiQuery: string = '';
  @State aiLoading: boolean = false;

  private bgDeep = '#3A352F';
  private accentAmber = '#C9A25D';
  private cardBg = 'rgba(255,255,255,0.05)';
  private dividerDark = 'rgba(255,255,255,0.12)';
  private paperBg = '#24211C';

  private getCityData(): CityStory {
    return GEO_ORIGIN_DATA[this.currentCity] || {
      cityName: this.currentCity,
      summary: '正在调取该城市的地名编年档案...',
      districts: []
    };
  }

  private GLM_MODEL = 'glm-4-flash';
  private aiScroller: Scroller = new Scroller();

  private buildArchivePrompt(userQuestion: string): string {
    const city = this.currentCity;
    const district = this.selectedDistrict?.name ?? '';

    return `你是一位中国历史地名与地方志研究专家。【研究背景】城市：${city}，地名：${district || '未指定'}。【回答要求】1. 使用正式、克制、偏史料的语气 2. 优先从历史沿革、名称来源、行政变迁角度解释 3. 如存在多种说法，请说明“其一 / 其二” 4. 不要使用口语，不要编造具体年代 5. 字数控制在 200 字以内。【用户问题】${userQuestion}`;
  }

  private async callAI(question: string) {
    if (!question) return;

    const userContent = this.buildArchivePrompt(question);

    this.aiChats.push({
      role: 'user',
      content: userContent,
      display: question
    });

    this.aiLoading = true;
    this.aiQuery = '';

    this.scrollToBottom();

    let httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(
        'http://localhost:3000/api/chat', // 模拟机
        // 'http://192.168.10.105:3000/api/chat' //真机
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            messages: [
              {
                role: 'system',
                content: `你是一位中国历史地名与地方志研究专家。城市：${this.currentCity}，地名：${this.selectedDistrict?.name ?? '未指定'}。请严格遵循正式史料语气。`
              },
              ...this.aiChats.slice(-6).map(item => ({
                role: item.role,
                content: item.content
              } as GLMMessage))
            ],
            temperature: 0.3
          },
          expectDataType: http.HttpDataType.OBJECT,
          connectTimeout: 15000,
          readTimeout: 15000
        }
      );

      if (response.responseCode === 200) {
        const result = response.result as GLMChatResponse;
        const answer = result.choices?.[0]?.message?.content ?? 'AI 未返回有效内容';

        this.aiChats.push({
          role: 'assistant',
          content: answer
        });
        this.scrollToBottom();
      } else {
        this.aiChats.push({
          role: 'assistant',
          content: `请求失败（状态码 ${response.responseCode}）`
        })
      }
    } catch (err) {
      const error = err as BusinessError;
      this.aiChats.push({
        role: 'assistant',
        content: `连接失败：${error.message}`
      })
    } finally {
      httpRequest.destroy();
      this.aiLoading = false;
    }
  }

  private scrollToBottom() {
    setTimeout(() => {
      this.aiScroller.scrollEdge(Edge.Bottom);
    }, 150);
  }

  build() {
    Stack() {
      Stack() {
        Circle().width(420).height(420).fill('#6B6459').blur(140).position({ x: -120, y: -80 })
        Circle().width(360).height(360).fill('#8A7A5E').blur(120).position({ x: '55%', y: '35%' })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.bgDeep)

      Column() {
        this.ModernNav()

        Scroll() {
          Column() {
            this.CityHeroHeader()
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.getCityData().districts, (item: DistrictStory, index: number) => {
                this.ArtisticCard(item, index)
              })
            }.padding({ left: 16, right: 16, top: 30, bottom: 40 })
          }.width('100%')
        }.layoutWeight(1).edgeEffect(EdgeEffect.Spring)
      }
      .opacity(this.isShowDetail || this.showAI ? 0.35 : 1)
      .scale(this.isShowDetail || this.showAI ? { x: 0.98, y: 0.98 } : { x: 1, y: 1 })

      if (this.isShowDetail && this.selectedDistrict) this.SmartDetailOverlay()

      if (this.showAI) {
        Stack({ alignContent: Alignment.Bottom }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.45)')
            .onClick(() => {
              animateTo(
                { duration: 260, curve: Curve.EaseIn },
                () => this.showAI = false
              )
            })

          this.AIPanel()
        }
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder ModernNav() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(24)
        .fontColor(['rgba(255,255,255,0.9)'])
        .onClick(() => router.back())

      Blank()

      Text('AI ARCHIVE')
        .fontSize(10)
        .fontColor(this.accentAmber)
        .fontWeight(FontWeight.Bold)
        .letterSpacing(1)
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .borderRadius(20)
        .border({ width: 1, color: 'rgba(201,162,93,0.6)' })
        .onClick(() => {
          animateTo(
            { duration: 360, curve: Curve.EaseOut },
            () => {
              this.showAI = true;
              this.aiQuery = '';
            }
          )
        })
    }.width('100%').padding({ left: 20, right: 20, top: 40, bottom: 10 })
  }

  @Builder
  AIPanel() {
    Column() {
      Row() {
        Text('AI 地名档案')
          .fontSize(18)
          .fontWeight(FontWeight.Bolder)
          .fontColor(this.accentAmber)
        Blank()
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(20)
          .fontColor([this.accentAmber])
          .onClick(() => {
            animateTo(
              { duration: 260, curve: Curve.EaseIn },
              () => this.showAI = false
            )
          })
      }
      .padding(16)
      .backgroundColor(this.paperBg)
      .borderRadius({ topLeft: 18, topRight: 18 })

      Scroll(this.aiScroller) {
        Column({ space: 14 }) {
          ForEach(this.aiChats, (item: AIChatItem) => {
            Row() {
              if (item.role === 'assistant') {
                Column() {
                  Text(item.content)
                    .fontSize(15)
                    .lineHeight(26)
                    .fontColor('rgba(255,255,255,0.88)')
                }
                .padding(14)
                .backgroundColor('rgba(255,255,255,0.08)')
                .borderRadius(14)
              } else {
                Blank()
                Column() {
                  Text(item.display ?? item.content)
                    .fontSize(15)
                    .lineHeight(24)
                    .fontColor(this.bgDeep)
                }
                .padding(14)
                .backgroundColor(this.accentAmber)
                .borderRadius(14)
              }
            }.width('100%')
          })

          if (this.aiLoading) {
            Row({ space: 8 }) {
              LoadingProgress().width(24).height(24).color(this.accentAmber)
              Text('正在查阅地方志…')
                .fontSize(13)
                .fontColor(this.accentAmber)
                .opacity(0.8)
            }.margin({ top: 10 })
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor(this.paperBg)

      Row({ space: 10 }) {
        TextInput({ text: this.aiQuery, placeholder: '询问地名沿革…' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor('rgba(255,255,255,0.12)')
          .fontColor(Color.White)
          .placeholderColor('rgba(255,255,255,0.35)')
          .enterKeyType(EnterKeyType.Send)
          .onChange(v => this.aiQuery = v)
          .onSubmit(() => {
            if (this.aiQuery.trim()) this.callAI(this.aiQuery.trim());
          })

        Button('发送')
          .height(44)
          .backgroundColor(this.accentAmber)
          .fontColor(this.bgDeep)
          .onClick(() => {
            if (this.aiQuery.trim()) this.callAI(this.aiQuery.trim());
          })
      }
      .padding({ left: 16, right: 16, bottom: 26, top: 10 })
      .backgroundColor(this.paperBg)
    }
    .width('100%')
    .height('65%')
    .alignSelf(ItemAlign.End)
    .transition(TransitionEffect.move(TransitionEdge.BOTTOM))
    .shadow({ radius: 32, color: 'rgba(0,0,0,0.45)' })
  }


  @Builder
  CityHeroHeader() {
    Column() {
      Row() {
        Rect({ width: 3, height: 48 })
          .fill(this.accentAmber)
          .margin({ right: 16 })

        Column() {
          Text(this.getCityData().cityName)
            .fontSize(56)
            .fontWeight(FontWeight.Bolder)
            .fontColor('rgba(255,255,255,0.95)')
            .letterSpacing(2)

          Text('数字化地名溯源')
            .fontSize(12)
            .fontColor(this.accentAmber)
            .letterSpacing(4)
        }
        .alignItems(HorizontalAlign.Start)
      }

      Text(this.getCityData().summary)
        .fontSize(15)
        .fontColor('rgba(255,255,255,0.8)')
        .lineHeight(26)
        .margin({ top: 30 })
        .width('90%')
        .textAlign(TextAlign.JUSTIFY)
    }
    .padding({ left: 24, top: 30, right: 24 })
  }

  @Builder
  ArtisticCard(item: DistrictStory, index: number) {
    Column({ space: 14 }) {
      Text(`地名条目 ${index + 1}`)
        .fontSize(11)
        .fontColor('rgba(255,255,255,0.35)')
        .letterSpacing(2)

      Text(item.name)
        .fontSize(index % 3 == 0 ? 34 : 28)
        .fontWeight(FontWeight.Bolder)
        .fontColor('rgba(255,255,255,0.92)')
        .letterSpacing(2)
        .maxLines(2)

      Text(item.slogan)
        .fontSize(14)
        .fontColor(this.accentAmber)
        .lineHeight(22)
        .maxLines(2)
        .margin({ top: 4 })

      Blank()

      Rect()
        .width(40)
        .height(1)
        .fill('rgba(255,255,255,0.18)')
    }
    .width(index % 3 == 0 ? '100%' : '48%')
    .height(index % 3 == 0 ? 200 : 220)
    .padding(24)
    .margin({ bottom: 18 })
    .backgroundColor(this.cardBg)
    .borderRadius(22)
    .scale({ x: 0.96, y: 0.96 })
    .opacity(0.98)
    .border({ width: 1, color: this.dividerDark })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      this.selectedDistrict = item;
      this.aiChats.push({
        role: 'assistant',
        content: `已进入【${item.name}】地名档案，可继续询问其沿革。`
      });

      animateTo(
        { duration: 380, curve: Curve.EaseOut },
        () => {
          this.isShowDetail = true
        }
      );
    })
  }

  @Builder
  SmartDetailOverlay() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(30,26,20,0.75)')
        .onClick(() => {
          animateTo(
            { duration: 260, curve: Curve.EaseIn },
            () => {
              this.isShowDetail = false
            }
          )
        })

      Column() {
        Rect()
          .width(60)
          .height(4)
          .fill('rgba(0,0,0,0.25)')
          .borderRadius(2)
          .margin({ top: 12, bottom: 24 })

        Scroll() {
          Column({ space: 30 }) {
            Column({ space: 12 }) {
              Text(this.selectedDistrict?.name)
                .fontSize(42)
                .fontWeight(FontWeight.Bolder)
                .fontColor('rgba(255,255,255,0.95)')
                .letterSpacing(3)

              Text('地名沿革记载')
                .fontSize(13)
                .fontColor(this.accentAmber)
                .letterSpacing(4)

              Rect()
                .width(80)
                .height(1)
                .fill(this.accentAmber)
            }

            Text(
              `${this.selectedDistrict?.origin ?? ''}\n\n${this.selectedDistrict?.history ?? ''}`
            )
              .fontSize(16)
              .fontColor('rgba(255,255,255,0.75)')
              .lineHeight(30)
              .letterSpacing(1)

            Text('—— 摘录自地方志与历史文献')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.35)')
              .margin({ top: 20 })
          }
          .padding({ left: 26, right: 26, bottom: 40 })
        }
      }
      .width('100%')
      .height('78%')
      .backgroundColor(this.paperBg)
      .borderRadius({ topLeft: 28, topRight: 28 })
    }
  }

  @Builder
  DetailSection(title: string, content: string | undefined) {
    Column({ space: 16 }) {
      Row({ space: 8 }) {
        Circle({ width: 6, height: 6 })
          .fill(this.accentAmber)

        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B261F')
          .letterSpacing(1)
      }

      Text(content)
        .lineHeight(30)
        .fontSize(16)
        .fontColor('#3A342C')
        .textAlign(TextAlign.JUSTIFY)
    }
    .alignItems(HorizontalAlign.Start)
  }
}
