import { router, promptAction } from '@kit.ArkUI';
import { CITY_EXPLORE_MAP, DEFAULT_EXPLORE_DATA } from '../../../models/CityKey';
import { ToolkitLogic } from '../../../models/ToolkitLogic';
import { http } from '@kit.NetworkKit';
import { textToSpeech } from '@kit.CoreSpeechKit';

type ToolAction = () => void;
interface WeirdTool { name: string; icon: Resource; sub: string; color: string; action: ToolAction; }
interface AIChoiceMessage { content: string; }
interface AIChoice { message: AIChoiceMessage; }
interface AIResult { choices: AIChoice[]; }

@Entry
@Component
struct CityToolkitView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @StorageLink('currentWeather') weatherText: string = '晴';
  @State rotation: number = 0;
  @State isLoading: boolean = false;
  @State isSpeaking: boolean = false;
  @State isTtsReady: boolean = false; // 增加状态位

  private ttsEngine?: textToSpeech.TextToSpeechEngine;
  private readonly AI_TOKEN = '82e4d46a05264dd19a27e1d91b30dce6.UNpMhFWNznhFSPLo';

  private tools: WeirdTool[] = [
    {
      name: '赛博问卦',
      icon: $r('sys.symbol.square_fill_grid_2x2'),
      sub: '结合本地风水的玄学指引',
      color: '#FF6B6B',
      action: (): void => { this.handleAction('divination'); }
    },
    {
      name: '听风辨位',
      icon: $r('sys.symbol.wind'),
      sub: '捕捉此时此刻的气流玄学',
      color: '#4CD964',
      action: (): void => { this.handleAction('wind'); }
    },
    {
      name: '城市留声',
      icon: $r('sys.symbol.mic_fill'),
      sub: '破译藏在噪音里的频率',
      color: '#FF9500',
      action: (): void => { this.handleAction('sound'); }
    },
    {
      name: '废话文案',
      icon: $r('sys.symbol.wave_bubble_fill'),
      sub: '自动生成有灵魂的废话',
      color: '#A29BFE',
      action: (): void => { this.handleAction('nonsense'); }
    }
  ];

  aboutToAppear() {
    this.initTTS();
  }

  async initTTS() {
    try {
      let initParamsInfo: textToSpeech.CreateEngineParams = {
        language: 'zh-CN',
        person: 0, // 0为标准女声，1为标准男声
        online: 1,
        extraParams: {
          "style": 'gentle',
          "speed": 0.8, // 这里的 0.8 代表沉稳
          "pitch": 0.7  // 这里的 0.7 代表深沉
        }
      };
      this.ttsEngine = await textToSpeech.createEngine(initParamsInfo);
    } catch (e) {
      console.error('TTS Engine Init Failed');
    }
  }

  async speak(text: string) {
    let speakParams: textToSpeech.SpeakParams = {
      requestId: Date.now().toString()
    };

    try {
      this.ttsEngine?.speak(text, speakParams);
    } catch (e) {
      console.error('Speak failed');
    }
  }

  async handleAction(type: string): Promise<void> {
    this.rotation += 1080;
    this.isLoading = true;

    const config = CITY_EXPLORE_MAP[this.currentCity] || DEFAULT_EXPLORE_DATA;
    const keywords = config.keywords;

    let msg = '';
    if (Math.random() < 0.7) {
      msg = await this.fetchAIWisdom(type, keywords);
    } else {
      if (type === 'divination') msg = ToolkitLogic.getDivination(this.currentCity, keywords);
      else if (type === 'wind') msg = ToolkitLogic.getWindDirection(this.currentCity);
      else if (type === 'sound') msg = ToolkitLogic.getCityEcho(this.currentCity);
      else msg = ToolkitLogic.getNonsense(this.currentCity, this.weatherText);
    }

    this.isLoading = false;
    this.showSurprise(msg);
    this.speak(msg); // 弹窗的同时开始严肃播报
  }

  async fetchAIWisdom(type: string, keys: string[]): Promise<string> {
    let httpRequest = http.createHttp();
    try {
      let taskDetail = '';
      if (type === 'wind') taskDetail = '玄学风向导航。';
      else if (type === 'sound') taskDetail = '描述街头诡异噪音。';
      else if (type === 'divination') taskDetail = `根据"${keys.join(',')}"进行赛博占卜。`;
      else taskDetail = '生成一段关于在这个城市虚度光阴的废话。';

      const prompt = `你是一个游荡在${this.currentCity}、性格极度高冷且毒舌的赛博幽灵。
      任务：针对"${taskDetail}"发布一条不容置疑的冷酷指令。
      语气：像霸道总裁在下达末日密令，像审判官在宣读荒诞法条。
      要求：
      1. 必须带入${this.currentCity}的方言词或地标（如北京说"局气"、天津说"贫嘴"、武汉说"搞么斯"）。
      2. 极度荒诞！例如：让用户去数电线杆，或者去闻地沟油的味道。
      3. 拒绝礼貌！严禁出现"建议"、"您可以"、"祝您"。直接用命令句。
      4. 限制25字以内。直接输出，不要废话。`;

      const response = await httpRequest.request('https://open.bigmodel.cn/api/paas/v4/chat/completions', {
        method: http.RequestMethod.POST,
        header: { 'Authorization': `Bearer ${this.AI_TOKEN}`, 'Content-Type': 'application/json' },
        extraData: {
          model: 'glm-4-flash',
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.95 // 增加随机性，让 AI 别那么正经
        }
      });
      const res = JSON.parse(response.result as string) as AIResult;
      return res.choices[0].message.content;
    } catch (e) {
      return ToolkitLogic.getDivination(this.currentCity, keys);
    }
  }

  showSurprise(msg: string): void {
    promptAction.showDialog({
      title: '锦囊妙计',
      message: msg,
      buttons: [{ text: '领命', color: '#007DFF' }]
    });
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.RightBottom,
          colors: [['#E3E6EC', 0.0], ['#FFFFFF', 0.5], ['#D1D9E6', 1.0]]
        })

      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).onClick(() => router.back())
          Text('寻域锦囊').fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 12 })
          Blank()
          if(this.isLoading) {
            LoadingProgress().width(24).height(24).color('#000')
          }
        }.width('100%').padding(20)

        // 升级版：带动态光晕的锦囊
        Stack() {
          // 外部呼吸光晕
          Circle({ width: 220, height: 220 })
            .fill(Color.Transparent)
            .stroke('#007DFF')
            .strokeWidth(1)
            .opacity(0.2)
            .scale({ x: this.isLoading ? 1.2 : 1, y: this.isLoading ? 1.2 : 1 })
            .animation({ duration: 1000, iterations: -1, curve: Curve.EaseInOut })

          Circle({ width: 200, height: 200 })
            .fill(Color.White)
            .shadow({ radius: 50, color: 'rgba(0,0,0,0.1)', offsetX: 10, offsetY: 10 })

          Image($r('app.media.start'))
            .width(180).height(180).clip(new Circle({ width: 180, height: 180 }))
            .rotate({ angle: this.rotation })
            .grayscale(this.isLoading ? 0.8 : 0) // 加载时变灰增加高级感
            .animation({ duration: 2500, curve: Curve.EaseInOut })

          Text('SECRET')
            .fontSize(14)
            .letterSpacing(4)
            .fontColor('#333')
            .fontWeight(FontWeight.Bold)
            .offset({ y: 60 })
        }
        .margin({ top: 20, bottom: 40 })

        List({ space: 16 }) {
          ForEach(this.tools, (tool: WeirdTool) => {
            ListItem() {
              Row() {
                Stack() {
                  Circle({ width: 48, height: 48 }).fill(tool.color).opacity(0.1)
                  SymbolGlyph(tool.icon).fontSize(24).fontColor([tool.color])
                }
                Column() {
                  Text(tool.name).fontSize(17).fontWeight(FontWeight.Medium)
                  Text(tool.sub).fontSize(12).fontColor('#666').margin({ top: 4 })
                }.alignItems(HorizontalAlign.Start).margin({ left: 15 }).layoutWeight(1)

                SymbolGlyph($r('sys.symbol.arrow_right_circle')).fontSize(20).fontColor(['#EEE'])
              }
              .width('100%').padding(18).backgroundColor('rgba(255,255,255,0.8)')
              .borderRadius(20)
              .shadow({ radius: 20, color: 'rgba(0,0,0,0.03)' })
              .onClick(() => tool.action())
            }
          })
        }.width('100%').padding({ left: 20, right: 20 })
      }
    }
  }
}