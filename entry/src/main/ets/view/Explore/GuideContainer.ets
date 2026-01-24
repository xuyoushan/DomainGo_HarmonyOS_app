// // ets/view/Explore/GuideContainer.ets
// import { router } from '@kit.ArkUI';
//
// @Component
// export struct GuideContainer {
//   @Link currentStage: 'welcome' | 'stepGuide' | 'teaching' | 'full';
//   @Link guideStepIndex: number;
//   @Link displayedText: string;
//   @Link isTyping: boolean;
//   @Link scaleValue: number;
//   @Link hasCompletedGuide: boolean;
//
//   // 方法通过参数传入
//   @Prop getSteps: () => string[];
//   @Prop nextStep: (total: number) => void;
//   @Prop playStepText: () => void;
//   @Prop enterMainPage: () => void;
//   @Prop heroArchiveCardBuilder: () => void;
//
//   // 🎨 背景氛围效果
//   @Builder BackgroundAtmosphere() {
//     Stack() {
//       Image($r('app.media.start'))
//         .width('100%')
//         .height('100%')
//         .objectFit(ImageFit.Cover)
//         .blur(25)
//         .opacity(0.6)
//         .scale({ x: 1.2, y: 1.2 })
//         .animation({ duration: 12000, iterations: -1, curve: Curve.Linear })
//       Rect()
//         .width('100%')
//         .height('100%')
//         .fill(Color.Black)
//         .opacity(0.15)
//     }
//     .width('100%')
//     .height('100%')
//     .hitTestBehavior(HitTestMode.None)
//   }
//
//   // 🎪 欢迎引导页面
//   @Builder WelcomeGuideUI() {
//     Stack() {
//       Image($r('app.media.start'))
//         .width('100%')
//         .height('100%')
//         .objectFit(ImageFit.Cover)
//
//       Column()
//         .width('100%')
//         .height('100%')
//         .linearGradient({
//           direction: GradientDirection.Bottom,
//           colors: [['#20000000', 0.0], ['#80000000', 1.0]]
//         })
//
//       Column() {
//         Text('寻 · 域')
//           .fontSize(48)
//           .fontWeight(FontWeight.Lighter)
//           .fontColor(Color.White)
//           .letterSpacing(15)
//           .margin({ bottom: 10 })
//
//         Text('—— 触摸每一座城市的温度 ——')
//           .fontSize(14)
//           .fontColor('#CCFFFFFF')
//           .letterSpacing(2)
//           .margin({ bottom: 80 })
//
//         Button() {
//           Row({ space: 8 }) {
//             Text('开启旅程').fontColor(Color.White).fontSize(16).fontWeight(FontWeight.Medium)
//             SymbolGlyph($r('sys.symbol.arrow_right')).fontSize(18).fontColor([Color.White])
//           }
//         }
//         .width(200)
//         .height(56)
//         .backgroundColor('rgba(255,255,255,0.15)')
//         .backgroundBlurStyle(BlurStyle.Thin)
//         .borderRadius(28)
//         .border({ width: 1, color: 'rgba(255,255,255,0.3)' })
//         .onClick(() => {
//           this.currentStage = 'stepGuide'
//           this.guideStepIndex = 0
//           this.playStepText()
//         })
//       }
//       .width('100%')
//       .padding({ bottom: 100 })
//       .alignItems(HorizontalAlign.Center)
//       .justifyContent(FlexAlign.End)
//     }
//     .width('100%')
//     .height('100%')
//   }
//
//   // 📝 分步引导页面
//   @Builder StepGuideUI() {
//     Stack() {
//       Column() {
//         Text(this.displayedText)
//           .fontSize(20)
//           .fontWeight(FontWeight.Lighter)
//           .fontColor(Color.White)
//           .lineHeight(32)
//           .textAlign(TextAlign.Center)
//           .margin({ left: 24, right: 24, bottom: 30 })
//           .textShadow({ radius: 4, color: '#80000000', offsetY: 2 })
//
//         if (!this.isTyping) {
//           Button({ type: ButtonType.Capsule, stateEffect: true }) {
//             Text(this.guideStepIndex < this.getSteps().length - 1 ? '下一步' : '开始探索')
//               .fontSize(16)
//               .fontColor(Color.White)
//               .fontWeight(FontWeight.Medium)
//               .letterSpacing(2)
//           }
//           .width(200)
//           .height(56)
//           .linearGradient({
//             direction: GradientDirection.Right,
//             colors: [['#FF7F50', 0.0], ['#FF6B6B', 1.0]]
//           })
//           .border({ width: 1, color: 'rgba(255, 255, 255, 0.5)' })
//           .borderRadius(25)
//           .shadow({
//             radius: 15,
//             color: 'rgba(255, 107, 107, 0.4)',
//             offsetY: 8
//           })
//           .scale({ x: this.scaleValue, y: this.scaleValue })
//           .onTouch((event: TouchEvent) => {
//             if (event.type === TouchType.Down) {
//               animateTo({ duration: 100 }, () => { this.scaleValue = 0.95 })
//             } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
//               animateTo({ duration: 100 }, () => { this.scaleValue = 1.0 })
//             }
//           })
//           .onClick(() => this.nextStep(this.getSteps().length))
//         }
//       }
//       .alignItems(HorizontalAlign.Center)
//       .justifyContent(FlexAlign.Center)
//       .width('100%')
//       .height('100%')
//     }
//     .width('100%')
//     .height('100%')
//   }
//
//   // 🏫 教学页面
//   @Builder TeachingUI() {
//     Column({ space: 20 }) {
//       Text('先从城市印象开始了解这座城市').fontSize(16).fontColor('#666')
//
//       this.HeroArchiveCardContent()
//
//       Stack({ alignContent: Alignment.BottomStart }) {
//         Image($r('app.media.city_impression_placeholder'))
//           .width('100%').height(140).borderRadius(20).objectFit(ImageFit.Cover)
//           .linearGradient({
//             direction: GradientDirection.Bottom,
//             colors: [['#00000000', 0.0], ['#CC000000', 1.0]]
//           })
//         Column() {
//           Text('城市印象').fontSize(22).fontWeight(FontWeight.Bolder).fontColor(Color.White)
//           Text('城市档案总览').fontSize(12).fontColor('rgba(255,255,255,0.8)').margin({ top: 4 })
//         }.padding(20)
//       }
//       .width('100%')
//
//       Button('展开完整内容')
//         .width(200)
//         .height(40)
//         .backgroundColor('#007DFF')
//         .fontColor(Color.White)
//         .onClick(() => {
//           this.enterMainPage()
//         })
//     }
//     .padding(16)
//     .width('100%')
//     .height('100%')
//     .justifyContent(FlexAlign.Center)
//     .backgroundColor('#F8F8F8')
//   }
//
//   // 处理 HeroArchiveCard Builder
//   @Builder HeroArchiveCardContent() {
//     this.heroArchiveCardBuilder ? this.heroArchiveCardBuilder() : Stack()
//   }
//
//   // 🎬 构建整个引导模态框
//   @Builder GuideModalBuilder() {
//     Stack() {
//       Rect().width('100%').height('100%').fill(Color.Black)
//
//       if (this.currentStage === 'welcome' || this.currentStage === 'stepGuide') {
//         this.BackgroundAtmosphere()
//       }
//       if (this.currentStage === 'teaching') {
//         Rect().width('100%').height('100%').fill('#F8F8F8')
//       }
//
//       Column() {
//         if (this.currentStage === 'welcome') {
//           this.WelcomeGuideUI()
//         } else if (this.currentStage === 'stepGuide') {
//           this.StepGuideUI()
//         } else if (this.currentStage === 'teaching') {
//           this.TeachingUI()
//         }
//       }
//       .width('100%')
//       .height('100%')
//     }
//     .width('100%')
//     .height('100%')
//     .backgroundColor(Color.Black)
//     .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
//   }
//
//   build() {
//     // 直接调用Builder
//     this.GuideModalBuilder()
//   }
// }