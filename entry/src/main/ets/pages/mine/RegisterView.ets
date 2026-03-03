import { router, promptAction } from '@kit.ArkUI';
import { postRepo } from '../../services/PostRepository';
import { common } from '@kit.AbilityKit';
import { PreferenceManager } from '../../services/PreferenceManager';
import { http } from '@kit.NetworkKit';
import { userRepo } from '../../services/UserRepository';

const BASE_URL = 'https://login-inchnzmmux.cn-hangzhou.fcapp.run';

interface ResponseData { success: boolean;message?: string;}
interface VerifyResponse { success: boolean; message?: string; }
interface CloudUser { _id: string;username: string;email: string;avatar: string;domainId: string; }
interface RegisterResponse {
  success: boolean;
  user?: CloudUser;
  token?: string;
  message?: string;
}
@Entry
@Component
struct RegisterView {
  @State isLoginMode: boolean = true;
  @State username: string = '';
  @State email: string = '';
  @State verifyCodeInput: string = '';
  @State password: string = '';
  @State countdown: number = 0;
  private timer: number = -1;

  async aboutToAppear() {
    await postRepo.init(getContext(this));
  }

  validateUsername(name: string): boolean {
    if (name === '_' || /^\d$/.test(name)) return false;
    const reg = /^[\u4e00-\u9fa5_a-zA-Z0-9]{1,16}$/;
    return reg.test(name);
  }

