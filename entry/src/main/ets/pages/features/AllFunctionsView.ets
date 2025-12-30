// AllFunctionsView.ets
import { promptAction, router } from '@kit.ArkUI';

// 1. 必须定义接口，解决 arks-no-obj-literals 报错
interface FunctionItem {
  name: string;
  icon: Resource;
  color: string;
}

@Entry
@Component
struct AllFunctionsView {
  private scroller: Scroller = new Scroller();
  @StorageLink('currentCity') currentCity: string = '武汉市';

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .onClick(() => {
            router.back(); // 补全返回逻辑
          })
        Text('全部服务')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 15 })
        Blank()
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      Scroll(this.scroller) {
        Column({ space: 20 }) {
          // 2. 使用显式定义的数组
          this.FunctionGroup('文旅类', [
            { name: '门票预订', icon: $r('sys.symbol.ticket_fill'), color: '#74B9FF' },
            { name: '语音导览', icon: $r('sys.symbol.mic_fill'), color: '#A29BFE' },
            { name: '博物馆预约', icon: $r('sys.symbol.house_fill'), color: '#fab1a0' }, // 修正可能不存在的 bank_fill
            { name: '当地向导', icon: $r('sys.symbol.person_2_fill'), color: '#55efc4' }
          ])

          this.FunctionGroup('政务类', [
            { name: '行政隶属', icon: $r('sys.symbol.map_badge_cloud_slash_fill'), color: '#00cec9' },
            { name: '邮编查询', icon: $r('sys.symbol.envelope_fill'), color: '#81ecec' },
            { name: '区号查询', icon: $r('sys.symbol.phone_fill'), color: '#74b9ff' },
            { name: '人口数据', icon: $r('sys.symbol.person_3_fill'), color: '#0984e3' }
          ])

          this.FunctionGroup('生活类', [
            { name: '城市商圈', icon: $r('sys.symbol.cart_fill'), color: '#ffeaa7' },
            { name: '医疗药店', icon: $r('sys.symbol.plus_circle_fill'), color: '#ff7675' },
            { name: '天气深度预报', icon: $r('sys.symbol.cloud_sun_fill'), color: '#fdcb6e' },
            { name: '实时汇率', icon: $r('sys.symbol.yuan_banknote_inlet'), color: '#6c5ce7' }
          ])
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  // 3. 修改函数签名，引用上面定义的 FunctionItem 接口
  @Builder FunctionGroup(title: string, items: FunctionItem[]) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 15 })
        .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(items, (item: FunctionItem) => {
          Column() {
            Stack() {
              Circle().width(48).height(48).fill(item.color).opacity(0.1)
              SymbolGlyph(item.icon).fontColor([item.color]).fontSize(24)
            }
            Text(item.name).fontSize(12).margin({ top: 8 }).fontColor('#333')
          }
          .width('25%')
          .margin({ bottom: 20 })
          .onClick(() => {
            // 增加逻辑拦截：只有点击指定功能才跳转
            if (item.name === '城市印象' || item.name === '读美文') {
              router.pushUrl({
                url: 'pages/DataDetailView',
                params: {
                  title: item.name,
                  icon: item.icon,
                  color: item.color,
                  cityName: this.currentCity, // 确保从首页同步到了最新的定位城市
                  funcType: 'general'
                }
              }, router.RouterMode.Standard, (err) => {
                if (err) {
                  console.error(`跳转失败，错误码: ${err.code}, 错误信息: ${err.message}`);
                }
              })
            } else {
              // 拦截其他所有图标的点击（如：门票预订、实时汇率、行政区划等）
              // 这样就不会出现点击哪里都跳到文章页的 Bug 了
              promptAction.showToast({ message: `${item.name} 功能开发中...` });
            }
          })
        }, (item: FunctionItem) => item.name)
      }
      .backgroundColor('#FFFFFF')
      .padding({ top: 20, left: 10, right: 10 })
      .borderRadius(12)
    }
  }
}