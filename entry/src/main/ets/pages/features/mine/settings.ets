import router from '@ohos.router';
import { common } from '@kit.AbilityKit'; // 👈 修复 1：导入 common 命名空间
import { PreferenceManager } from '../../../services/PreferenceManager';

@Entry
@Component
struct SettingsPage {
  // @StorageLink('show_guide') isGuideEnabled: boolean = false;
  @StorageLink('show_guide_manual') show_guide_manual: boolean = false;

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F1F3F5')

      // 开关行
      Row() {
        Column() {
          Text('重新播放引导动画')
            .fontSize(16)
          Text('开启后，下次启动将展示引导')
            .fontSize(12)
            .fontColor(Color.Gray)
        }.alignItems(HorizontalAlign.Start)

        Blank() // 自动撑开中间距离
        Toggle({ type: ToggleType.Switch, isOn: AppStorage.get<boolean>('show_guide_manual') })
          .onChange(async (isOn: boolean) => {
            AppStorage.setOrCreate('show_guide_manual', isOn);
            const context = getContext(this) as common.UIAbilityContext;
            await PreferenceManager.put(context, 'show_guide_manual', isOn);
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      Divider()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}