  async getVerifyCode() {
    if (!this.email || !this.email.includes('@')) {
      promptAction.showToast({ message: '请输入有效的邮箱地址' });
      return;
    }
    if (this.countdown > 0) return;

    let httpRequest = http.createHttp();

    try {
      let response = await httpRequest.request(
        `${BASE_URL}/sendCode`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: { email: this.email },
          connectTimeout: 60000,
          readTimeout: 60000,
        }
      );

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as ResponseData;

        if (!data.success) {
          promptAction.showToast({ message: '验证码发送失败：' + (data.message || '') });
          return;
        }

        promptAction.showToast({ message: '验证码已发送，请检查邮箱' })

        this.countdown = 60;
        this.timer = setInterval(() => {
          this.countdown--;
          if (this.countdown <= 0) {
            clearInterval(this.timer);
          }
        }, 1000);
      } else {
        promptAction.showToast({ message: '服务器响应异常' });
      }
    } catch (err) {
      console.error('Request failed', JSON.stringify(err));
      promptAction.showToast({ message: '网络错误，发送失败' });
    } finally {
      httpRequest.destroy();
    }
  }

  aboutToDisappear() {
    if (this.timer !== -1) clearInterval(this.timer);
  }

  async handleRegister() {
    if (!this.username || !this.email || !this.verifyCodeInput || !this.password) {
      promptAction.showToast({ message: '请完善注册信息' });
      return;
    }

    // 用户名校验
    const nameReg = /^(?!\d$)(?!_$)[\u4e00-\u9fa5_a-zA-Z0-9]{1,16}$/;
    if (!nameReg.test(this.username)) {
      promptAction.showToast({ message: '用户名需1-16位，且不能仅为单个数字或下划线' });
      return;
    }

    // 敏感词校验
    const forbiddenWords = ['管理员', 'admin', '色情', '政治关键词1', '政治关键词2'];
    if (forbiddenWords.some(word => this.username.includes(word))) {
      promptAction.showToast({ message: '用户名包含违规敏感词' });
      return;
    }

    // 密码校验
    if (this.password === this.username) {
      promptAction.showToast({ message: '密码不能与用户名相同' });
      return;
    }
    const pwdReg = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/;
    if (!pwdReg.test(this.password) || this.password === '123456') {
      promptAction.showToast({ message: '密码太弱！需包含字母和数字' });
      return;
    }

    // 邮箱格式校验（支持所有邮箱）
    const emailReg = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailReg.test(this.email)) {
      promptAction.showToast({ message: '请输入有效的邮箱地址' });
      return;
    }

    // 1. 校验验证码
    try {
      const verifyHttp = http.createHttp();
      const response = await verifyHttp.request(
        `${BASE_URL}/verifyCode`,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: { email: this.email, code: this.verifyCodeInput }
        }
      );
      verifyHttp.destroy();

      if (response.responseCode !== 200) {
        promptAction.showToast({ message: '校验服务异常' });
        return;
      }

      const data = JSON.parse(response.result as string) as VerifyResponse;
      if (!data.success) {
        promptAction.showToast({ message: data.message || '验证码错误或已过期' });
        return;
      }
    } catch (err) {
      promptAction.showToast({ message: '验证码校验失败，请检查网络' });
      return;
    }

    // 2. 调用云端注册接口
    try {
      const registerHttp = http.createHttp();
      const response = await registerHttp.request(
        `${BASE_URL}/user/register`,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({
            username: this.username,
            email: this.email,
            password: this.password,
            avatar: 'app.media.start'
          })
        }
      );
      registerHttp.destroy();

      if (response.responseCode !== 200) {
        promptAction.showToast({ message: '服务器异常，请稍后再试' });
        return;
      }

      const result = JSON.parse(response.result as string) as RegisterResponse;
      if (!result.success || !result.user) {
        promptAction.showToast({ message: result.message || '注册失败' });
        return;
      }
      const user: CloudUser = result.user;

      // 3. 写入本地登录状态
      AppStorage.setOrCreate('isLoggedIn', true);
      AppStorage.setOrCreate('userName', user.username);
      AppStorage.setOrCreate('currentUserId', user._id);
      AppStorage.setOrCreate('userAvatar', 'app.media.start');
      AppStorage.setOrCreate('token', result.token);
      AppStorage.setOrCreate('domainId', user.domainId);

      const context = getContext(this) as common.UIAbilityContext;
      await PreferenceManager.put(context, 'isLoggedIn', true);
      await PreferenceManager.put(context, 'currentUserId', user._id);
      await PreferenceManager.put(context, 'userName', user.username);
      await PreferenceManager.put(context, 'userAvatar', 'app.media.start');
      if (user.domainId && user.domainId !== '') {
        AppStorage.setOrCreate('domainId', user.domainId);
        await PreferenceManager.put(context, 'domainId', user.domainId);
      } else {
        console.error("domainId is missing:", user);
      }

      if (result.token) {
        await PreferenceManager.put(context, 'token', result.token);
        AppStorage.setOrCreate('token', result.token);
      }

      promptAction.showToast({ message: '欢迎加入寻域！' });

      animateTo({ duration: 888, curve: Curve.EaseInOut }, () => {
        router.replaceUrl({ url: 'pages/Index' });
      });

    } catch (e) {
      promptAction.showToast({ message: '注册失败，请稍后再试' });
    }
  }


  async checkImageSafety(uri: string): Promise<boolean> {
    return true;
  }

  async handleLogin() {
    if (!this.username || !this.password) {
      promptAction.showToast({ message: '请输入账号和密码' });
      return;
    }

    try {
      const result = await userRepo.login(this.username, this.password);

      if (!result.success || !result.user) {
        promptAction.showToast({ message: result.message || '账号或密码错误' });
        return;
      }

      const user = result.user;

      AppStorage.setOrCreate('isLoggedIn', true);
      AppStorage.setOrCreate('userName', user.username);
      AppStorage.setOrCreate('currentUserId', user._id);
      AppStorage.setOrCreate('domainId', user.domainId);
      AppStorage.setOrCreate('userAvatar', 'app.media.start');
      AppStorage.setOrCreate('token', result.token);


      const context = getContext(this) as common.UIAbilityContext;
      await PreferenceManager.put(context, 'isLoggedIn', true);
      await PreferenceManager.put(context, 'currentUserId', user._id);
      await PreferenceManager.put(context, 'userName', user.username);
      await PreferenceManager.put(context, 'userAvatar', 'app.media.start');
      if (user.domainId && user.domainId !== '') {
        AppStorage.setOrCreate('domainId', user.domainId);
        await PreferenceManager.put(context, 'domainId', user.domainId);
      } else {
        console.error("domainId is missing:", user);
      }
      if (result.token) {
        await PreferenceManager.put(context, 'token', result.token);
        AppStorage.setOrCreate('token', result.token);
      }

      promptAction.showToast({ message: '欢迎回来！' });

      animateTo({ duration: 888, curve: Curve.EaseInOut }, () => {
        router.replaceUrl({ url: 'pages/Index' });
      });

    } catch (err) {
      promptAction.showToast({ message: '登录失败，请检查网络' });
    }
  }

  build() {
    Column() {
      Text('DomainGo')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontFamily('Playfair Display')
        .letterSpacing(1)
        .fontColor('#7A6A45')
        .margin({ top: 80, bottom: 8 })

      Text(this.isLoginMode ? '发现属于你的域' : '开启探险之旅')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ bottom: 40 })

      Column({ space: 15 }) {
        TextInput({ placeholder: this.isLoginMode ? '邮箱地址' : '用户名', text: this.username })
          .height(52)
          .backgroundColor('rgba(255,255,255,0.65)')
          .border({ width: 1, color: '#E6D8C3' })
          .borderRadius(8)
          .shadow({ radius: 6, color: '#20000000' })
          .fontColor('#4A4A4A')
          .onChange((v) => this.username = v)

        if (!this.isLoginMode) {
          TextInput({ placeholder: '邮箱地址', text: this.email })
            .height(52)
            .backgroundColor('rgba(255,255,255,0.65)')
            .border({ width: 1, color: '#E6D8C3' })
            .borderRadius(8)
            .shadow({ radius: 6, color: '#20000000' })
            .fontColor('#4A4A4A')
            .onChange((v) => this.email = v)

          Row() {
            TextInput({ placeholder: '验证码', text: this.verifyCodeInput })
              .height(52).layoutWeight(1)
              .backgroundColor('rgba(255,255,255,0.65)')
              .border({ width: 1, color: '#E6D8C3' })
              .borderRadius(8)
              .shadow({ radius: 6, color: '#20000000' })
              .fontColor('#4A4A4A')
              .onChange((v) => this.verifyCodeInput = v)

            Button(this.countdown > 0 ? `${this.countdown}s` : '获取')
              .height(52)
              .width(80)
              .margin({ left: 10 })
              .borderRadius(12)
              .backgroundColor('#E8DCC2')
              .border({ width: 1, color: '#D8C7A0' })
              .shadow({ radius: 8, color: '#15000000', offsetY: 3 })
              .fontColor('#3E3A35')
              .onClick(() => this.getVerifyCode())
          }
        }

        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password).height(52)
          .backgroundColor('rgba(255,255,255,0.65)')
          .border({ width: 1, color: '#E6D8C3' })
          .borderRadius(8)
          .shadow({ radius: 6, color: '#20000000' })
          .fontColor('#4A4A4A')
          .onChange((v) => this.password = v)

        Button(this.isLoginMode ? '进入 DomainGo' : '立即注册并探索')
          .width('100%')
          .height(52)
          .fontSize(18)
          .borderRadius(12)
          .margin({ top: 15 })
          .backgroundColor('#DCC9A3')
          .border({ width: 1, color: '#D8C7A0' })
          .shadow({ radius: 10, color: '#15000000', offsetY: 4 })
          .fontColor('#3E3A35')
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
              AppStorage.setOrCreate('isLoggedIn', false);
              AppStorage.setOrCreate('userName', '游客探险员');
              AppStorage.setOrCreate('currentUserId', '');
              AppStorage.setOrCreate('userAvatar', 'app.media.start');
              AppStorage.setOrCreate('token', '');
              router.replaceUrl({ url: 'pages/Index' });
            })
        }.width('100%')
      }
      .width('100%').padding(30)
    }
    .width('100%').height('100%')
    .backgroundImage($r('app.media.shanshui_bg'))
    .backgroundImageSize(ImageSize.Cover)
  }
}
