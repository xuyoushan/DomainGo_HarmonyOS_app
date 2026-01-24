// pages/CityHistoryPage.ets
import { CITY_EXPLORE_MAP, HistoryNode } from '../../models/HistoryData'
import { StarChartProvider, StarDust, VisualNode } from '../../services/StarChartUtils'
import vibrator from '@ohos.vibrator';

@Entry
@Component
struct CityHistoryPage {
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  @State historyNodes: VisualNode[] = []
  @State starDusts: StarDust[] = []
  // [优化] 使用 StorageLink 自动同步 ExploreView 传来的城市名，无需手动 initLocation
  @StorageLink('currentCity') currentCity: string = '定位中...'
  @State canvasWidth: number = 0
  @State canvasHeight: number = 1800
  @State screenHeight: number = 0
  @State pathOffset: number = 0
  @State isShowCard: boolean = false
  @State selectedNode: VisualNode | null = null
  @State selectedIndex: number = -1

  @State clickX: number = 0
  @State clickY: number = 0
  @State nodeOpacity: number[] = []
  @State cardOffsetX: number = 0

  private timerId: number = -1
  private scroller: Scroller = new Scroller()

  aboutToDisappear() {
    if (this.timerId !== -1) clearInterval(this.timerId);
  }

  // 统一数据初始化入口
  initUniverse() {
    // 🔹 关键修正：必须使用处理后的 cityName 匹配字典，否则“武汉市”查不到数据
    const cityName = this.currentCity.replace('市', '');
    const rawData = CITY_EXPLORE_MAP[cityName];

    if (this.canvasWidth > 0 && rawData) {
      this.historyNodes = StarChartProvider.generateStarNodes(rawData, this.canvasWidth, this.canvasHeight);
      this.starDusts = StarChartProvider.generateStarDust(40, this.canvasWidth, this.canvasHeight);

      this.nodeOpacity = new Array(this.historyNodes.length).fill(0);
      this.historyNodes.forEach((_, i) => {
        setTimeout(() => {
          animateTo({ duration: 800, curve: Curve.EaseOut }, () => {
            this.nodeOpacity[i] = 1;
          })
        }, i * 150);
      });

      if (this.timerId !== -1) clearInterval(this.timerId);
      this.startAnimation();
    } else {
      // 无数据时执行清理，停止动画并清空画布
      this.historyNodes = [];
      this.starDusts = [];
      if (this.timerId !== -1) clearInterval(this.timerId);
      this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    }
  }

  startAnimation() {
    this.timerId = setInterval(() => {
      this.pathOffset += 0.003;
      if (this.pathOffset > 1) this.pathOffset = 0;
      this.drawAll();
    }, 30)
  }

  drawAll() {
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 绘制中央虚线
    this.context.setLineDash([15, 30]);
    this.context.strokeStyle = 'rgba(255, 255, 255, 0.08)';
    this.context.beginPath();
    this.context.moveTo(this.canvasWidth/2, 0);
    this.context.lineTo(this.canvasWidth/2, this.canvasHeight);
    this.context.stroke();
    this.context.setLineDash([]);

    // 绘制时空经纬网背景
    this.context.beginPath();
    this.context.strokeStyle = 'rgba(255, 255, 255, 0.08)';
    this.context.lineWidth = 0.5;
    for(let x=0; x<this.canvasWidth; x+=50) {
      this.context.moveTo(x, 0); this.context.lineTo(x, this.canvasHeight);
    }
    for(let y=0; y<this.canvasHeight; y+=50) {
      this.context.moveTo(0, y); this.context.lineTo(this.canvasWidth, y);
    }
    this.context.stroke();

    // 绘制粒子
    this.starDusts.forEach(dust => {
      dust.x += dust.vx; dust.y += dust.vy;
      this.context.fillStyle = `rgba(255, 255, 255, ${dust.opacity})`;
      this.context.beginPath();
      this.context.arc(dust.x, dust.y, dust.size, 0, Math.PI * 2);
      this.context.fill();
    });

    if (this.historyNodes.length < 2) return;
    this.drawMainPath();
    this.drawFlowParticles();
  }

  drawMainPath() {
    this.context.beginPath();
    this.context.lineWidth = 2.5;
    let grad = this.context.createLinearGradient(0, 0, 0, this.canvasHeight);
    grad.addColorStop(0, 'rgba(201, 160, 99, 0.3)');
    grad.addColorStop(1, 'rgba(0, 125, 255, 0.3)');
    this.context.strokeStyle = grad;

    this.context.moveTo(this.historyNodes[0].screenX!, this.historyNodes[0].screenY!);
    for (let i = 0; i < this.historyNodes.length - 1; i++) {
      const p0 = this.historyNodes[i];
      const p1 = this.historyNodes[i+1];
      const cpY = (p0.screenY! + p1.screenY!) / 2;
      this.context.bezierCurveTo(p0.screenX!, cpY, p1.screenX!, cpY, p1.screenX!, p1.screenY!);
    }
    this.context.stroke();
  }

