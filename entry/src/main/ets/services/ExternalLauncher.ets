import { common, Want } from '@kit.AbilityKit';

export class OpenExternalApp {

  static async startSearch(context: common.UIAbilityContext, platform: string, keyword: string) {
    let uri = '';
    const encodedKey = encodeURIComponent(keyword);

    if (platform === '美团') {
      uri = `meituan://www.meituan.com/s/${encodedKey}`;
    } else if (platform === '高德') {
      uri = `amapuri://route/plan/?dname=${encodedKey}&dev=0&t=0`;
    } else if (platform === '携程') {
      uri = `ctrip://wireless/index?page=search&keyword=${encodedKey}`;
    }

    let want: Want = {
      action: 'ohos.actions.browser.intent.MAIN',
      entities: ['entity.system.browsable'],
      uri: uri
    };

    try {
      await context.startAbility(want);
    } catch (e) {
      OpenExternalApp.openWeb(context, platform, keyword);
    }
  }

  static openWeb(context: common.UIAbilityContext, platform: string, keyword: string) {
    const encodedKey = encodeURIComponent(keyword);
    let webUrl = '';

    if (platform === '美团') {
      webUrl = `https://i.meituan.com/s/${encodedKey}`;
    } else if (platform === '携程') {
      webUrl = `https://m.ctrip.com/webapp/search/index?keyword=${encodedKey}`;
    } else {
      webUrl = `https://m.amap.com/search/view/keywords=${encodedKey}`;
    }

    context.startAbility({
      action: 'ohos.actions.browser.intent.MAIN',
      entities: ['entity.system.browsable'],
      uri: webUrl
    });
  }
}