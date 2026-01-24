import { webview } from '@kit.ArkWeb'
import { router, promptAction, componentSnapshot } from '@kit.ArkUI'
import { Venue } from '../models/VenueData'
import { image } from '@kit.ImageKit'
import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import { notificationManager } from '@kit.NotificationKit';

/* =========================================================
 * 通用 WebView 组件
 * ========================================================= */
@Component
struct CommonWebContainer {
  @Prop url: string
  @Prop onError?: () => void

  controller: webview.WebviewController = new webview.WebviewController()

  @State loading: boolean = true
  @State progress: number = 0
  @State hasError: boolean = false
  @State internalUrl: string = ''

  aboutToAppear() {
    this.internalUrl = this.url
  }

  build() {
    Column() {
      if (this.loading && !this.hasError) {
        Progress({
          value: this.progress,
          total: 100,
          type: ProgressType.Linear
        }).width('100%')
      }

      if (!this.hasError) {
        Web({
          src: this.internalUrl,
          controller: this.controller
        })
          .id('webContainer')
          .width('100%')
          .layoutWeight(1)
          .domStorageAccess(true)
          .javaScriptAccess(true)
          .mixedMode(MixedMode.All)
          .databaseAccess(true)
          .onPageBegin(() => {
            this.loading = true
            this.hasError = false
          })
          .onProgressChange(e => {
            if (e) this.progress = e.newProgress
          })
          .onPageEnd(() => {
            this.loading = false
          })
          .onErrorReceive(() => {
            this.loading = false
            this.hasError = true
            this.onError && this.onError()
          })
      } else {
        Column() {
          Text('网页加载失败').fontSize(16)
          Button('重新加载')
            .margin({ top: 20 })
            .onClick(() => {
              this.hasError = false
              this.internalUrl = ''
              setTimeout(() => {
                this.internalUrl = this.url
              }, 10)
            })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
  }
}

/* =========================================================
 * 业务页面：场馆官网预约
 * ========================================================= */
@Entry
@Component
struct VenueWebView {

  @State venue: Venue = {
    id: '',
    name: '',
    address: '',
    category: '其他',
    description: '',
    needBooking: true
  }

  @State webUrl: string = ''
  @State autoCaptureEnabled: boolean = true
  @State autoCaptureNotified: boolean = false
  @State firstBookingCaptured: boolean = false
  @State screenshotUri: string = '' // ✅ 新增：记录截图路径供行程页使用

  aboutToAppear() {
    const params = router.getParams() as Record<string, Venue>

    if (!params || !params['venue'] || !params['venue'].officialUrl) {
      promptAction.showToast({ message: '场馆信息异常' })
      router.back()
      return
    }

    this.venue = params['venue']
    this.webUrl = params['venue'].officialUrl ?? ''
  }

  /* ================= 功能 1：针对不同分类的特殊提醒横幅 ================= */
  @Builder
  WarningBanner() {
    if (this.venue.category === '学术殿堂' || this.venue.isUniversity) {
      Row() {
        SymbolGlyph($r('sys.symbol.info_circle_fill')).fontColor(['#FF9500']).fontSize(18)
        Text(' 进校需携带身份证，教学区、办公区谢绝参观。')
          .fontSize(12).fontColor('#CC7700').layoutWeight(1)
      }
      .width('100%').padding(10).backgroundColor('#FFF8E1')
    } else if (this.venue.category === '文博馆') {
      Row() {
        SymbolGlyph($r('sys.symbol.clock_fill')).fontColor(['#FF4D4F']).fontSize(18)
        Text(' 大多数纪念馆、博物馆周一闭馆，请留意日期。')
          .fontSize(12).fontColor('#CC3333').layoutWeight(1)
      }
      .width('100%').padding(10).backgroundColor('#FFF1F0')
    }
  }

  /* ================= 保存截图 ================= */
  async saveToGallery(showToast: boolean) {
    const context = getContext(this) as common.UIAbilityContext
    const atManager = abilityAccessCtrl.createAtManager()

    try {
      const grant = await atManager.requestPermissionsFromUser(
        context,
        ['ohos.permission.WRITE_IMAGEVIDEO']
      )

      if (grant.authResults[0] !== 0) {
        promptAction.showToast({ message: '请开启相册写入权限' })
        return
      }

      const pixelMap = await componentSnapshot.get('webContainer')
      const helper = photoAccessHelper.getPhotoAccessHelper(context)
      const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg')
      this.screenshotUri = uri // ✅ 记录 URI

      const file = await fileIo.open(
        uri,
        fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE
      )

      const packer = image.createImagePacker()
      const buffer = await packer.packing(pixelMap, {
        format: 'image/jpeg',
        quality: 98
      })

      await fileIo.write(file.fd, buffer)
      await fileIo.close(file.fd)

      if (showToast) {
        promptAction.showToast({ message: '预约凭证已保存到相册' })
      }

      if (!this.autoCaptureNotified && showToast) {
        this.autoCaptureNotified = true
        promptAction.showDialog({
          title: '凭证已存入相册',
          message: '预约成功后请确保截图包含二维码。',
          buttons: [{ text: '知道了', color: '#007DFF' }]
        })
      }
    } catch {
      promptAction.showToast({ message: '保存失败' })
    }
  }

  /* ================= 预约逻辑：生成动态彩蛋标题 ================= */
  generateSmartTitle(): string {
    if (this.venue.category === '学术殿堂' || this.venue.isUniversity) return `学术探访：${this.venue.name}`;
    if (this.venue.category === '文博馆') return `文博之旅：${this.venue.name}`;
    return `参观：${this.venue.name}`;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        /* ================= 顶部栏 ================= */
        Row() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(22)
            .onClick(() => router.back())

          Text(this.venue.name)
            .fontSize(16)
            .margin({ left: 12 })
            .layoutWeight(1)
            .maxLines(1)

          SymbolGlyph($r('sys.symbol.camera_fill'))
            .fontSize(22)
            .fontColor(['#007DFF'])
            .onClick(() => this.saveToGallery(true))
        }
        .padding(15)
        .backgroundColor(Color.White)

        /* ✅ 功能 1：特殊提醒横幅 */
        this.WarningBanner()

        /* ================= 通用 WebView ================= */
        CommonWebContainer({
          url: this.webUrl
        }).layoutWeight(1)

        /* ================= 底部操作 ================= */
        Column() {
          /* ✅ 功能 2：截图引导提示层 */
          Row() {
            SymbolGlyph($r('sys.symbol.info_circle')).fontSize(14).fontColor(['#999'])
            Text(' 预约成功后请手动截图或点击上方相机存证')
              .fontSize(12).fontColor('#999')
          }.margin({ bottom: 8 })

          Button('我已成功预约，同步到行程')
            .width('90%')
            .height(46)
            .backgroundColor('#007DFF')
            .onClick(async () => {
              // ✅ 功能 3：自动截图与带参跳转
              if (this.autoCaptureEnabled && !this.firstBookingCaptured) {
                this.firstBookingCaptured = true
                await this.saveToGallery(false)
              }

              router.pushUrl({
                url: 'pages/features/ScheduleView',
                params: {
                  presetTitle: this.generateSmartTitle(), // 彩蛋标题
                  presetLocation: this.venue.address,
                  presetDesc: `已预约完成，入馆地址：${this.venue.address}`,
                  evidenceImage: this.screenshotUri // 传递截图凭证
                }
              })
            })
        }
        .padding({ top: 12, bottom: 24 })
        .backgroundColor('#F8F8F8')
      }
      .height('100%')
    }
  }
}