  drawFlowParticles() {
    const t = this.pathOffset;
    const total = this.historyNodes.length - 1;
    const segment = Math.floor(t * total);
    const localT = (t * total) % 1;
    if (segment >= total) return;
    const p0 = this.historyNodes[segment];
    const p1 = this.historyNodes[segment+1];
    const cpY = (p0.screenY! + p1.screenY!) / 2;
    const x = Math.pow(1-localT,3)*p0.screenX! + 3*Math.pow(1-localT,2)*localT*p0.screenX! + 3*(1-localT)*Math.pow(localT,2)*p1.screenX! + Math.pow(localT,3)*p1.screenX!;
    const y = Math.pow(1-localT,3)*p0.screenY! + 3*Math.pow(1-localT,2)*localT*cpY + 3*(1-localT)*Math.pow(localT,2)*cpY + Math.pow(localT,3)*p1.screenY!;

    this.context.shadowBlur = 15;
    this.context.shadowColor = '#FFF';
    this.context.fillStyle = '#FFF';
    this.context.beginPath();
    this.context.arc(x, y, 3, 0, Math.PI * 2);
    this.context.fill();
    this.context.shadowBlur = 0;
  }

  private calcActiveIndexByScroll(scrollY: number): number {
    if (this.historyNodes.length === 0 || this.screenHeight === 0) return -1;
    const viewCenterY = scrollY + (this.screenHeight / 2);
    let nearestIndex = -1;
    let minDist = 250;

    for (let i = 0; i < this.historyNodes.length; i++) {
      const d = Math.abs(this.historyNodes[i].screenY! - viewCenterY);
      if (d < minDist) {
        minDist = d;
        nearestIndex = i;
      }
    }
    return nearestIndex;
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.paper_bg')).width('100%').height('100%').objectFit(ImageFit.Cover).blur(25)

      Column() {
        // [任务1] 保持原逻辑判定标题，绝不省略
        Text(this.currentCity === "定位中..." ? "寻找时空锚点..." : `${this.currentCity} · 历史长卷`)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .letterSpacing(3)
          .shadow({ radius: 8, color: '#000' })
      }
      .width('100%')
      .padding({ top: 60, bottom: 30 })
      .linearGradient({ angle: 180, colors: [['rgba(0,0,0,0.7)', 0], ['transparent', 1]] })
      .zIndex(10)

      // [任务3] 图标颜色加深：0.2->0.5，文字颜色加深：0.8/0.4->1.0/0.6
      if (!CITY_EXPLORE_MAP[this.currentCity.replace('市', '')] && this.currentCity !== "定位中...") {
        Column({ space: 20 }) {
          SymbolGlyph($r('sys.symbol.map_badge_cloud_slash_fill'))
            .fontSize(72)
            .fontColor(['rgba(255,255,255,0.6)']) // 颜色加深

          Column({ space: 8 }) {
            Text("尚未开启城市长卷")
              .fontColor('rgba(255,255,255,1.1)') // 颜色加深
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
            Text("我们会尽快收录该地区的历史足迹")
              .fontColor('rgba(255,255,255,1.0)') // 颜色加深
              .fontSize(14)
          }
        }
        .width('100%')
        .margin({ top: 200 })
        .zIndex(5)
      }

      Scroll(this.scroller) {
        Stack() {
          Canvas(this.context)
            .width('100%')
            .height(this.canvasHeight)
            .onReady(() => {
              this.initUniverse();
            })

          if (this.historyNodes.length > 0) {
            ForEach(this.historyNodes, (item: VisualNode, index: number) => {
              this.NodeBuilder(item, index)
            }, (item: VisualNode) => `${this.currentCity}_${item.id}`)
          }
        }
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .onScroll(() => {
        const currentY = this.scroller.currentOffset().yOffset;
        const index = this.calcActiveIndexByScroll(currentY);
        if (index !== this.selectedIndex && !this.isShowCard) {
          animateTo({ duration: 300 }, () => {
            this.selectedIndex = index;
          })
        }
      })

      if (this.isShowCard) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.4)')
          .onClick(() => {
            animateTo({ duration: 300 }, () => {
              this.isShowCard = false;
              this.selectedNode = null;
              this.selectedIndex = -1;
            })
          })
          .zIndex(90)
      }

