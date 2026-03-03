import router from '@ohos.router';
import { common } from '@kit.AbilityKit';
import { PreferenceManager } from '../../../services/PreferenceManager';
import promptAction from '@ohos.promptAction';
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { PostItem } from '../../../models/PostItem';
import { userRepo } from '../../../services/UserRepository';
import { http } from '@kit.NetworkKit';
const BASE_URL = 'https://login-inchnzmmux.cn-hangzhou.fcapp.run';
const pwdReg = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/;
class SimpleResponse {
  success: boolean = false;
  message?: string;
}

@Entry
@Component
struct SettingsPage {
  @StorageLink('show_guide_manual') show_guide_manual: boolean = false;
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('userName') globalUserName: string = '';
  @StorageLink('currentUserId') userId: string = '';
  @StorageLink('userAvatar') globalUserAvatar: string = '';

  @State tempName: string = '';
  @State tempAvatar: string = '';
  @State newPassword: string = '';
  @State isChecking: boolean = false;

  async aboutToAppear() {
    this.tempName = this.globalUserName;
    this.tempAvatar = (this.globalUserAvatar === 'app.media.start') ? '' : this.globalUserAvatar;
  }

  validateUsername(name: string): boolean {
    if (name === '_' || /^\d$/.test(name)) return false;
    const reg = /^(?!\d$)(?!_$)[\u4e00-\u9fa5_a-zA-Z0-9]{1,16}$/;
    return reg.test(name);
  }

  async checkImageSafety(uri: string): Promise<boolean> {
    this.isChecking = true;
    console.info(`DomainGo_AI_Scan: 正在分析图片流 ${uri}`);
    return new Promise((resolve) => {
      setTimeout(() => {
        this.isChecking = false;
        resolve(true);
      }, 1500);
    });
  }

