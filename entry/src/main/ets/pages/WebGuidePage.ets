import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebGuidePage {
  @State url: string = '';
  @State title: string = '导览加载中...';
  @State isLoading: boolean = true;
  @State progress: number = 0;
  // 初始化 Web 控制器
  controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear() {
    // 获取跳转传参
    const params = router.getParams() as Record<string, string>;
    if (params && params.url) {
      this.url = params.url;
      this.title = params.title || '位置导览';
    }
  }

  build() {
    Column() {
      // --- 1. 顶部导航栏 ---
      Row() {
        // 返回图标：处理网页回退逻辑
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .fontColor(['#333'])
          .onClick(() => {
            if (this.controller.accessBackward()) {
              this.controller.backward();
            } else {
              router.back();
            }
          })

        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12 })
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 刷新按钮
        SymbolGlyph($r('sys.symbol.arrow_clockwise'))
          .fontSize(20)
          .onClick(() => this.controller.refresh())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 40, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F2F2F2' })

      // --- 2. 进度条 (消除白屏焦虑) ---
      if (this.isLoading) {
        Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(2)
          .color('#FF9500')
      }

      // --- 3. Web 组件核心区域 ---
      Stack() {
        if (this.url) {
          Web({ src: this.url, controller: this.controller })
            .width('100%')
            .height('100%')
            .domStorageAccess(true)     // 允许存储，地图必需
            .javaScriptAccess(true)     // 允许JS，地图必需
            .fileAccess(true)
            .imageAccess(true)
            .onlineImageAccess(true)
            // ✅ 修复报错：使用数字 2 代表 All 模式，或者使用正确的枚举全称
            .mixedMode(2)            .onProgressChange((event) => {
              if (event) {
                this.progress = event.newProgress;
                if (this.progress === 100) {
                  this.isLoading = false;
                }
              }
            })
            .onErrorReceive((event) => {
              if (event) {
                console.error('WebPage Error: ' + event.error.getErrorInfo());
              }
            })
            .onConsole((event) => {
              console.info('Web Console: ' + event?.message.getMessage());
              return false;
            })
        }

        // 加载占位图
        if (this.isLoading && this.progress < 20) {
          Column() {
            LoadingProgress().width(50).height(50).color('#FF9500')
            Text('正在规划避堵路线...').margin({ top: 12 }).fontColor('#999').fontSize(14)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}