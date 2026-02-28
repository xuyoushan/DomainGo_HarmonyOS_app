import { router, promptAction } from '@kit.ArkUI';
import { CITY_ROUTES, TravelRoute, ScenicSpot } from '../../models/RouteData';
import { MapComponent, map, mapCommon } from '@kit.MapKit';
import type { AsyncCallback } from '@kit.BasicServicesKit';
import { common, Want} from '@kit.AbilityKit';
import { LocationManager, RealLocation } from '../../services/LocationManager';
import { hilog } from '@kit.PerformanceAnalysisKit';

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
  @StorageLink('currentCity') @Watch('onCityChange') currentCity: string = '北京市';

  @State route: TravelRoute = {
    routeName: '加载中...',
    spots: [{ name: '初始地点', address: '获取定位中', latitude: 30.5, longitude: 114.3 }]
  };

  @State currentIndex: number = 0;
  @State isAutoCheck: boolean = true;
  @State themeColor: string = '#FF9500';
  @State isFullScreenMap: boolean = false;

  @State mapCameraPosition: mapCommon.CameraPosition = {
    target: { latitude: 30.5, longitude: 114.3 },
    zoom: 14,
    tilt: 0,
    bearing: 0
  };

  private mapController?: map.MapComponentController;
  private context = getContext(this) as common.UIAbilityContext;
  private realLocation: RealLocation | null = null;
  private refreshTimer?: number;

  onCityChange() {
    console.info(`[Guide] 监测到城市切换至: ${this.currentCity}`);
    this.currentIndex = 0;
    this.matchRouteByCity();
    this.moveMapToSpot(0);
  }

  async aboutToAppear() {
    this.initializeData();

    try {
      this.realLocation = await LocationManager.getLocation(this.context);
    } catch (e) {
      console.warn('[Guide] 定位失败', e);
    }

    this.startAutoRefreshLocation();
  }

  aboutToDisappear() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = undefined;
    }
  }

  initializeData() {
    const params = router.getParams() as Record<string, TravelRoute>;
    if (params && params['route']) {
      this.route = params['route'];
    } else {
      this.matchRouteByCity();
    }
    this.moveMapToSpot(this.currentIndex);
  }

  matchRouteByCity() {
    if (CITY_ROUTES[this.currentCity]?.length) {
      this.route = CITY_ROUTES[this.currentCity][0];
    } else {
      this.route = CITY_ROUTES['北京市'][0];
    }
  }

  moveMapToSpot(index: number) {
    const spot = this.route.spots[index];
    if (!spot?.latitude || !spot?.longitude) return;

    const target: mapCommon.LatLng = {
      latitude: spot.latitude!,
      longitude: spot.longitude!
    };

    if (this.mapController) {
      this.mapController.animateCamera(map.newCameraPosition({ target, zoom: 16.5, tilt: 45 }), 500);
    } else {
      this.mapCameraPosition.target = target;
      this.mapCameraPosition.zoom = 17.5;
    }

    this.refreshMapElements();
  }

  private callback: AsyncCallback<map.MapComponentController> = (err, controller) => {
    if (err) {
      hilog.error(0x0000, 'MapStatus', 'MapComponent load failed: %{public}d', err.code);
      promptAction.showToast({ message: `地图加载失败: ${err.code}` });
      return;
    }

    if (controller) {
      this.mapController = controller;
      hilog.info(0x0000, 'MapStatus', 'MapController ready. Enabling Traffic and Layers...');

      this.mapController.setTrafficEnabled(true);
      this.mapController.setBuildingEnabled(true);
      this.mapController.setMapType(1);
      this.mapController.setMyLocationEnabled(true);
      this.refreshMapElements();

      setTimeout(() => {
        hilog.info(0x0000, 'MapStatus', 'If map is still blank, check SHA256 and JSON file.');
      }, 2000);

      hilog.info(0x0000, 'MapStatus', '地图控制器初始化完成');
    }
  };


  private refreshMapElements() {
    if (!this.mapController) return;
    this.mapController.clear();

    const path = this.route.spots
      .filter(s => s.latitude && s.longitude)
      .map((s): mapCommon.LatLng => ({ latitude: s.latitude!, longitude: s.longitude! }));

    if (path.length > 1) {
      this.mapController.addPolyline({ points: path, width: 10, color: 0xffFF9500 });
    }

    const cur = this.route.spots[this.currentIndex];
    if (cur?.latitude && cur?.longitude) {
      this.mapController.addMarker({
        position: { latitude: cur.latitude, longitude: cur.longitude },
        title: cur.name
      });
    }
  }

  async handleAction() {
    if (!this.isAutoCheck || !this.realLocation) {
      this.proceedToCheckIn();
      return;
    }

    const target = this.route.spots[this.currentIndex];
    const distance = this.getDistance(
      this.realLocation.latitude,
      this.realLocation.longitude,
      target.latitude,
      target.longitude
    );

    if (distance <= 200) {
      this.proceedToCheckIn();
    } else {
      promptAction.showDialog({
        title: '未进入打卡范围',
        message: `您当前距离目的地 ${Math.round(distance)} 米`,
        buttons: [
          { text: '强制打卡', color: '#FF4500' },
          { text: '继续前往', color: '#666' }
        ]
      }).then(res => {
        if (res.index === 0) this.proceedToCheckIn();
      });
    }
  }

  getDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371000;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) ** 2 + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLon / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }

  proceedToCheckIn() {
    if (this.currentIndex < this.route.spots.length - 1) {
      this.currentIndex++;
      this.moveMapToSpot(this.currentIndex);
      promptAction.showToast({ message: '打卡成功！' });
    } else {
      promptAction.showDialog({
        title: '旅程终点',
        message: '恭喜！您已完成本路线',
        buttons: [{ text: '返回', color: this.themeColor }]
      }).then(() => router.replaceUrl({ url: 'pages/Index' }));
    }
  }

  async startExternalNavi(spot: ScenicSpot) {
    let want: Want = {
      action: 'ohos.want.action.viewData',
      uri: `geo:${spot.latitude},${spot.longitude}?q=${encodeURIComponent(spot.name)}`
    };
    try {
      await this.context.startAbility(want);
    } catch {
      promptAction.showToast({ message: '未检测到地图应用' });
    }
  }

  private startAutoRefreshLocation() {
    if (this.refreshTimer) clearInterval(this.refreshTimer);
    this.refreshTimer = setInterval(async () => {
      try {
        const loc = await LocationManager.getLocation(this.context);
        this.realLocation = loc;
      } catch {}
    }, 30000);
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        MapComponent({
          mapOptions: { position: this.mapCameraPosition },
          mapCallback: this.callback
        }).width('100%').height(this.isFullScreenMap ? '100%' : '45%')
          .animation({ duration: 300, curve: Curve.EaseInOut })
      }.zIndex(1)

      Scroll() {
        Column() {
          Column() {
            Row() {
              Text('下一站').fontSize(12).fontColor('#999').padding(4).backgroundColor('#F5F5F5').borderRadius(4)
              Blank()
              Row() {
                Text('自动校验').fontSize(12).fontColor('#999')
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
              Button('外部导航').layoutWeight(1).height(45).backgroundColor('#333')
                .onClick(() => this.startExternalNavi(this.route.spots[this.currentIndex]))

              Button(this.currentIndex === this.route.spots.length - 1 ? '全程完成' : '到达打卡')
                .layoutWeight(1).height(45).backgroundColor(this.themeColor)
                .onClick(() => this.handleAction())
            }
          }
          .width('100%').padding(20).backgroundColor('#FFF').borderRadius(20).shadow({ radius: 20, color: '#1A000000' })

          Text('路线清单').width('100%').margin({ top: 30, bottom: 15 }).fontSize(16).fontWeight(FontWeight.Bold)

          List({ space: 10 }) {
            ForEach(this.route.spots, (spot: ScenicSpot, index: number) => {
              ListItem() {
                Row() {
                  Column() {
                    Circle({ width: 10, height: 10 })
                      .fill(index === this.currentIndex ? this.themeColor : (index < this.currentIndex ? '#999' : '#DDD'))
                    if (index !== this.route.spots.length - 1) { Rect().width(1).height(30).fill('#EEE') }
                  }.width(20)

                  Text(spot.name).fontSize(14).fontColor(index === this.currentIndex ? '#333' : (index < this.currentIndex ? '#CCC' : '#666'))
                    .decoration({ type: index < this.currentIndex ? TextDecorationType.LineThrough : TextDecorationType.None })
                    .layoutWeight(1)
                    .onClick(() => {
                      this.currentIndex = index;
                      this.moveMapToSpot(index);
                    })

                  if (index < this.currentIndex) {
                    SymbolGlyph($r('sys.symbol.checkmark_circle_fill')).fontColor([this.themeColor]).fontSize(18)
                  }
                }.width('100%').padding({ left: 10, right: 10 })
              }
            })
          }.layoutWeight(1).edgeEffect(EdgeEffect.Spring).width('100%')
        }
      }
      .zIndex(2)
      .translate({ y: this.isFullScreenMap ? 1000 : 0 })
      .animation({ duration: 400, curve: Curve.FastOutSlowIn })
      .margin({ top: 220 }).padding(20).width('100%').height('100%').backgroundColor('#F7F7F7').borderRadius({ topLeft: 30, topRight: 30 })

      Row() {
        Button() { SymbolGlyph($r('sys.symbol.chevron_left')).fontColor(['#333']).fontSize(24) }
        .type(ButtonType.Circle).backgroundColor('#F0F0F0').width(40).height(40)
        .onClick(() => router.back())

        Row() {
          SymbolGlyph($r('sys.symbol.location_north_up_right_and_circle_dotted_fill')).fontColor(['#FF9500']).fontSize(14)
          Text(this.currentCity).fontSize(14).fontWeight(FontWeight.Bold).margin({ left: 4 })
        }
        .margin({ left: 10 }).padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('#CCFFFFFF').borderRadius(20)

        Blank()

        Button(this.isFullScreenMap ? '收起地图' : '展开地图')
          .fontSize(12).backgroundColor('#333').height(30).padding({ left: 10, right: 10 })
          .onClick(() => { this.isFullScreenMap = !this.isFullScreenMap })
      }
      .zIndex(4).position({ x: 0, y: 40 }).width('100%').padding({ left: 20, right: 20 })
    }
    .width('100%').height('100%')
  }
}