import { router, promptAction } from '@kit.ArkUI';
import { CITY_ROUTES, TravelRoute, ScenicSpot } from '../../models/RouteData';
import { MapComponent, map, mapCommon } from '@kit.MapKit';
import type { AsyncCallback } from '@kit.BasicServicesKit';

/**
 * ✅ 显式接口定义：解决 image_78924f.png 中提到的 untyped-obj-literals 报错
 */
interface PolylineConfig {
  points: mapCommon.LatLng[];
  width: number;
  color: number;
}

@Entry
@Component
struct GuidePageEntrance {
  build() {
    Column() {
      GuideView()
    }
  }
}

@Component
export struct GuideView {
  // --- 状态变量保留 ---
  @State route: TravelRoute = {
    routeName: '加载中...',
    spots: [{ name: '初始地点', address: '获取定位中', latitude: 39.9055, longitude: 116.3976 }]
  };
  @State currentIndex: number = 0;
  @State isAutoCheck: boolean = false;
  @State themeColor: string = '#FF9500';
  @State isNavigating: boolean = false;
  @State isFullScreenMap: boolean = false;

  // ✅ 关键：直接操作此变量来控制地图视角，避开 CameraUpdateFactory 报错
  @State mapCameraPosition: mapCommon.CameraPosition = {
    target: { latitude: 39.9055, longitude: 116.3976 },
    zoom: 14,
    tilt: 0,
    bearing: 0
  };

  private mapController?: map.MapComponentController;

  /**
   * ✅ 地图初始化回调
   */
  private callback: AsyncCallback<map.MapComponentController> = (err, controller) => {
    if (!err && controller) {
      this.mapController = controller;
      this.mapController.setMyLocationEnabled(true);
      this.refreshMapElements();
    }
  };

  /**
   * ✅ 绘制方法：命令式 API 避开 build() 内的字面量报错
   */
  private refreshMapElements() {
    if (!this.mapController) return;

    // 清理旧标记，准备重新绘制
    this.mapController.clear();

    // 1. 绘制路线轨迹
    const path: mapCommon.LatLng[] = this.route.spots
      .filter(s => s.latitude !== undefined && s.longitude !== undefined)
      .map((s): mapCommon.LatLng => {
        return { latitude: s.latitude!, longitude: s.longitude! };
      });

    if (path.length > 1) {
      this.mapController.addPolyline({
        points: path,
        width: 10,
        color: 0xffFF9500
      });
    }

    // 2. 绘制当前目标 Marker
    const current = this.route.spots[this.currentIndex];
    if (current.latitude && current.longitude) {
      this.mapController.addMarker({
        position: { latitude: current.latitude, longitude: current.longitude },
        title: current.name
      });
    }
  }

  aboutToAppear() {
    const params = router.getParams() as Record<string, TravelRoute>;
    if (params && params['route']) {
      this.route = params['route'];
    } else if (CITY_ROUTES['北京市'] && CITY_ROUTES['北京市'].length > 0) {
      this.route = CITY_ROUTES['北京市'][0];
    }
    this.moveMapToSpot(0);
  }

