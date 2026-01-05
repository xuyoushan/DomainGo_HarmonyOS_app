import { calendarManager } from '@kit.CalendarKit';
import { common, abilityAccessCtrl } from '@kit.AbilityKit';
import { promptAction, router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
// 严格引用你的模型
import { TravelRoute, ScenicSpot } from '../../models/RouteData';

@Entry
@Component
struct TravelScheduleView {
  @State currentCity: string = '';
  @State routeData: TravelRoute | null = null;
  private calendarMgr: calendarManager.CalendarManager | null = null;

  aboutToAppear() {
    // 1. 获取路由参数 - 增加防御性判断确保数据成功赋值
    const params = router.getParams() as Record<string, Object>;
    if (params && params.route) {
      this.currentCity = (params.cityName as string) || (params.city as string) || '所选城市';
      this.routeData = params.route as TravelRoute;
      console.info('成功加载行程数据: ' + this.routeData.routeName);
    } else {
      console.error('未接收到路由参数 route');
    }

    try {
      this.calendarMgr = calendarManager.getCalendarManager(getContext(this) as common.UIAbilityContext);
    } catch (e) {
      console.error('CalendarManager 初始化失败');
    }
  }

  async handleSyncAction() {
    const context = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();

    try {
      const data = await atManager.requestPermissionsFromUser(context, [
        'ohos.permission.READ_CALENDAR',
        'ohos.permission.WRITE_CALENDAR'
      ]);

      if (data.authResults[0] === 0 && data.authResults[1] === 0) {
        await this.doWriteCalendar();
      } else {
        promptAction.showToast({ message: '请在系统设置中开启日历权限' });
      }
    } catch (err) {
      promptAction.showToast({ message: '权限申请异常' });
    }
  }

  private async doWriteCalendar() {
    if (!this.routeData || !this.calendarMgr) {
      promptAction.showToast({ message: '暂无行程数据，无法同步' });
      return;
    }

    try {
      const calendar = await this.calendarMgr.getCalendar();

      // 时间：1小时后开始，持续3小时
      const startTime = new Date().getTime() + (60 * 60 * 1000);
      const endTime = startTime + (3 * 60 * 60 * 1000);

      // 构造描述文字 - 严格使用 spot.name
      const routeDesc = this.routeData.spots.map((s: ScenicSpot, i: number) => `${i + 1}. ${s.name}`).join('\n');

      // API 21 稳健版：只传系统必填和支持的字段
      // 手机同步手表的逻辑由系统日历自动完成
      const event: calendarManager.Event = {
        title: `[行程] ${this.currentCity}·${this.routeData.routeName}`,
        location: { location: this.currentCity },
        description: `游玩路线：\n${routeDesc}`,
        startTime: startTime,
        endTime: endTime,
        type: calendarManager.EventType.IMPORTANT
      };

      await calendar.addEvent(event);

      promptAction.showDialog({
        title: '同步成功',
        message: '行程已存入手机日历，Watch GT 5 将自动同步提醒。',
        buttons: [{ text: '好的', color: '#007DFF' }]
      });

    } catch (error) {
      const err = error as BusinessError;
      promptAction.showToast({ message: `同步错误: ${err.code}` });
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .onClick(() => router.back())
        Text('行程详情').fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 12 })
      }
      .width('100%').padding(20).margin({ top: 20 })

      // 判断 routeData 是否存在，解决“未发现有效行程”问题
      if (this.routeData) {
        Scroll() {
          Column({ space: 16 }) {
            // 卡片 1：路线名称
            Column() {
              Text(this.routeData.routeName).fontSize(22).fontWeight(FontWeight.Bold)
              Text(this.currentCity).fontSize(14).fontColor('#666').margin({ top: 8 })
            }.width('100%').alignItems(HorizontalAlign.Start).padding(20).backgroundColor(Color.White).borderRadius(16)

            // 卡片 2：景点列表
            Column() {
              ForEach(this.routeData.spots, (spot: ScenicSpot, index: number) => {
                Row() {
                  Text((index + 1).toString()).fontSize(12).fontColor(Color.White)
                    .width(18).height(18).backgroundColor('#007DFF').borderRadius(9).textAlign(TextAlign.Center)
                  // 严格对齐 name 属性
                  Text(spot.name).fontSize(16).margin({ left: 12 })
                }.margin({ bottom: 15 }).width('100%')
              })
            }.width('100%').padding(20).backgroundColor(Color.White).borderRadius(16)

            // 联动说明
            Row() {
              SymbolGlyph($r('sys.symbol.watch')).fontSize(18).fontColor(['#007DFF'])
              Text('已开启与 Watch GT 5 生态联动').fontSize(12).fontColor('#666').margin({ left: 8 })
            }.padding(10)

            Button('一键同步到系统日历')
              .width('100%').height(50).margin({ top: 20 })
              .onClick(() => this.handleSyncAction())
          }.padding(16)
        }
      } else {
        // 如果这里显示了，说明 ExploreView 跳转过来时 params.route 是空的
        Column() {
          SymbolGlyph($r('sys.symbol.exclamationmark_circle')).fontSize(40).fontColor(['#999'])
          Text('未发现有效行程').fontColor('#999').margin({ top: 10 })
          Button('返回重试').margin({ top: 20 }).onClick(() => router.back())
        }.width('100%').margin({ top: 100 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F2F3F5')
  }
}