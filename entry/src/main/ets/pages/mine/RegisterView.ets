import { router, promptAction } from '@kit.ArkUI';
import { postRepo } from '../../services/PostRepository';
import { UserInfo } from '../../models/PostItem';

@Entry
@Component
struct RegisterView {
  @State isLoginMode: boolean = true;
  @State username: string = '';
  @State email: string = '';
  @State verifyCodeInput: string = '';
  @State password: string = '';
  @State generatedCode: string = '';
  @State countdown: number = 0;
  private timer: number = -1;

  async aboutToAppear() {
    await postRepo.init(getContext(this));
  }

  getVerifyCode() {
    if (this.email.length === 0 || !this.email.includes('@')) {
      promptAction.showToast({ message: '请输入有效的邮箱地址' });
      return;
    }
    if (this.countdown > 0) return;

    this.generatedCode = Math.floor(Math.random() * 900000 + 100000).toString();

    promptAction.showDialog({
      title: '验证码已发送',
      message: `【DomainGo】您的验证码是：${this.generatedCode}`,
      buttons: [{ text: '我知道了', color: '#007DFF' }]
    });

    this.countdown = 60;
    this.timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(this.timer);
        this.generatedCode = ''; // 过期后清空
      }
    }, 1000);
  }

  async handleRegister() {
    if (!this.username || !this.email || !this.verifyCodeInput || !this.password) {
      promptAction.showToast({ message: '请完善注册信息' });
      return;
    }

    if (this.verifyCodeInput !== this.generatedCode) {
      promptAction.showToast({ message: '验证码错误或已过期' });
      return;
    }

    const newUser: UserInfo = {
      id: '', // 由 Repository 生成 DGxxxx 格式
      username: this.username,
      email: this.email,
      password: this.password,
      avatar: 'ic_mine_active'
    };

    try {
      await postRepo.registerUser(newUser);
      AppStorage.setOrCreate('isLoggedIn', true);
      AppStorage.setOrCreate('userName', this.username);
      const user = await postRepo.checkUser(this.username, this.password);
      if(user) AppStorage.setOrCreate('currentUserId', user.id);

      promptAction.showToast({ message: '欢迎加入 DomainGo！' });
      router.replaceUrl({ url: 'pages/Index' });
    } catch (e) {
      promptAction.showToast({ message: '注册失败，用户名可能已存在' });
    }
  }

  async handleLogin() {
    const user = await postRepo.checkUser(this.username, this.password);
    if (user) {
      AppStorage.setOrCreate('isLoggedIn', true);
      AppStorage.setOrCreate('userName', user.username);
      AppStorage.setOrCreate('currentUserId', user.id); // 确保是 string
      router.replaceUrl({ url: 'pages/Index' });
    } else {
      promptAction.showToast({ message: '账号或密码错误' });
    }
  }

  async handleAmapLogin() {
    promptAction.showToast({ message: '正在唤起高德地图授权...' });

    const amapNickName = "高德探险家_" + Math.floor(Math.random()*100);
    const amapUser: UserInfo = {
      id: '', // 自动生成 DG ID
      username: amapNickName,
      email: 'amap_user@auto.com',
      avatar: 'ic_mine_active'
    };

    await postRepo.registerUser(amapUser); // 自动注册/记录
    AppStorage.setOrCreate('isLoggedIn', true);
    AppStorage.setOrCreate('userName', amapNickName);
    router.replaceUrl({ url: 'pages/Index' });
  }

  build() {
    Column() {
      Text('DomainGo')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#007DFF')
        .margin({ top: 80, bottom: 8 })

      Text(this.isLoginMode ? '发现属于你的域' : '开启探险之旅')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ bottom: 40 })

      Column({ space: 15 }) {
        TextInput({ placeholder: '用户名', text: this.username })
          .height(52).backgroundColor('#F5F7F9').borderRadius(12)
          .onChange((v) => this.username = v)

        if (!this.isLoginMode) {
          TextInput({ placeholder: '邮箱地址', text: this.email })
            .height(52).backgroundColor('#F5F7F9').borderRadius(12)
            .onChange((v) => this.email = v)

          Row() {
            TextInput({ placeholder: '验证码', text: this.verifyCodeInput })
              .height(52).layoutWeight(1).backgroundColor('#F5F7F9').borderRadius(12)
              .onChange((v) => this.verifyCodeInput = v)

            Button(this.countdown > 0 ? `${this.countdown}s` : '获取')
              .height(52).width(80).margin({ left: 10 }).borderRadius(12)
              .backgroundColor(this.countdown > 0 ? '#EEEEEE' : '#007DFF')
              .fontColor(this.countdown > 0 ? '#999999' : '#FFFFFF')
              .onClick(() => this.getVerifyCode())
          }

          // 【修复 1】：验证码防忘显示区
          if (this.generatedCode) {
            Text(`当前有效验证码：${this.generatedCode}`)
              .fontSize(12).fontColor('#007DFF').alignSelf(ItemAlign.Start).margin({ left: 5 })
          }
        }

        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password).height(52).backgroundColor('#F5F7F9').borderRadius(12)
          .onChange((v) => this.password = v)

        Button(this.isLoginMode ? '进入 DomainGo' : '立即注册并探索')
          .width('100%').height(52).fontSize(18).borderRadius(12).margin({ top: 15 })
          .onClick(() => this.isLoginMode ? this.handleLogin() : this.handleRegister())

        Row() {
          Text(this.isLoginMode ? '新用户注册' : '返回登录')
            .fontSize(14).fontColor('#666666')
            .onClick(() => {
              animateTo({ duration: 300 }, () => this.isLoginMode = !this.isLoginMode )
            })
          Blank()
          Text('游客模式 >').fontSize(14).fontColor('#999999')
            .onClick(() => {
              AppStorage.setOrCreate('userName', '游客探险员');
              router.replaceUrl({ url: 'pages/Index' });
            })
        }.width('100%')

        // 【修复 3】：第三方登录入口
        Column() {
          Text('其他方式登录').fontSize(12).fontColor('#CCCCCC').margin({ top: 40, bottom: 15 })
          Row({ space: 30 }) {
            // 这里放一个类似高德地图的图标
            Image($r('app.media.map_china_tech')) // 暂用地图图标替代
              .width(40).height(40).borderRadius(20)
              .onClick(() => this.handleAmapLogin())

            SymbolGlyph($r('sys.symbol.phone_fill'))
              .fontSize(30).fontColor(['#999999'])
              .onClick(() => promptAction.showToast({ message: '手机号功能维护中' }))
          }
        }
      }
      .width('100%').padding(30)
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF')
  }
}