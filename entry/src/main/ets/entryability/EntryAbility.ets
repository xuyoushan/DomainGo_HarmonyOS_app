import { AbilityConstant, UIAbility, Want, ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

interface PostContinuationState { text: string;images: string[];location: string;cursor: number; }

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    try {
      const postData = AppStorage.get<PostContinuationState>('current_post_state');
      if (postData) {
        wantParam['postText'] = postData.text;
        wantParam['selectedImages'] = JSON.stringify(postData.images);
        wantParam['selectedLocation'] = postData.location;
        wantParam['cursorPos'] = postData.cursor;
        hilog.info(DOMAIN, 'Continuation', 'Data bundled successfully');
        return AbilityConstant.OnContinueResult.AGREE;
      }
    } catch (err) {
      hilog.error(DOMAIN, 'Continuation', 'Failed to save data: %{public}s', JSON.stringify(err));
    }
    return AbilityConstant.OnContinueResult.REJECT;
  }

  private handleContinuation(want: Want, launchParam: AbilityConstant.LaunchParam) {
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      AppStorage.setOrCreate('isContinuation', true);
      AppStorage.setOrCreate('contText', want.parameters?.postText);
      try {
        const images = want.parameters?.selectedImages;
        AppStorage.setOrCreate('contImages', images ? JSON.parse(images as string) : []);
      } catch {
        AppStorage.setOrCreate('contImages', []);
      }
      AppStorage.setOrCreate('contLoc', want.parameters?.selectedLocation);
      AppStorage.setOrCreate('contCursor', want.parameters?.cursorPos);
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'MapInit', 'Ability onCreate started');
    this.handleContinuation(want, launchParam);

    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err) ?? '');
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handleContinuation(want, launchParam);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    AppStorage.setOrCreate('currentCity', '定位中...');
    AppStorage.setOrCreate('currentWeather', '26°C');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }
}