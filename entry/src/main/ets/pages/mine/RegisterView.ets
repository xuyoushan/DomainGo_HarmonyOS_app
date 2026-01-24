import { router, promptAction } from '@kit.ArkUI';

// 定义用户接口
interface UserInfo {
  username: string;
  email: string;
  password: string;
}

@Entry
@Component
struct LoginPage {
  // --- 核心状态 ---
  @State isLoginMode: boolean = true; // true: 登录模式, false: 注册模式

  // --- 输入框数据 ---
  @State username: string = '';
  @State email: string = '';
  @State verifyCodeInput: string = ''; // 用户输入的验证码
  @State password: string = '';

  // --- 验证码逻辑 ---
  @State generatedCode: string = '';   // 系统生成的正确验证码
  @State countdown: number = 0;        // 倒计时
  private timer: number = -1;

  // --- 模拟数据库 (使用 AppStorage 模拟已注册用户列表，保证本次运行内有效) ---
  @StorageLink('mockUserDB') userList: UserInfo[] = [
    { username: 'admin', email: 'admin@domaingo.com', password: '123456' }
  ];

  // 1. 获取验证码逻辑
  getVerifyCode() {
    if (this.email.length === 0 || !this.email.includes('@')) {
      promptAction.showToast({ message: '请输入有效的邮箱地址' });
      return;
    }

    // 检查倒计时
    if (this.countdown > 0) return;

    // 生成6位随机验证码
    this.generatedCode = Math.floor(Math.random() * 900000 + 100000).toString();

    // 模拟发送（在弹窗显示，方便调试）
    promptAction.showDialog({
      title: '邮件已发送',
      message: `【DomainGo】您的验证码是：${this.generatedCode}\n请在5分钟内完成注册。`,
      buttons: [{ text: '我知道了', color: '#007DFF' }]
    });

    // 启动60秒倒计时
    this.countdown = 60;
    this.timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(this.timer);
      }
    }, 1000);
  }

  // 2. 注册逻辑
  handleRegister() {
    // A. 基础非空检查
    if (!this.username || !this.email || !this.verifyCodeInput || !this.password) {
      promptAction.showToast({ message: '请完善注册信息' });
      return;
    }

    // B. 用户名唯一性检查
    const isUserExist = this.userList.some(u => u.username === this.username);
    if (isUserExist) {
      promptAction.showToast({ message: '该用户名已被注册，请更换' });
      return;
    }

    // C. 验证码检查
    if (this.verifyCodeInput !== this.generatedCode) {
      promptAction.showToast({ message: '验证码错误' });
      return;
    }

    // D. 注册成功：存入模拟数据库
    const newUser: UserInfo = {
      username: this.username,
      email: this.email,
      password: this.password
    };

    // 更新存储列表
    this.userList.push(newUser); // AppStorage会自动更新

    promptAction.showToast({ message: '注册成功，请登录' });

    // 切换回登录模式并自动填充用户名
    this.isLoginMode = true;
    this.password = ''; // 清空密码确保安全
    this.verifyCodeInput = '';
  }

  // 3. 登录逻辑
  handleLogin() {
    // 游客登录
    if (this.username === '' && this.password === '') {
      // 如果没填账号密码，视作游客？或者保持原有的游客按钮逻辑
    }

    // 在模拟数据库中查找用户
    const targetUser = this.userList.find(
      u => (u.username === this.username || u.email === this.username) && u.password === this.password
    );

    if (targetUser) {
      promptAction.showToast({ message: `欢迎回来，${targetUser.username}` });

      // 保存登录状态到全局
      AppStorage.setOrCreate('isLoggedIn', true);
      AppStorage.setOrCreate('userName', targetUser.username);

      router.replaceUrl({ url: 'pages/Index' });
    } else {
      promptAction.showToast({ message: '账号或密码错误' });
    }
  }

  // 游客模式
  handleGuestLogin() {
    promptAction.showToast({ message: '以游客身份登录' });
    AppStorage.setOrCreate('isLoggedIn', false);
    AppStorage.setOrCreate('userName', '游客');
    router.replaceUrl({ url: 'pages/Index' });
  }

  build() {
    Column() {
      // 顶部标题
      Text('DomainGo')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#007DFF')
        .margin({ top: 60, bottom: 10 })

      Text(this.isLoginMode ? '账号登录' : '新用户注册')
        .fontSize(20)
        .fontColor('#666666')
        .margin({ bottom: 40 })

      Column({ space: 15 }) {

        // --- 公共输入：用户名 ---
        TextInput({ placeholder: this.isLoginMode ? '请输入用户名/邮箱' : '设置唯一用户名', text: this.username })
          .height(50)
          .backgroundColor('#F5F7F9')
          .borderRadius(8)
          .onChange((v) => this.username = v)

        // --- 注册独有字段：邮箱 ---
        if (!this.isLoginMode) {
          TextInput({ placeholder: '请输入电子邮箱', text: this.email })
            .height(50)
            .backgroundColor('#F5F7F9')
            .borderRadius(8)
            .type(InputType.Email)
            .onChange((v) => this.email = v)

          // --- 注册独有字段：验证码 ---
          Row() {
            TextInput({ placeholder: '6位验证码', text: this.verifyCodeInput })
              .height(50)
              .layoutWeight(1)
              .backgroundColor('#F5F7F9')
              .borderRadius(8)
              .maxLength(6)
              .type(InputType.Number)
              .onChange((v) => this.verifyCodeInput = v)

            Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
              .height(50)
              .width(120)
              .margin({ left: 10 })
              .fontSize(14)
              .backgroundColor(this.countdown > 0 ? '#CCCCCC' : '#007DFF')
              .enabled(this.countdown === 0)
              .onClick(() => this.getVerifyCode())
          }
          .width('100%')
        }

        // --- 公共输入：密码 ---
        TextInput({ placeholder: '请输入密码', text: this.password })
          .type(InputType.Password)
          .height(50)
          .backgroundColor('#F5F7F9')
          .borderRadius(8)
          .onChange((v) => this.password = v)

        // --- 提交按钮 ---
        Button(this.isLoginMode ? '登 录' : '注 册')
          .width('100%')
          .height(50)
          .fontSize(18)
          .margin({ top: 20 })
          .onClick(() => {
            if (this.isLoginMode) {
              this.handleLogin();
            } else {
              this.handleRegister();
            }
          })

        // --- 模式切换与游客入口 ---
        Row() {
          Text(this.isLoginMode ? '还没有账号？去注册' : '已有账号？去登录')
            .fontSize(14)
            .fontColor('#007DFF')
            .onClick(() => {
              // 切换模式动画效果
              animateTo({ duration: 300 }, () => {
                this.isLoginMode = !this.isLoginMode;
                // 清空敏感数据
                this.password = '';
                this.verifyCodeInput = '';
              })
            })

          Blank()

          Text('游客随便逛逛 >')
            .fontSize(14)
            .fontColor('#999999')
            .onClick(() => this.handleGuestLogin())
        }
        .width('100%')
        .margin({ top: 10 })
      }
      .width('100%')
      .padding(30)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Start) // 靠上布局，避免键盘遮挡
  }
}