import { PreferenceManager } from '../../services/PreferenceManager';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI'; // 必须从 ArkUI 导入 window 模块

@Component
export struct WelcomeGuide {
  @Link currentStage: string;
  @Link displayedText: string;
  @Link isTyping: boolean;
  @Link guideStepIndex: number;
  @Link scaleValue: number;
  @Link isReady: boolean;

  private timerId: number = -1;
  private context = getContext(this) as common.UIAbilityContext;

  // --- 引导文案数据 ---
  private getGuideSteps(): string[] {
    return [
      `欢迎来到寻域之旅。\n在这座城市，每条街道、每幢建筑、每个人的笑声里，都藏着独特的故事。`,
      `这里有被时间遗忘的老巷，有被记忆铭刻的历史建筑。\n走进去，你会发现那些平凡角落里非凡的秘密。`,
      `在这里，你可以慢慢品味城市的味道。\n无论是街头小吃的香气，\n还是老茶馆里的谈笑声，\n都在讲述属于城市的温度。`,
      `每一座城市都有自己的节奏和脉络。\n历史、文化、生活在这里交织，每一步行走，都是一次新的发现。`,
      `准备好了吗？\n让我们从这里开始，慢慢触摸城市的故事。\n一场探索之旅即将在你的指尖展开。`,
      `点击“开始探索”\n去寻域\n去了解每个功能、每条路线、每个故事的精华。`];
  }

  private playStepText() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }

    const steps = this.getGuideSteps();
    this.displayedText = '';
    this.isTyping = true;
    const fullText = steps[this.guideStepIndex];
    let i = 0;

    this.timerId = setInterval(() => {
      if (i < fullText.length) {
        this.displayedText += fullText[i];
        i++;
      } else {
        clearInterval(this.timerId);
        this.timerId = -1;
        this.isTyping = false;
      }
    }, 50);
  }

  private nextStep(total: number) {
    if (this.isTyping) return;
    if (this.guideStepIndex < total - 1) {
      this.guideStepIndex++;
      this.playStepText();
    }
  }

  private async enterMainPage() {
    await PreferenceManager.put(this.context, 'hasCompletedGuide', true);
    await PreferenceManager.put(this.context, 'show_guide_manual', false);
    AppStorage.setOrCreate('show_guide_manual', false);
    AppStorage.setOrCreate('welcomeFinished', true);

    const win = await window.getLastWindow(this.context);
    animateTo({
      duration: 888,
      curve: Curve.EaseInOut,
      onFinish: () => {
        this.currentStage = 'full';
      }
    }, () => {
      this.isReady = false;
      win.setWindowSystemBarEnable(['status', 'navigation']);
      win.setWindowLayoutFullScreen(false);
    })
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
      console.info('[WelcomeGuide] 定时器已清理');
    }
  }

  @Builder BackgroundAtmosphere() {
    Stack() {
      Image($r('app.media.start'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(25)
        .opacity(0.6)
        .scale({ x: 1.2, y: 1.2 })
        .animation({ duration: 12000, iterations: -1, curve: Curve.Linear })
      Rect()
        .width('100%')
        .height('100%')
        .fill(Color.Black)
        .opacity(0.15)
    }.width('100%').height('100%')
    .hitTestBehavior(HitTestMode.None)
  }

  build() {
    Stack() {
      Rect().width('100%').height('100%').fill(Color.Black)

      this.BackgroundAtmosphere()

      Column() {
        if (this.currentStage === 'welcome') {
          this.WelcomeGuideUI()
        } else {
          this.StepGuideUI()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder WelcomeGuideUI() {
    Stack() {
      Image($r('app.media.start'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#20000000', 0.0], ['#80000000', 1.0]]
        })
      Column() {
        Text('寻 · 域')
          .fontSize(48)
          .fontWeight(FontWeight.Lighter)
          .fontColor(Color.White)
          .letterSpacing(15)
          .margin({ bottom: 10 })

        Text('—— 触摸每一座城市的温度 ——')
          .fontSize(14)
          .fontColor('#CCFFFFFF')
          .letterSpacing(2)
          .margin({ bottom: 80 })

        Button() {
          Row({ space: 8 }) {
            Text('开启旅程').fontColor(Color.White).fontSize(16).fontWeight(FontWeight.Medium)
            SymbolGlyph($r('sys.symbol.arrow_right')).fontSize(18).fontColor([Color.White])
          }
        }
        .width(200)
        .height(56)
        .backgroundColor('rgba(255,255,255,0.15)')
        .backgroundBlurStyle(BlurStyle.Thin)
        .borderRadius(28)
        .border({ width: 1, color: 'rgba(255,255,255,0.3)' })
        .onClick(async () => {
          const isFinished = await PreferenceManager.get(this.context, 'hasCompletedGuide', false) as boolean;
          const isManualOpen = await PreferenceManager.get(this.context, 'show_guide_manual', false) as boolean;
          if (isFinished && !isManualOpen) {
            this.enterMainPage();
          } else {
            animateTo({ duration: 300 }, () => {
              this.currentStage = 'stepGuide';
            })
            this.guideStepIndex = 0;
            this.playStepText();
          }
        })
      }
      .width('100%')
      .padding({ bottom: 100 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height('100%')
  }

  @Builder StepGuideUI() {
    Stack() {
      Column() {
        Text(this.displayedText).fontSize(20)
          .fontWeight(FontWeight.Lighter).fontColor(Color.White)
          .lineHeight(32).textAlign(TextAlign.Center)
          .margin({ left: 24, right: 24, bottom: 30 }).textShadow({ radius: 4, color: '#80000000', offsetY: 2 })
        if (!this.isTyping) {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Text(this.guideStepIndex < this.getGuideSteps().length - 1 ? '下一步' : '开始探索')
              .fontSize(16)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .letterSpacing(2)
          }
          .width(200).height(56)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#FF7F50', 0.0], ['#FF6B6B', 1.0]]
          })
          .border({ width: 1, color: 'rgba(255, 255, 255, 0.5)' })
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White).fontSize(16)
          .backgroundBlurStyle(BlurStyle.Thin)
          .border({ width: 1, color: 'rgba(255, 255, 255, 0.5)' })
          .borderRadius(25)
          .shadow({
            radius: 15,
            color: 'rgba(255, 107, 107, 0.4)', // 按钮同色系的呼吸投影
            offsetY: 8
          })
          .scale({ x: this.scaleValue, y: this.scaleValue })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              animateTo({ duration: 100 }, () => { this.scaleValue = 0.95 })
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              animateTo({ duration: 100 }, () => { this.scaleValue = 1.0 })
            }
          })
          .onClick(() => {
            if (this.guideStepIndex < this.getGuideSteps().length - 1) {
              this.nextStep(this.getGuideSteps().length);
            } else {
              this.enterMainPage();
            }
          })
        }
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
      .onClick(() => this.nextStep(this.getGuideSteps().length))
    }
    .width('100%')
    .height('100%')
  }
}