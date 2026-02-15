import { ChatGLMService, ChatMessage } from '../../services/ChatGLMService';
import { promptAction, router } from '@kit.ArkUI';

@Component
export struct AIChatSheet {
  @StorageLink('currentWeatherText') weatherText: string = ''
  @StorageLink('currentTemperature') curTemp: string = '';

  @Prop currentCity: string;
  @Link isChatOpen: boolean;

  @State chatMessages: ChatMessage[] = [];
  @State userChatInput: string = '';
  @State isWaitingAI: boolean = false;
  private scroller: Scroller = new Scroller();

  async sendToAI(query: string) {
    if (this.isWaitingAI || !query.trim()) return;
    this.isWaitingAI = true;
    this.chatMessages = [...ChatGLMService.getHistory(), { role: 'user', content: query } as ChatMessage];
    setTimeout(() => { this.scroller.scrollEdge(Edge.Bottom) }, 50);

    const weatherCombined = `${this.weatherText}, 气温${this.curTemp}度`;
    const reply = await ChatGLMService.getAdventureAdvice(
      this.currentCity,
      weatherCombined,
      query
    );
    console.info('AI Response: ' + reply);
    this.chatMessages = [...ChatGLMService.getHistory()];
    this.isWaitingAI = false;
    setTimeout(() => { this.scroller.scrollEdge(Edge.Bottom) }, 100);
  }

  aboutToAppear() {
    const history = ChatGLMService.getHistory();
    if (history.length > 0) {
      this.chatMessages = [...history];
    } else {
      this.chatMessages = [];
    }
  }

  private handleSendMessage() {
    const isUserLoggedIn = AppStorage.get<boolean>('isLoggedIn') || false;
    if (!isUserLoggedIn) {
      promptAction.showToast({ message: '寻域 AI 仅对登录探险家开放，请先登录' });
      setTimeout(() => {
        router.pushUrl({ url: 'pages/mine/RegisterView' });
      }, 800);
      return;
    }

    if (!this.userChatInput.trim()) return;
    const q = this.userChatInput;
    this.userChatInput = '';
    this.sendToAI(q);
  }

