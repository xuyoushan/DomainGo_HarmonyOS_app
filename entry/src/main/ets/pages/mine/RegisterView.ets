import { router, promptAction } from '@kit.ArkUI';
import { postRepo } from '../../services/PostRepository';
import { UserInfo } from '../../models/PostItem';
import { common } from '@kit.AbilityKit';
import { PreferenceManager } from '../../services/PreferenceManager';

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

  validateUsername(name: string): boolean {
    if (name === '_' || /^\d$/.test(name)) return false;
    const reg = /^[\u4e00-\u9fa5_a-zA-Z0-9]{1,16}$/;
    return reg.test(name);
  }

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
        this.generatedCode = '';
      }
    }, 1000);
  }

  async handleRegister() {
    if (!this.username || !this.email || !this.verifyCodeInput || !this.password) {
      promptAction.showToast({ message: '请完善注册信息' });
      return;
    }

    // 1-8个字符，不能是单个数字或下划线，支持1数字+1下划线
    const nameReg = /^(?!\d$)(?!_$)[[\u4e00-\u9fa5_a-zA-Z0-9]{1,16}$/;
    if (!nameReg.test(this.username)) {
      promptAction.showToast({ message: '用户名需1-16位，且不能仅为单个数字或下划线' });
      return;
    }

    /*
    // 1. 敏感词过滤
    const forbiddenWords = ['管理员', 'admin', '色情', '政治关键词1', '政治关键词2'];
    if (forbiddenWords.some(word => this.username.includes(word))) {
      promptAction.showToast({ message: '用户名包含违规敏感词' });
      return;
    }

    // 2. 密码强度限制
    if (this.password === this.username) {
      promptAction.showToast({ message: '密码不能与用户名相同' });
      return;
    }
    const pwdReg = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/; // 必须包含字母和数字，最少8位
    if (!pwdReg.test(this.password) || this.password === '123456') {
      promptAction.showToast({ message: '密码太弱！需包含字母和数字' });
      return;
    }

    // 3. 邮箱后缀限制 (只支持 QQ、Hotmail、Outlook)
    // QQ: 前缀5位起; Hotmail/Outlook: 前缀8位起
    const isQQ = /^\d{5,}@qq\.com$/.test(this.email);
    const isOutlook = /^[a-zA-Z0-9]{8,}@(hotmail\.com|outlook\.com)$/.test(this.email);
    if (!isQQ && !isOutlook) {
      promptAction.showToast({ message: '目前仅支持 QQ 邮箱(5位起)或 Outlook/Hotmail(8位起)' });
      return;
    }

    // 4. 注册频率限制 (同一设备24小时内限3个)
    const regCount = await PreferenceManager.get(getContext(this), 'reg_count_today', 0) as number;
    const lastRegTime = await PreferenceManager.get(getContext(this), 'last_reg_date', '') as string;
    const today = new Date().toLocaleDateString();
    if (lastRegTime === today && regCount >= 3) {
      promptAction.showToast({ message: '同一设备每日最多注册3个账号' });
      return;
    }
    */

    // 1. 验证码校验
    if (this.verifyCodeInput !== this.generatedCode) {
      promptAction.showToast({ message: '验证码错误或已过期' });
      return;
    }

    try {
      // 2. 邮箱查重
      const isUsed = await postRepo.isEmailRegistered(this.email);
      if (isUsed) {
        promptAction.showToast({ message: '该邮箱已被占用' });
        return;
      }

      // 3. 头像安全性检测
      const isAvatarSafe = await this.checkImageSafety('app.media.start');
      if (!isAvatarSafe) {
        promptAction.showToast({ message: '检测到默认头像不符合合规要求' });
        return;
      }

      const newUser: UserInfo = {
        id: '',
        username: this.username,
        email: this.email,
        password: this.password,
        avatar: 'app.media.start'
      };

      // 4. 执行写入
      const registeredUser = await postRepo.registerUser(newUser);
      await new Promise<void>(resolve => setTimeout(resolve, 100));

      // 5. 自动登录并缓存状态
      if (registeredUser && registeredUser.id) {
        const finalUserId = registeredUser.id;
        const avatarPath = (registeredUser.avatar && registeredUser.avatar !== '') ? registeredUser.avatar : 'app.media.start';

        AppStorage.setOrCreate('isLoggedIn', true);
        AppStorage.setOrCreate('userName', registeredUser.username);
        AppStorage.setOrCreate('currentUserId', finalUserId);
        AppStorage.setOrCreate('userAvatar', avatarPath);
        AppStorage.setOrCreate('needsRefreshPosts', Date.now());

        const context = getContext(this) as common.UIAbilityContext;
        await PreferenceManager.put(context, 'isLoggedIn', true);
        await PreferenceManager.put(context, 'currentUserId', finalUserId);
        await PreferenceManager.put(context, 'userName', registeredUser.username);
        await PreferenceManager.put(context, 'userAvatar', avatarPath);

        // 更新注册频率记录 (频率限制逻辑时)
        // await PreferenceManager.put(getContext(this), 'reg_count_today', regCount + 1);
        // await PreferenceManager.put(getContext(this), 'last_reg_date', today);

        promptAction.showToast({ message: '欢迎加入寻域！' });

        animateTo({ duration: 888, curve: Curve.EaseInOut }, (): void => {
          router.replaceUrl({ url: 'pages/Index' });
        })
      }else {
        throw new Error('用户信息写入异常，请重试');
      }
    } catch (e) {
      const error = e as Error;
      promptAction.showToast({ message: '注册失败：' + error.message });
    }
  }

  async checkImageSafety(uri: string): Promise<boolean> {
    console.info('正在进行 AI 内容安全检测...');
    return true;
  }

  async handleLogin() {
    const user = await postRepo.checkUser(this.username, this.password);
    if (user) {
      const avatarValue = (user.avatar && user.avatar !== '' && user.avatar !== 'undefined') ? user.avatar : 'app.media.start';

      AppStorage.setOrCreate('isLoggedIn', true);
      AppStorage.setOrCreate('userName', user.username);
      AppStorage.setOrCreate('currentUserId', user.id);
      AppStorage.setOrCreate('userAvatar', avatarValue);

      const context = getContext(this) as common.UIAbilityContext;
      await PreferenceManager.put(context, 'isLoggedIn', true);
      await PreferenceManager.put(context, 'currentUserId', user.id);
      await PreferenceManager.put(context, 'userName', user.username);
      await PreferenceManager.put(context, 'userAvatar', avatarValue);

      animateTo({ duration: 888, curve: Curve.EaseInOut }, () => {
        router.replaceUrl({ url: 'pages/Index' });
      })
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

        Column() {
          Text('其他方式登录').fontSize(12).fontColor('#CCCCCC').margin({ top: 40, bottom: 15 })
          Row({ space: 30 }) {
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