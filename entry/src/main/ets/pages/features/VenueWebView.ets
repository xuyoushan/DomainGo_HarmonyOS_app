import { webview } from '@kit.ArkWeb'
import { router, promptAction, componentSnapshot } from '@kit.ArkUI'
import { Venue } from '../../models/VenueData'
import { image } from '@kit.ImageKit'
import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'

/* =========================================================
 * 通用 WebView 组件（以后别的页面直接复用）
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

  // ======== 状态（全部有默认值，ArkTS 安全） ========
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

      if (!this.autoCaptureNotified) {
        this.autoCaptureNotified = true
        promptAction.showDialog({
          title: '已自动保存预约凭证',
          message: '你可以在右上角关闭“自动截图保存”功能',
          buttons: [{ text: '知道了', color: '#007DFF' }]
        })
      }
    } catch {
      promptAction.showToast({ message: '保存失败' })
    }
  }

  build() {
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

        Text(this.autoCaptureEnabled ? '自动截图：开' : '自动截图：关')
          .fontSize(12)
          .fontColor(this.autoCaptureEnabled ? '#07C160' : '#999')
          .margin({ right: 12 })
          .onClick(() => {
            this.autoCaptureEnabled = !this.autoCaptureEnabled
            promptAction.showToast({
              message: this.autoCaptureEnabled ? '已开启自动截图' : '已关闭自动截图'
            })
          })

        SymbolGlyph($r('sys.symbol.camera_fill'))
          .fontSize(22)
          .fontColor(['#007DFF'])
          .onClick(() => this.saveToGallery(true))
      }
      .padding(15)
      .backgroundColor(Color.White)

      /* ================= 通用 WebView ================= */
      CommonWebContainer({
        url: this.webUrl
      }).layoutWeight(1)

      /* ================= 底部操作 ================= */
      Row() {
        Button('预约成功，同步到行程安排')
          .width('90%')
          .height(46)
          .backgroundColor('#007DFF')
          .onClick(async () => {

            // ✅ 仅首次预约成功自动截图
            if (
              this.autoCaptureEnabled &&
                !this.firstBookingCaptured
            ) {
              this.firstBookingCaptured = true
              await this.saveToGallery(false)
            }

            router.pushUrl({
              url: 'pages/features/ScheduleView',
              params: {
                presetTitle: `参观：${this.venue.name}`,
                presetLocation: this.venue.address,
                presetDesc: `已预约完成，入馆地址：${this.venue.address}`
              }
            })
          })
      }
      .padding(12)
      .backgroundColor('#F8F8F8')
    }
    .height('100%')
  }
}