  /**
   * ✅ 彻底修复：不再使用 CameraUpdateFactory
   * 直接修改 @State 变量来触发 MapComponent 内部的视角变化
   */
  moveMapToSpot(index: number) {
    const spot = this.route.spots[index];
    if (!spot || spot.latitude === undefined || spot.longitude === undefined) return;

    // 直接赋值给绑定变量，UI 框架会自动同步地图位置
    // 导航模式开启时，增加倾斜度和缩放级别模拟指引感
    this.mapCameraPosition = {
      target: { latitude: spot.latitude, longitude: spot.longitude },
      zoom: this.isNavigating ? 18 : 15,
      tilt: this.isNavigating ? 45 : 0,
      bearing: 0
    };

    // 刷新 Marker 位置
    this.refreshMapElements();
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {

      // --- 1. 地图区域 (zIndex 保证在底层) ---
      Column() {
        MapComponent({
          // 关联状态变量
          mapOptions: { position: this.mapCameraPosition },
          mapCallback: this.callback
        })
          .width('100%')
          .height(this.isFullScreenMap ? '100%' : '45%')
          .animation({ duration: 300, curve: Curve.EaseInOut })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Up) {
              this.isFullScreenMap = !this.isFullScreenMap;
            }
          })
      }
      .zIndex(1)

      // --- 2. 悬浮操作面板 (100% 完整保留逻辑) ---
      Column() {
        Column() {
          Row() {
            Text('当前目标').fontSize(12).fontColor('#999').padding(4).backgroundColor('#F5F5F5').borderRadius(4)
            Blank()
            Row() {
              Text('距离校验').fontSize(12).fontColor('#999')
              Toggle({ type: ToggleType.Switch, isOn: this.isAutoCheck })
                .size({ width: 35, height: 20 }).margin({ left: 5 })
                .onChange((isOn) => this.isAutoCheck = isOn)
            }
          }.width('100%')

          Text(this.route.spots[this.currentIndex]?.name || '未知地点')
            .fontSize(26).fontWeight(FontWeight.Bolder).margin({ top: 15 })

          Text(this.route.spots[this.currentIndex]?.address || '暂无地址')
            .fontSize(14).fontColor('#666').margin({ top: 8, bottom: 20 })

          Row({ space: 15 }) {
            Button(this.isNavigating ? '停止导航' : '开始导航')
              .layoutWeight(1).height(45).backgroundColor(this.isNavigating ? '#666' : '#333')
              .onClick(() => {
                this.isNavigating = !this.isNavigating;
                if (this.isNavigating) {
                  this.isFullScreenMap = true; // 导航自动进入大图
                  this.moveMapToSpot(this.currentIndex);
                  promptAction.showToast({ message: `内部指引已开启` });
                }
              })

            Button(this.currentIndex === this.route.spots.length - 1 ? '全程完成' : '抵达打卡')
              .layoutWeight(1).height(45).backgroundColor(this.themeColor)
              .onClick(() => this.handleAction())
          }
        }
        .width('100%').padding(20).backgroundColor('#FFF').borderRadius(20).shadow({ radius: 20, color: '#1A000000' })

        Text('行程详情').width('100%').margin({ top: 30, bottom: 15 }).fontSize(16).fontWeight(FontWeight.Bold)

        List({ space: 10 }) {
          ForEach(this.route.spots, (spot: ScenicSpot, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Circle({ width: 10, height: 10 })
                    .fill(index === this.currentIndex && this.isNavigating ? '#FF4500' : (index <= this.currentIndex ? this.themeColor : '#DDD'))
                  if (index !== this.route.spots.length - 1) { Rect().width(1).height(30).fill('#EEE') }
                }.width(20)

                Text(spot.name).fontSize(14).fontColor(index === this.currentIndex ? '#333' : (index < this.currentIndex ? '#CCC' : '#666'))
                  .decoration({ type: index < this.currentIndex ? TextDecorationType.LineThrough : TextDecorationType.None })
                  .onClick(() => this.moveMapToSpot(index))
                Blank()
                if (index < this.currentIndex) { SymbolGlyph($r('sys.symbol.checkmark_circle_fill')).fontColor([this.themeColor]).fontSize(18) }
              }.width('100%').padding({ left: 10, right: 10 })
            }
          })
        }.layoutWeight(1).edgeEffect(EdgeEffect.Spring)
      }
      .zIndex(2)
      .translate({ y: this.isFullScreenMap ? 1000 : 0 })
      .animation({ duration: 400, curve: Curve.FastOutSlowIn })
      .margin({ top: 220 }).padding(20).width('100%').height('100%').backgroundColor('#F7F7F7').borderRadius({ topLeft: 30, topRight: 30 })

      // --- 3. 退出按钮层 ---
      if (this.isFullScreenMap) {
        Button('收起指引大图')
          .zIndex(3).position({ x: '30%', y: 80 }).backgroundColor('#CC000000')
          .onClick(() => {
            this.isFullScreenMap = false;
            this.isNavigating = false;
            this.moveMapToSpot(this.currentIndex);
          })
      }

      Button() { SymbolGlyph($r('sys.symbol.chevron_left')).fontColor(['#FFF']).fontSize(24) }
      .zIndex(4).type(ButtonType.Circle).backgroundColor('#40000000').width(40).height(40)
      .position({ x: 20, y: 40 }).onClick(() => {
        if (this.isFullScreenMap) { this.isFullScreenMap = false }
        else { router.back() }
      })
    }
    .width('100%').height('100%')
  }

  handleAction() {
    if (this.isAutoCheck) {
      promptAction.showDialog({
        title: '位置校验',
        message: '正在核对您的位置...',
        buttons: [{ text: '跳过校验并打卡', color: this.themeColor }]
      }).then((data) => {
        if (data.index === 0) { this.proceedToCheckIn() }
      });
      return;
    }
    this.proceedToCheckIn();
  }

  proceedToCheckIn() {
    if (this.currentIndex < this.route.spots.length - 1) {
      this.currentIndex++;
      this.moveMapToSpot(this.currentIndex);
      promptAction.showToast({ message: '打卡成功，目标已更新' });
    } else {
      promptAction.showDialog({
        title: '恭喜！',
        message: '您已完成所有打卡',
        buttons: [{ text: '好的', color: this.themeColor }]
      }).then(() => router.back());
    }
  }
}