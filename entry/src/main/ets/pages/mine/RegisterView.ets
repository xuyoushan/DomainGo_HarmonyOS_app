import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;

  // 模拟登录逻辑
  handleLogin(isGuest: boolean = false) {
    this.isLoading = true;

    // 模拟网络延迟
    setTimeout(() => {
      this.isLoading = false;

      if (isGuest) {
        promptAction.showToast({ message: '以游客身份登录' });
        router.replaceUrl({ url: 'pages/Index' });
        return;
      }

      // 账号密码校验（演示用）
      if (this.username === 'admin' && this.password === '123456') {
        promptAction.showToast({ message: '登录成功' });
        router.replaceUrl({ url: 'pages/Index' });
      } else {
        promptAction.showToast({ message: '账号或密码错误 (admin/123456)' });
      }
    }, 800);
  }

  build() {
    Column({ space: 20 }) {
      Text('欢迎使用 DomainGo')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })

      // 账号输入
      TextInput({ placeholder: '请输入账号 (admin)', text: this.username })
        .height(50)
        .onChange((v) => this.username = v)

      // 密码输入
      TextInput({ placeholder: '请输入密码 (123456)', text: this.password })
        .type(InputType.Password)
        .height(50)
        .onChange((v) => this.password = v)

      // 登录按钮
      Button(this.isLoading ? '登录中...' : '立即登录')
        .width('100%')
        .height(50)
        .enabled(!this.isLoading)
        .onClick(() => this.handleLogin(false))

      // 游客登录链接
      Text('随便逛逛 (游客登录)')
        .fontSize(14)
        .fontColor(Color.Gray)
        .decoration({ type: TextDecorationType.Underline })
        .onClick(() => this.handleLogin(true))

    }
    .padding(30)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}