  build() {
    Column() {
      Row()
      Column() {
        Column() {
          Row() {
            Row() {
              SymbolGlyph($r('sys.symbol.info_circle_fill')).fontSize(18).fontColor(['#6C5CE7'])
              Text(' 寻域助手 · 深度探索').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333')
            }

            Blank()

            Button() {
              Row({ space: 4 }) {
                SymbolGlyph($r('sys.symbol.arrow_clockwise')).fontSize(14).fontColor(['#6C5CE7'])
                Text('新对话').fontSize(13).fontColor('#6C5CE7').fontWeight(FontWeight.Medium)
              }
            }
            .backgroundColor('#E8E7FF')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(12)
            .onClick(() => {
              ChatGLMService.clearHistory();
              this.chatMessages = [];
              promptAction.showToast({ message: '记忆已重置，开始新对话' });
            })
          }
          .width('100%')
          .margin({ bottom: 10 })

          Text(`我可以为你解读${this.currentCity}的历史烟云、寻访地道风味或定制私人游踪。在这座城市，让我们一起去发现不为人知的角落。`)
            .fontSize(14).fontColor('#666').lineHeight(22)
        }
        .margin({ left: 15, right: 15, top: 15, bottom: 5 })
        .padding(18).backgroundColor('#F0F2F5').borderRadius(16)
        .border({ width: 1, color: '#E4E7ED' })

        List({ scroller: this.scroller }) {
          ForEach(this.chatMessages, (msg: ChatMessage) => {
            if (msg.role !== 'system') {
              ListItem() {
                Row() {
                  if (msg.role === 'assistant') {
                    Column() {
                      SymbolGlyph($r('sys.symbol.AI')).fontSize(22).fontColor([Color.White])
                    }
                    .width(42).height(42).borderRadius(21)
                    .linearGradient({ angle: 135, colors: [['#6C5CE7', 0], ['#8E44AD', 1]] })
                    .justifyContent(FlexAlign.Center).margin({ right: 12 })
                    .shadow({ radius: 8, color: 'rgba(108, 92, 231, 0.3)', offsetY: 4 })
                  } else {
                    Blank().layoutWeight(1)
                  }

                  Column() {
                    Text(msg.content)
                      .fontSize(15).lineHeight(24)
                      .fontColor(msg.role === 'user' ? Color.White : '#2C3E50')
                      .padding(14)
                      .backgroundColor(msg.role === 'user' ? '' : '#FFFFFF')
                      .linearGradient(msg.role === 'user' ? {
                        angle: 270,
                        colors: [['#6C5CE7', 0], ['#A29BFE', 1]]
                      } : undefined)
                      .borderRadius(msg.role === 'user' ?
                        { topLeft: 20, bottomLeft: 20, bottomRight: 4, topRight: 20 } :
                        { topRight: 20, bottomRight: 20, bottomLeft: 4, topLeft: 20 })
                      .shadow({
                        radius: 12,
                        color: msg.role === 'user' ? 'rgba(108, 92, 231, 0.2)' : 'rgba(0,0,0,0.06)',
                        offsetY: 6
                      })
                  }.constraintSize({ maxWidth: '78%' })

                  if (msg.role === 'user') {
                    Column() {
                      Image($r('app.media.start'))
                        .width(42).height(42).borderRadius(21)
                        .objectFit(ImageFit.Cover)
                    }
                    .width(42).height(42).borderRadius(21).backgroundColor('#E8EBF0')
                    .justifyContent(FlexAlign.Center).margin({ left: 12 })
                    .shadow({ radius: 6, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
                  } else {
                    Blank().layoutWeight(1)
                  }
                }
                .width('100%').alignItems(VerticalAlign.Top).margin({ bottom: 22 })
              }
            }
          }, (item: ChatMessage) => item.content + Math.random())

          if (this.isWaitingAI) {
            ListItem() {
              Row({ space: 6 }) {
                LoadingProgress().width(18).height(18).color('#6C5CE7')
                Text('寻域助手正在深度推理...').fontSize(12).fontColor('#999')
              }.margin({ left: 54, top: 10 })
            }
          }
        }
        .layoutWeight(1).padding({ left: 15, right: 15, bottom: 10 }).edgeEffect(EdgeEffect.Spring)

        Row({ space: 12 }) {
          TextInput({ text: this.userChatInput, placeholder: '唤醒城市的记忆...' })
            .layoutWeight(1).height(48).backgroundColor('#F5F7FA').borderRadius(24).padding({ left: 20 })
            .onChange((v) => this.userChatInput = v)
            .onSubmit(() => this.handleSendMessage())

          Button() {
            SymbolGlyph($r('sys.symbol.paperplane_fill')).fontSize(22).fontColor([Color.White])
          }
          .backgroundColor('#6C5CE7').width(48).height(48).borderRadius(24)
          .shadow({ radius: 8, color: 'rgba(108, 92, 231, 0.4)', offsetY: 4 })
          .onClick(() => this.handleSendMessage())
        }
        .padding({ left: 15, right: 15, top: 12, bottom: 25 })
        .backgroundColor(Color.White).borderRadius({ topLeft: 24, topRight: 24 })
        .shadow({ radius: 15, color: 'rgba(0,0,0,0.05)', offsetY: -5 })
      }
      .layoutWeight(1)
      .backgroundColor('#F8F9FB')
      .borderRadius({ topLeft: 28, topRight: 28 })
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.1)', offsetY: -10 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder AIAvatar() {
    Column() {
      SymbolGlyph($r('sys.symbol.AI')).fontSize(22).fontColor([Color.White])
    }
    .width(42).height(42).borderRadius(21)
    .linearGradient({ angle: 135, colors: [['#6C5CE7', 0], ['#8E44AD', 1]] })
    .justifyContent(FlexAlign.Center).margin({ right: 12 })
  }

  @Builder UserAvatar() {
    Column() {
      Image($r('app.media.start')).width(42).height(42).borderRadius(21).objectFit(ImageFit.Cover)
    }
    .width(42).height(42).borderRadius(21).backgroundColor('#E8EBF0')
    .justifyContent(FlexAlign.Center).margin({ left: 12 })
  }

  @Builder MessageBubble(msg: ChatMessage) {
    Column() {
      Text(msg.content)
        .fontSize(15).lineHeight(24)
        .fontColor(msg.role === 'user' ? Color.White : '#2C3E50')
        .padding(14)
        .backgroundColor(msg.role === 'user' ? '' : '#FFFFFF')
        .linearGradient(msg.role === 'user' ? { angle: 270, colors: [['#6C5CE7', 0], ['#A29BFE', 1]] } : undefined)
        .borderRadius(msg.role === 'user' ?
          { topLeft: 20, bottomLeft: 20, bottomRight: 4, topRight: 20 } :
          { topRight: 20, bottomRight: 20, bottomLeft: 4, topLeft: 20 })
    }.constraintSize({ maxWidth: '78%' })
  }
}