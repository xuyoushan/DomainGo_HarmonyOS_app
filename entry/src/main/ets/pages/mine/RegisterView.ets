import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

// 1. 初始化持久化存储，确保数据存储在磁盘上 (必须在组件定义外初始化)
// 键名 'userName' 和 'isLoggedIn' 需要与 MineView 中的 @StorageLink 保持一致
PersistentStorage.persistProp('userName', '点击注册/登录');
PersistentStorage.persistProp('isLoggedIn', false);
PersistentStorage.persistProp('userPhone', '');

@Entry
@Component
struct RegisterView {
  @State username: string = '';
  @State phone: string = '';
  @State verifyCode: string = '';
  @State countdown: number = 0; // 验证码倒计时秒数
  private timerId: number = -1;

  // 绑定全局持久化状态
  @StorageLink('userName') storedName: string = '';
  @StorageLink('isLoggedIn') loggedIn: boolean = false;
  @StorageLink('userPhone') storedPhone: string = '';

  // 倒计时逻辑函数
  startCountdown() {
    if (this.phone.length < 11) {
      promptAction.showToast({ message: '请输入正确的手机号' });
      return;
    }

    if (this.countdown <= 0) {
      this.countdown = 60;
      this.timerId = setInterval(() => {
        if (this.countdown <= 0) {
          clearInterval(this.timerId);
        } else {
          this.countdown--;
        }
      }, 1000);
      promptAction.showToast({ message: '验证码已发送' });
    }
  }

  // 组件销毁前清除定时器
  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 底层：沉浸式科技感地图背景
      Image($r('app.media.map_china_tech'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 背景遮罩
      Rect()
        .width('100%')
        .height('100%')
        .fill('rgba(0, 0, 0, 0.4)')

      // 顶层内容容器
      Column() {
        // 自定义导航栏
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(28)
            .fontColor(['#FFFFFF'])
            .onClick(() => router.back())

          Text('加入寻域')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ left: 15 })
            .textShadow({ radius: 5, color: '#80000000' })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 50, bottom: 20 })
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#CC000000', 0.0], ['#00000000', 1.0]]
        })

        Blank().layoutWeight(1)

        // 注册表单卡片
        Column({ space: 15 }) {
          Text('开启你的探索之旅')
            .fontSize(20)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 5 })

          // 1. 昵称输入
          this.InputBox('sys.symbol.person', '设置你的探险者昵称', (v) => this.username = v)

          // 2. 手机号输入 + 验证码按钮
          Stack({ alignContent: Alignment.End }) {
            this.InputBox('sys.symbol.phone', '输入手机号', (v) => this.phone = v)

            Text(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
              .fontSize(14)
              .fontColor(this.countdown > 0 ? '#99FFFFFF' : '#007DFF')
              .fontWeight(FontWeight.Medium)
              .margin({ right: 15 })
              .onClick(() => this.startCountdown())
          }

          // 3. 验证码输入
          this.InputBox('sys.symbol.lock', '输入 4 位验证码', (v) => this.verifyCode = v)

          // 注册按钮
          Button('立即启程')
            .width('100%')
            .height(55)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#007DFF')
            .borderRadius(15)
            .margin({ top: 10 })
            .onClick(() => {
              if (this.username && this.phone && this.verifyCode) {
                // 保存数据到持久化存储
                this.storedName = this.username;
                this.storedPhone = this.phone;
                this.loggedIn = true;

                promptAction.showToast({ message: '欢迎加入，探险家！' });
                router.back();
              } else {
                promptAction.showToast({ message: '请完善所有信息' });
              }
            })

          Text('注册即代表同意《寻域用户协议与隐私政策》')
            .fontSize(12)
            .fontColor('#99FFFFFF')
            .margin({ top: 5 })
        }
        .width('92%')
        .padding(25)
        .margin({ bottom: 80 })
        .backgroundColor('#F21A1A1A')
        .borderRadius(24)
        .border({ width: 1, color: '#40FFFFFF' })
      }
      .width('100%')
      .height('100%')
    }
  }

  // 自定义输入框样式
  @Builder
  InputBox(icon: string, hint: string, callback: (v: string) => void) {
    Row() {
      SymbolGlyph($r(icon))
        .fontSize(22)
        .fontColor(['#CCFFFFFF'])
        .margin({ left: 15, right: 10 })

      TextInput({ placeholder: hint })
        .placeholderColor('#66FFFFFF')
        .fontColor('#FFFFFF')
        .backgroundColor(Color.Transparent)
        .layoutWeight(1)
        .onChange(callback)
    }
    .width('100%')
    .height(60)
    .backgroundColor('#33FFFFFF')
    .borderRadius(15)
  }
}