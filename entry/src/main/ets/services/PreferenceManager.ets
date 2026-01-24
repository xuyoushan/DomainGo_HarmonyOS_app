import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

export class PreferenceManager {
  private static readonly STORE_NAME = 'UserConfig'; // 存储库名称

  private static async getStore(context: common.Context) {
    return await preferences.getPreferences(context, PreferenceManager.STORE_NAME);
  }

  static async put(context: common.Context, key: string, value: preferences.ValueType) {
    try {
      const store = await PreferenceManager.getStore(context);
      await store.put(key, value);
      await store.flush();
      console.info(`[Preference] 成功保存 ${key}: ${value}`);
    } catch (err) {
      console.error(`[Preference] 保存失败: ${JSON.stringify(err)}`);
    }
  }

  static async get(context: common.Context, key: string, defaultValue: preferences.ValueType) {
    try {
      const store = await PreferenceManager.getStore(context);
      const val = await store.get(key, defaultValue);
      return val;
    } catch (err) {
      console.error(`[Preference] 读取失败: ${JSON.stringify(err)}`);
      return defaultValue;
    }
  }
}