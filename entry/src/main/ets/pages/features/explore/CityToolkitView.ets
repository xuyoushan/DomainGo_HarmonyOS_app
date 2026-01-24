// import { router } from '@kit.ArkUI';
//
// interface TooltipItem {
//   title: string;
//   content: string;
//   subContent?: string;
// }
//
// @Entry
// @Component
// struct CityToolkitView {
//   @StorageLink('currentCity') currentCity: string = '武汉市';
//   @StorageLink('currentWeather') weatherInfo: string = '20°C';
//
//   // 模拟数据：你可以根据 currentCity 切换
//   private dialectList: TooltipItem[] = [
//     { title: '过早', content: 'guò zǎo', subContent: '吃早餐，武汉人的灵魂仪式。' },
//     { title: '耍拉', content: 'shuǎ lā', subContent: '形容办事干脆利索，不磨叽。' },
//     { title: '蛮扎实', content: 'mán zhā shí', subContent: '非常厉害，或者东西很稳固。' }
//   ];
//
//   build() {
//     Column() {
//       // --- 自定义导航栏 ---
//       Row() {
//         SymbolGlyph($r('sys.symbol.chevron_left'))
//           .fontSize(24)
//           .onClick(() => router.back())
//         Text(`${this.currentCity} · 寻域锦囊`)
//           .fontSize(18)
//           .fontWeight(FontWeight.Bold)
//           .margin({ left: 12 })
//       }
//       .width('100%')
//       .padding({ left: 16, top: 44, bottom: 20 })
//       .backgroundColor(Color.White)
//
//       Scroll() {
//         Column({ space: 20 }) {
//
//           // 1. 穿衣锦囊 (实用的行程建议)
//           this.ToolkitCard('穿衣指数', $r('sys.symbol.tshirt_fill'), '#007DFF') {
//             Column({ space: 8 }) {
//               Text(`当前温度：${this.weatherInfo}`).fontSize(15).fontWeight(FontWeight.Medium)
//               Text("建议：早晚温差较大，建议“洋葱式”穿衣法，外搭一件轻便夹克。")
//                 .fontSize(13).fontColor('#666').lineHeight(20)
//             }.alignItems(HorizontalAlign.Start)
//           }
//
//           // 2. 方言急救包 (趣味交互)
//           this.ToolkitCard('方言急救包', $r('sys.symbol.mic_fill'), '#FF9500') {
//             Flex({ wrap: FlexWrap.Wrap }) {
//               ForEach(this.dialectList, (item: TooltipItem) => {
//                 Column() {
//                   Text(item.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
//                   Text(item.content).fontSize(10).fontColor('#999').margin({ top: 4 })
//                 }
//                 .backgroundColor('#F5F7FA')
//                 .padding(12)
//                 .borderRadius(12)
//                 .margin(4)
//                 .width('46%')
//                 .alignItems(HorizontalAlign.Start)
//                 .onClick(() => {
//                   // 这里可以接 TTS 语音合成，或者简单弹个 Toast
//                 })
//               })
//             }
//           }
//
//           // 3. 本地人叮嘱 (避坑锦囊)
//           this.ToolkitCard('本地叮嘱', $r('sys.symbol.exclamationmark_bubble_fill'), '#FF3B30') {
//             Column({ space: 12 }) {
//               this.TipRow("拒绝火车站拉客的“低价一日游”。")
//               this.TipRow("景区里的金丝牛肉饼大排长龙？其实本地菜市场里的更好吃。")
//               this.TipRow("不要相信出租车司机推荐的“正宗老字号”。")
//             }
//           }
//
//         }.padding(16)
//       }
//       .layoutWeight(1)
//     }
//     .width('100%')
//     .height('100%')
//     .backgroundColor('#F8F8F8')
//   }
//
//   // 通用卡片容器
//   @Builder ToolkitCard(title: string, icon: Resource, color: string, @BuilderParam content: () => void) {
//     Column() {
//       Row() {
//         SymbolGlyph(icon).fontSize(20).fontColor([color])
//         Text(title).fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 8 })
//       }.margin({ bottom: 16 })
//
//       content()
//     }
//     .width('100%')
//     .padding(20)
//     .backgroundColor(Color.White)
//     .borderRadius(16)
//   }
//
//   @Builder TipRow(text: string) {
//     Row() {
//       Circle({ width: 6, height: 6 }).fill('#FF3B30').margin({ right: 10 })
//       Text(text).fontSize(13).fontColor('#444').layoutWeight(1)
//     }.alignItems(VerticalAlign.Top).margin({ bottom: 4 })
//   }
// }