      this.FloatingCardBuilder()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0A0E1A')
    // 在 build() 里的 .onAreaChange 修改
    .onAreaChange((old, newValue) => {
      const newWidth = newValue.width as number;
      if (old.width !== newWidth) {
        this.canvasWidth = newWidth;
        // 🔹 新增：宽度确定后，如果当前有城市数据但还没加载，手动触发初始化
        if (newWidth > 0 && this.historyNodes.length === 0) {
          this.initUniverse();
        }
      }
      this.screenHeight = newValue.height as number;
    })
  }

  @Builder NodeBuilder(item: VisualNode, index: number) {
    if (item.screenX !== undefined) {
      Row() {
        Text(item.era).fontSize(14).fontColor(Color.White).fontWeight(FontWeight.Bold).textAlign(TextAlign.End).width(80)

        Stack() {
          Circle({ width: 28, height: 28 }).fill('rgba(255,255,255,0.08)')
            .scale({
              x: (item.status === 'breath' || this.selectedIndex === index) ? 1.3 : 1,
              y: (item.status === 'breath' || this.selectedIndex === index) ? 1.3 : 1
            })
            .animation({ duration: 2500, iterations: -1, curve: Curve.EaseInOut })
          Circle({ width: 12, height: 12 })
            .fill(this.selectedIndex === index ? '#FFF' : item.nodeColor)
            .shadow({ radius: 28, color: item.nodeColor })
        }
        .margin({ left: 12, right: 12 })

        Text(item.year).fontSize(11).fontColor(this.selectedIndex === index ? '#FFF' : '#999').width(80)
      }
      .position({ x: item.screenX! - 92, y: item.screenY! - 12 })
      .opacity(this.nodeOpacity[index])
      .offset({ y: this.nodeOpacity[index] === 1 ? 0 : 40 })
      .onClick(() => {
        this.clickX = item.screenX!; this.clickY = item.screenY!;
        this.selectedIndex = index;

        this.scroller.scrollTo({
          xOffset: 0,
          yOffset: Math.max(item.screenY! - (this.screenHeight / 2), 0),
          animation: { duration: 400, curve: Curve.EaseOut }
        });

        try { vibrator.startVibration({ type: 'time', duration: 35 }, { id: 0, usage: 'alarm' }); } catch (e) {}
        animateTo({ duration: 500, curve: Curve.Friction }, () => {
          this.selectedNode = item;
          this.isShowCard = true;
        })
      })
      .scale({
        x: this.selectedIndex === index ? 1.1 : 1,
        y: this.selectedIndex === index ? 1.1 : 1
      })
      .animation({ duration: 300 })
    }
  }

  @Builder FloatingCardBuilder() {
    if (this.isShowCard && this.selectedNode) {
      Column() {
        Scroll() {
          Column() {
            Image($r(`app.media.${this.selectedNode.image}`)).width('100%').height(220).borderRadius(18).objectFit(ImageFit.Cover)
            Column() {
              Text(this.selectedNode.siteName).fontSize(28).fontWeight(FontWeight.Bolder).fontColor(Color.White)
              Text(`${this.selectedNode.era} | ${this.selectedNode.year}`).fontSize(15).fontColor('#007DFF').margin({ top: 12 })
              Divider().color('rgba(255,255,255,0.1)').margin({ top: 18, bottom: 18 })
              Text(this.selectedNode.description).fontSize(16).fontColor('#EEE').lineHeight(28)
            }.alignItems(HorizontalAlign.Start).padding({ top: 20 })
          }.offset({ x: this.cardOffsetX })
        }.scrollBar(BarState.Off)
      }
      .width('92%').height('62%').padding(25).borderRadius(35)
      .backgroundColor('rgba(15, 15, 25, 0.92)').backgroundBlurStyle(BlurStyle.Thin)
      .shadow({ radius: 60, color: '#000' })
      .position({ x: '4%', y: '20%' })
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionEnd((event) => {
            if (event.offsetX > 60 && this.selectedIndex > 0) this.switchNode(this.selectedIndex - 1);
            else if (event.offsetX < -60 && this.selectedIndex < this.historyNodes.length - 1) this.switchNode(this.selectedIndex + 1);
          })
      )
      .transition(TransitionEffect.asymmetric(
        TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0, y: 0, centerX: this.clickX, centerY: this.clickY })),
        TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.9, y: 0.9 }))
      ))
      .zIndex(100)
    }
  }

  switchNode(index: number) {
    animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
      this.cardOffsetX = index > this.selectedIndex ? -60 : 60;
    })

    setTimeout(() => {
      this.selectedIndex = index;
      this.selectedNode = this.historyNodes[index];

      this.scroller.scrollTo({
        xOffset: 0,
        yOffset: Math.max(this.selectedNode.screenY! - (this.screenHeight / 2), 0),
        animation: { duration: 300, curve: Curve.EaseInOut }
      });

      animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
        this.cardOffsetX = 0;
      })
    }, 200)
  }
}