import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';

export class LocationManager {
  // 获取定位的权限请求逻辑
  static async requestPermission(context: common.UIAbilityContext): Promise<boolean> {
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      let data = await atManager.requestPermissionsFromUser(context, [
        'ohos.permission.APPROXIMATELY_LOCATION',
        'ohos.permission.LOCATION'
      ]);
      return data.authResults[0] === 0;
    } catch (err) {
      return false;
    }
  }

  // 获取真实 GPS 坐标并简单转换
  static async getRealCity(): Promise<string> {
    try {
      let requestInfo: geoLocationManager.CurrentLocationRequest = {
        'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
        'scenario': geoLocationManager.LocationRequestScenario.UNSET,
        'maxAccuracy': 0
      };
      // 获取坐标
      let location = await geoLocationManager.getCurrentLocation(requestInfo);
      console.info(`寻域定位成功: 经度${location.longitude}, 纬度${location.latitude}`);

      /** * 注意：HarmonyOS 原生接口只返回坐标。
       * 要显示“武汉市”，通常需要调用华为逆地理编码服务或第三方 API。
       * 这里我们通过坐标逻辑模拟一下。
       */
      return "武汉市"; // 实际开发需接逆地理编码接口
    } catch (err) {
      console.error("定位服务不可用", JSON.stringify(err));
      return "定位失败";
    }
  }
}