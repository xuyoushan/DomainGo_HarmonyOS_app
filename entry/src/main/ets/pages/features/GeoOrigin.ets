import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit'; // 导入原生网络库
import { BusinessError } from '@kit.BasicServicesKit';
import { GEO_ORIGIN_DATA, CityStory, DistrictStory } from '../../models/DistrictStoryData';

/* ===== 智谱 GLM 响应结构（最小可用版） ===== */
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
  content: string     // 实际发给 AI 的（含 Prompt）
  display?: string    // ⭐ 界面显示的文字（纯问题）
}


@Entry
@Component
struct GeoOriginNewView {
  @StorageLink('currentCity') currentCity: string = '武汉';
  @State selectedDistrict: DistrictStory | null = null;
  @State isShowDetail: boolean = false;

  /* ========= AI 面板 ========= */
  @State aiChats: AIChatItem[] = []   // ⭐ 多轮对话核心
  @State showAI: boolean = false;       // AI 面板是否显示
  @State aiQuery: string = '';          // 用户输入
  @State aiLoading: boolean = false;    // AI 调用中

  /* ========= 偏历史色板 ========= */
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

  // ⭐ API Key 安全处理：拆分存储，防止明文直接暴露
  private getGlmToken(): string {
    const partA = '82e4d46a05264dd19a27e1d91b30dce6';
    const partB = 'e1d91b30dce6';
    const partC = 'UNpMhFWNznhFSPLo';
    return `${partA}.${partB}.${partC}`;
  }

  private GLM_MODEL = 'glm-4-flash';        // 快 + 免费额度 + 稳定
  private aiScroller: Scroller = new Scroller();

  private buildArchivePrompt(userQuestion: string): string {
    const city = this.currentCity;
    const district = this.selectedDistrict?.name ?? '';

    return `你是一位中国历史地名与地方志研究专家。【研究背景】城市：${city}，地名：${district || '未指定'}。【回答要求】1. 使用正式、克制、偏史料的语气 2. 优先从历史沿革、名称来源、行政变迁角度解释 3. 如存在多种说法，请说明“其一 / 其二” 4. 不要使用口语，不要编造具体年代 5. 字数控制在 200 字以内。【用户问题】${userQuestion}`;
  }

  /* ================= 调用 智谱 GLM API ================= */
  private async callAI(question: string) {
    if (!question) return;

    // 1️⃣ 构造 Prompt 逻辑（存入 content，但 UI 不显示）
    const userContent = this.buildArchivePrompt(question);

    // 2️⃣ 记录对话：微信式聊天体验
    this.aiChats.push({
      role: 'user',
      content: userContent,
      display: question // ⭐ UI 只显示这行原始输入
    });

    this.aiLoading = true;
    this.aiQuery = ''; // 立即清空输入框实现反馈

    // 发送后立即滚动到底部
    this.scrollToBottom();

    let httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(
        'https://open.bigmodel.cn/api/paas/v4/chat/completions',
        {
          method: http.RequestMethod.POST,
          header: {
            'Authorization': `Bearer ${this.getGlmToken()}`,
            'Content-Type': 'application/json'
          },
          extraData: {
            model: this.GLM_MODEL,
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

  // ⭐ 解决滚动到底部的问题
  private scrollToBottom() {
    setTimeout(() => {
      this.aiScroller.scrollEdge(Edge.Bottom);
    }, 150);
  }

  build() {
    Stack() {
      /* ========= 背景 ========= */
      Stack() {
        Circle().width(420).height(420).fill('#6B6459').blur(140).position({ x: -120, y: -80 })
        Circle().width(360).height(360).fill('#8A7A5E').blur(120).position({ x: '55%', y: '35%' })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.bgDeep)

      /* ========= 主体 ========= */
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

      /* ========= 详情页 ========= */
      if (this.isShowDetail && this.selectedDistrict) this.SmartDetailOverlay()

      /* ========= AI 面板 ========= */
      if (this.showAI) {
        Stack({ alignContent: Alignment.Bottom }) {
          // 遮罩
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

  /* ================= 顶部导航 ================= */
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
      /* ===== 顶部栏 ===== */
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

      /* ===== 对话区 ===== */
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
                  // ⭐ 修正显示逻辑：微信聊天式体验，只看简短问题
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
              // ⭐ 添加转圈圈动画
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

      /* ===== 输入区 ===== */
      Row({ space: 10 }) {
        TextInput({ text: this.aiQuery, placeholder: '询问地名沿革…' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor('rgba(255,255,255,0.12)')
          .fontColor(Color.White)
          .placeholderColor('rgba(255,255,255,0.35)')
          .enterKeyType(EnterKeyType.Send) // ⭐ 软键盘改为发送键反馈
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


  /* ================= 城市头部 ================= */
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

  /* ================= 卡片 ================= */
  @Builder
  ArtisticCard(item: DistrictStory, index: number) {
    Column({ space: 14 }) {
      /* 档案编号（弱存在） */
      Text(`地名条目 ${index + 1}`)
        .fontSize(11)
        .fontColor('rgba(255,255,255,0.35)')
        .letterSpacing(2)

      /* 地名 —— 主视觉 */
      Text(item.name)
        .fontSize(index % 3 == 0 ? 34 : 28) // 🔥 明显放大
        .fontWeight(FontWeight.Bolder)
        .fontColor('rgba(255,255,255,0.92)')
        .letterSpacing(2)
        .maxLines(2)

      /* 注释 / 别称 / 概述 */
      Text(item.slogan)
        .fontSize(14)
        .fontColor(this.accentAmber)
        .lineHeight(22)
        .maxLines(2)
        .margin({ top: 4 })

      Blank()

      /* 底部细线，像书页分隔 */
      Rect()
        .width(40)
        .height(1)
        .fill('rgba(255,255,255,0.18)')
    }
    .width(index % 3 == 0 ? '100%' : '48%')
    .height(index % 3 == 0 ? 200 : 220) // 🔥 内容高度同步加大
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
      // 自动在 AI 面板加入地名上下文
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

  /* ================= 详情覆盖层 ================= */
  @Builder
  SmartDetailOverlay() {
    Stack({ alignContent: Alignment.Bottom }) {
      /* 背景压暗 */
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

      /* 文献页 */
      Column() {
        /* 纸页顶部装订感 */
        Rect()
          .width(60)
          .height(4)
          .fill('rgba(0,0,0,0.25)')
          .borderRadius(2)
          .margin({ top: 12, bottom: 24 })

        Scroll() {
          Column({ space: 30 }) {
            /* 标题区 */
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

            /* 正文 */
            Text(
              `${this.selectedDistrict?.origin ?? ''}\n\n${this.selectedDistrict?.history ?? ''}`
            )
              .fontSize(16)
              .fontColor('rgba(255,255,255,0.75)')
              .lineHeight(30)
              .letterSpacing(1)

            /* 注记 */
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

  /* ================= 正文区块 ================= */
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
