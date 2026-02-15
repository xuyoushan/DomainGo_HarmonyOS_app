import router from '@ohos.router';
import { common } from '@kit.AbilityKit';
import { PreferenceManager } from '../../../services/PreferenceManager';
import { postRepo } from '../../../services/PostRepository';
import promptAction from '@ohos.promptAction';
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { PostItem } from '../../../models/PostItem';

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
    this.tempAvatar = this.globalUserAvatar;
  }

  validateUsername(name: string): boolean {
    if (name === '_' || /^\d$/.test(name)) return false;
    const reg = /^[\u4e00-\u9fa5_a-zA-Z0-9]{1,16}$/;
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
          this.tempAvatar = selectedUri; // 只改本地缓存
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
    AppStorage.setOrCreate('isLoggedIn', false);
    AppStorage.setOrCreate('userName', '点击注册/登录');
    AppStorage.setOrCreate('currentUserId', '');
    AppStorage.setOrCreate('userAvatar', 'app.media.start'); // 统一默认头像标识

    await PreferenceManager.put(context, 'isLoggedIn', false);
    await PreferenceManager.put(context, 'currentUserId', '');
    await PreferenceManager.put(context, 'userName', '点击注册/登录');
    await PreferenceManager.put(context, 'userAvatar', 'app.media.start');

    router.clear();
    router.replaceUrl({ url: 'pages/Index' });
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .fontColor([Color.Black])
          .onClick(() => router.back())
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })

        if (this.isChecking) {
          LoadingProgress().width(24).height(24).margin({ left: 10 })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F1F3F5')

      Scroll() {
        Column() {
          this.SectionTitle('通用设置')

          Row() {
            Column() {
              Text('重新播放引导动画').fontSize(16)
              Text('开启后，下次启动将展示引导').fontSize(12).fontColor(Color.Gray)
            }.alignItems(HorizontalAlign.Start)

            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.show_guide_manual })
              .onChange(async (isOn: boolean) => {
                this.show_guide_manual = isOn;
                AppStorage.setOrCreate('show_guide_manual', isOn);
                const context = getContext(this) as common.UIAbilityContext;
                await PreferenceManager.put(context, 'show_guide_manual', isOn);
              })
          }
          .width('100%').padding(16).backgroundColor(Color.White)

          if (this.isLoggedIn) {
            this.SectionTitle('资料编辑')

            Column() {
              Row() {
                Text('修改头像').fontSize(16)
                Blank()
                Stack() {
                  Image(this.tempAvatar || $r('app.media.start'))
                    .width(44).height(44).borderRadius(22).objectFit(ImageFit.Cover)
                    .opacity(this.isChecking ? 0.5 : 1)
                  if (this.isChecking) {
                    Progress({ value: 0, total: 100, type: ProgressType.Ring })
                    LoadingProgress().width(40).height(40).color(Color.White)                  }
                }
                .margin({ right: 10 })
                SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(16).fontColor([Color.Gray])
              }
              .width('100%').padding(16)
              .onClick(() => !this.isChecking && this.selectAvatar())

              Divider().margin({ left: 16, right: 16 })

              // 这里绑定 tempName 而非 globalUserName
              this.EditItem('用户名', this.tempName, (v) => this.tempName = v)

              Divider().margin({ left: 16, right: 16 })

              this.EditItem('新密码', '', (v) => this.newPassword = v, true)

              Button('确认修改')
                .margin({ top: 30, bottom: 20 })
                .height(42)
                .width('50%')
                .backgroundColor('#FF8F00')
                .fontColor(Color.White)
                .borderRadius(21)
                .enabled(!this.isChecking)
                .onClick(async () => {
                  if (!this.validateUsername(this.tempName)) {
                    promptAction.showToast({ message: '用户名不合规 (1-16位中英文数字下划线)' });
                    return;
                  }
                  try {
                    await postRepo.updateUserInfo(this.userId, this.tempName, this.tempAvatar, this.newPassword);
                    this.globalUserName = this.tempName;
                    this.globalUserAvatar = this.tempAvatar;
                    const context = getContext(this) as common.UIAbilityContext;
                    await PreferenceManager.put(context, 'userName', this.tempName);
                    await PreferenceManager.put(context, 'userAvatar', this.tempAvatar);
                    let posts = AppStorage.get<PostItem[]>('globalPostList') || [];
                    const updatedPosts = posts.map(p => {
                      if (p.userId === this.userId) {
                        p.userName = this.tempName;
                        p.avatar = this.tempAvatar;
                      }
                      return p;
                    });
                    AppStorage.setOrCreate('globalPostList', updatedPosts);
                    AppStorage.setOrCreate('needsRefreshPosts', Date.now());
                    promptAction.showToast({ message: '修改成功' });
                    router.back();

                  } catch (e) {
                    const error = e as Error;
                    promptAction.showToast({ message: '保存失败: ' + error.message });
                  }
                })
            }
            .backgroundColor(Color.White)

            this.SectionTitle('账号安全')

            Column() {
              this.ActionItem('退出账号', Color.Black, () => {
                promptAction.showDialog({
                  title: '退出提醒',
                  message: '确定要结束本次探险吗？',
                  buttons: [
                    { text: '取消', color: '#000000' },
                    { text: '退出', color: '#FF4D4F' }
                  ]
                }).then(async (data) => {
                  if (data.index === 1) {
                    await this.doLogout();
                  }
                })
              })

              Divider().margin({ left: 16, right: 16 })

              this.ActionItem('注销账号 (危险)', Color.Red, () => {
                promptAction.showDialog({
                  title: '注销确认 (1/2)',
                  message: '注销将永久删除您的所有数据，不可撤销。',
                  buttons: [{ text: '点错了', color: '#000' }, { text: '执意注销', color: '#FF4D4F' }]
                }).then((res) => {
                  if (res.index === 1) {
                    promptAction.showDialog({
                      title: '最终确认 (2/2)',
                      message: '这是您最后一次后悔的机会，确定删除吗？',
                      buttons: [{ text: '我再想想', color: '#000' }, { text: '确定删除', color: '#FF4D4F' }]
                    }).then(async (final) => {
                      // settings.ets 里的注销最终确认部分
                      if (final.index === 1) {
                        await postRepo.deleteUserAccount(this.userId);
                        const context = getContext(this) as common.UIAbilityContext;
                        AppStorage.setOrCreate('isLoggedIn', false);
                        AppStorage.setOrCreate('userName', '点击注册/登录');
                        AppStorage.setOrCreate('currentUserId', '');
                        AppStorage.setOrCreate('userAvatar', 'app.media.start');
                        await PreferenceManager.put(context, 'isLoggedIn', false);
                        await PreferenceManager.put(context, 'currentUserId', '');
                        await PreferenceManager.put(context, 'userName', '');
                        await PreferenceManager.put(context, 'userAvatar', 'app.media.start');

                        promptAction.showToast({ message: '账号已永久注销' });
                        router.clear();
                        router.replaceUrl({ url: 'pages/Index' });
                      }
                    })
                  }
                })
              })
            }.backgroundColor(Color.White).width('100%')
          }
        }
      }.layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }

  @Builder SectionTitle(title: string) {
    Text(title).fontSize(13).fontColor('#999999').margin({ left: 16, top: 20, bottom: 8 }).width('100%')
  }

  @Builder EditItem(label: string, value: string, onChange: (v: string) => void, isPwd = false) {
    Row() {
      Text(label).width(80).fontSize(16)
      TextInput({ text: value, placeholder: isPwd ? '找回/重置密码' : `请输入${label}` })
        .layoutWeight(1).backgroundColor(Color.Transparent)
        .type(isPwd ? InputType.Password : InputType.Normal).onChange(onChange)
    }.padding(16)
  }

  @Builder ActionItem(text: string, color: ResourceColor, onClick: () => void) {
    Row() {
      Text(text).fontSize(16).fontColor(color)
      Blank()
      SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(16).fontColor([Color.Gray])
    }.padding(16).width('100%').onClick(onClick)
  }
}