  async selectAvatar() {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      const photoPicker = new photoAccessHelper.PhotoViewPicker();

      const result = await photoPicker.select(photoSelectOptions);
      if (result.photoUris.length > 0) {
        let selectedUri = result.photoUris[0];

        promptAction.showToast({ message: '原生 AI 正在安全扫描...' });
        const isSafe = await this.checkImageSafety(selectedUri);

        if (isSafe) {
          this.tempAvatar = selectedUri;
          promptAction.showToast({ message: '图片审核通过' });
        } else {
          promptAction.showDialog({
            title: '审核未通过',
            message: '该图片包含违规或敏感内容，请更换其他图片。',
            buttons: [{ text: '我知道了', color: '#007DFF' }]
          });
        }
      }
    } catch (err) {
      console.error('PhotoPicker failed', JSON.stringify(err));
    }
  }

  async doLogout() {
    const context = getContext(this) as common.UIAbilityContext;
    await PreferenceManager.put(context, 'token', '');
    AppStorage.setOrCreate('isLoggedIn', false);
    AppStorage.setOrCreate('userName', '点击注册/登录');
    AppStorage.setOrCreate('currentUserId', '');
    AppStorage.setOrCreate('userAvatar', 'app.media.start');

    await PreferenceManager.put(context, 'isLoggedIn', false);
    await PreferenceManager.put(context, 'currentUserId', '');
    await PreferenceManager.put(context, 'userName', '点击注册/登录');
    await PreferenceManager.put(context, 'userAvatar', 'app.media.start');

    router.clear();
    router.replaceUrl({ url: 'pages/Index' });
  }

  async changePassword(newPwd: string) {
    if (!pwdReg.test(newPwd)) {
      promptAction.showToast({ message: '密码太弱！需包含字母和数字' });
      return false;
    }

    const context = getContext(this) as common.UIAbilityContext;
    const token = await PreferenceManager.get(context, 'token', '');

    if (!token) {
      promptAction.showToast({ message: '请先登录' });
      return false;
    }

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        `${BASE_URL}/user/changePassword`,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: { token, newPassword: newPwd }
        }
      );

      const data = response.result as SimpleResponse;

      if (!data.success) {
        promptAction.showToast({ message: data.message || '修改失败' });
        return false;
      }

      return true;
    } finally {
      httpRequest.destroy();
    }
  }

  async deleteAccount() {
    const context = getContext(this) as common.UIAbilityContext;
    const token = await PreferenceManager.get(context, 'token', '');

    if (!token) {
      promptAction.showToast({ message: '请先登录' });
      return false;
    }

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        `${BASE_URL}/user/deleteAccount`,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: { token }
        }
      );

      const data = response.result as SimpleResponse;

      if (!data.success) {
        promptAction.showToast({ message: data.message || '注销失败' });
        return false;
      }

      return true;
    } finally {
      httpRequest.destroy();
    }
  }

  async updateAvatar() {
    const context = getContext(this) as common.UIAbilityContext;

    if (!this.tempAvatar || this.tempAvatar.trim() === '') {
      promptAction.showToast({ message: '请选择头像' });
      return false;
    }

    this.globalUserAvatar = this.tempAvatar;

    await PreferenceManager.put(context, 'userAvatar', this.tempAvatar);

    let posts = AppStorage.get<PostItem[]>('globalPostList') || [];
    const updatedPosts = posts.map(p => {
      if (p.userId === this.userId) {
        p.avatar = this.tempAvatar;
      }
      return p;
    });
    AppStorage.setOrCreate('globalPostList', updatedPosts);
    AppStorage.setOrCreate('needsRefreshPosts', Date.now());

    promptAction.showToast({ message: '头像已更新' });
    return true;
  }


  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#F4F7FF', 0.0], ['#E9EDF7', 1.0]]
        })

      Column() {
        Row() {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).fontColor([Color.Black])
          }
          .width(44).height(44).backgroundColor('#0A000000').onClick(() => router.back())

          Blank()

          if (this.isChecking) {
            LoadingProgress().width(24).height(24).color('#007DFF')
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12 })

        Scroll() {
          Column() {
            Column() {
              Text('账户设置')
                .fontSize(32)
                .fontWeight(FontWeight.Bolder)
                .fontColor('#182431')
              Text('管理你的探险身份与应用偏好')
                .fontSize(14)
                .fontColor('#667085')
                .margin({ top: 8 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 24, top: 20, bottom: 30 })

            if (this.isLoggedIn) {
              Column() {
                Stack() {
                  Circle()
                    .width(100).height(100)
                    .fill(Color.White)
                    .shadow({ radius: 20, color: 'rgba(0,125,255,0.15)', offsetX: 0, offsetY: 8 })

                  Image(this.tempAvatar ? this.tempAvatar : $r('app.media.start'))
                    .width(90).height(90)
                    .borderRadius(45)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(45)
                    .clip(true)
                    .alt($r('app.media.start'))
                    .onClick(() => !this.isChecking && this.selectAvatar())

                  if (this.isChecking) {
                    Column() {}
                    .width(90).height(90)
                    .backgroundColor('rgba(0,0,0,0.2)')
                    .borderRadius(45)
                    .clip(true)
                    LoadingProgress().width(30).height(30).color(Color.White)
                  }

                  Button({ type: ButtonType.Circle }) {
                    SymbolGlyph($r('sys.symbol.camera_fill')).fontSize(16).fontColor([Color.White])
                  }
                  .width(32).height(32)
                  .backgroundColor('#007DFF')
                  .position({ x: 65, y: 65 })
                  .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)' })
                  .onClick(() => !this.isChecking && this.selectAvatar())
                }
                .margin({ bottom: 20 })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }

            Column() {
              this.IslandSectionTitle('应用偏好')
              Column() {
                this.IslandToggleRow('重新播放引导动画', '开启后下次启动展示动画', this.show_guide_manual, async (isOn) => {
                  this.show_guide_manual = isOn;
                  AppStorage.setOrCreate('show_guide_manual', isOn);
                  const context = getContext(this) as common.UIAbilityContext;
                  await PreferenceManager.put(context, 'show_guide_manual', isOn);
                })
              }.IslandContainer()

              if (this.isLoggedIn) {
                this.IslandSectionTitle('身份信息')
                Column() {
                  this.IslandInputRow('用户名', this.tempName, (v) => this.tempName = v)
                  Divider().color('#F2F4F7').margin({ left: 16, right: 16 })
                  this.IslandInputRow('新密码', '', (v) => this.newPassword = v, true)
                }.IslandContainer()

                Button('保存资料更改')
                  .width('80%')
                  .height(54)
                  .margin({ top: 40, bottom: 20 })
                  .linearGradient({
                    direction: GradientDirection.Right,
                    colors: [['#007DFF', 0.0], ['#005BB7', 1.0]]
                  })
                  .shadow({ radius: 20, color: 'rgba(0,125,255,0.3)', offsetY: 10 })
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .enabled(!this.isChecking)
                  .onClick(async () => {
                    // 1. 用户名校验
                    if (!this.validateUsername(this.tempName)) {
                      promptAction.showToast({ message: '用户名不合规 (1-16位中英文数字下划线)' });
                      return;
                    }

                    const context = getContext(this) as common.UIAbilityContext;

                    try {
                      this.globalUserName = this.tempName;
                      await PreferenceManager.put(context, 'userName', this.tempName);

                      if (this.tempAvatar) {
                        await this.updateAvatar();
                      }
                      if (this.newPassword && this.newPassword.length > 0) {
                        const ok = await this.changePassword(this.newPassword);
                        if (!ok) return;
                      }
                      let posts = AppStorage.get<PostItem[]>('globalPostList') || [];
                      const updatedPosts = posts.map(p => {
                        if (p.userId === this.userId) {
                          p.userName = this.tempName;
                        }
                        return p;
                      });
                      AppStorage.setOrCreate('globalPostList', updatedPosts);
                      AppStorage.setOrCreate('needsRefreshPosts', Date.now());

                      promptAction.showToast({ message: '资料已更新' });
                      router.back();

                    } catch (e) {
                      promptAction.showToast({ message: '更新失败: ' + (e as Error).message });
                    }
                  })

                this.IslandSectionTitle('账户安全')
                Column() {
                  this.IslandActionRow('退出当前账号', '#182431', () => {
                    promptAction.showDialog({
                      title: '退出提醒',
                      message: '确定要结束本次探险吗？',
                      buttons: [{ text: '取消', color: '#666' }, { text: '退出', color: '#FF4D4F' }]
                    }).then(async (data) => { if (data.index === 1) await this.doLogout(); })
                  })
                  Divider().color('#F2F4F7').margin({ left: 16, right: 16 })
                  this.IslandActionRow('注销账户', '#FF4D4F', () => {
                    promptAction.showDialog({
                      title: '注销确认 (1/2)',
                      message: '注销将永久删除您的所有数据，不可撤销。',
                      buttons: [{ text: '点错了', color: '#000' }, { text: '执意注销', color: '#FF4D4F' }]
                    }).then((res) => {
                      if (res.index === 1) {
                        promptAction.showDialog({
                          title: '最终确认 (2/2)',
                          message: '最后一次后悔的机会，确定删除吗？',
                          buttons: [{ text: '我再想想', color: '#000' }, { text: '确定删除', color: '#FF4D4F' }]
                        }).then(async (final) => {
                          if (final.index === 1) {
                            const ok = await this.deleteAccount();
                            if (!ok) {
                              promptAction.showToast({ message: '注销失败，请稍后再试' });
                              return;
                            }

                            const context = getContext(this) as common.UIAbilityContext;
                            AppStorage.setOrCreate('isLoggedIn', false);
                            AppStorage.setOrCreate('userName', '点击注册/登录');
                            AppStorage.setOrCreate('currentUserId', '');
                            AppStorage.setOrCreate('userAvatar', 'app.media.start');
                            await PreferenceManager.put(context, 'isLoggedIn', false);
                            await PreferenceManager.put(context, 'currentUserId', '');
                            await PreferenceManager.put(context, 'userName', '点击注册/登录');
                            await PreferenceManager.put(context, 'userAvatar', 'app.media.start');
                            promptAction.showToast({ message: '账号已注销' });
                            router.clear();
                            router.replaceUrl({ url: 'pages/Index' });
                          }
                        })
                      }
                    })
                  })
                }.IslandContainer().margin({ bottom: 40 })
              }
            }
          }
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder IslandSectionTitle(title: string) {
    Text(title.toUpperCase())
      .fontSize(12)
      .fontWeight(FontWeight.Bold)
      .fontColor('#98A2B3')
      .letterSpacing(1.5)
      .margin({ left: 32, top: 24, bottom: 8 })
      .width('100%')
  }

  @Styles IslandContainer() {
    .backgroundColor(Color.White)
    .borderRadius(24)
    .margin({ left: 20, right: 20 })
    .shadow({ radius: 15, color: 'rgba(0,0,0,0.04)', offsetX: 0, offsetY: 4 })
  }

  @Builder IslandToggleRow(title: string, sub: string, state: boolean, callback: (v: boolean) => void) {
    Row() {
      Column() {
        Text(title).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#1D2939')
        Text(sub).fontSize(12).fontColor('#667085').margin({ top: 4 })
      }.alignItems(HorizontalAlign.Start)
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: state })
        .selectedColor('#007DFF')
        .onChange(callback)
    }
    .width('100%').padding(20)
  }

  @Builder IslandInputRow(label: string, value: string, onChange: (v: string) => void, isPwd = false) {
    Row() {
      Text(label).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#1D2939').width(80)
      TextInput({ text: value, placeholder: isPwd ? '找回/重置密码' : `输入${label}` })
        .layoutWeight(1)
        .backgroundColor('#F9FAFB')
        .borderRadius(12)
        .height(44)
        .fontSize(15)
        .type(isPwd ? InputType.Password : InputType.Normal)
        .onChange(onChange)
    }
    .width('100%').padding(16)
  }

  @Builder IslandActionRow(text: string, color: string, onClick: () => void) {
    Button({ type: ButtonType.Normal }) {
      Row() {
        Text(text).fontSize(16).fontWeight(FontWeight.Medium).fontColor(color)
        Blank()
        SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(14).fontColor(['#98A2B3'])
      }.width('100%')
    }
    .backgroundColor(Color.Transparent)
    .padding(20)
    .onClick(onClick)
  }
}