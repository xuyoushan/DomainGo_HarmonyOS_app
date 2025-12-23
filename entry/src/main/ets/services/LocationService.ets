// 用于全局共享的键名
export const STORAGE_KEY_CITY = 'currentCity';
export const STORAGE_KEY_WEATHER = 'currentWeather';

export class LocationService {
  // 模拟定位获取
  static async fetchLocation() {
    // 实际开发时这里调用 @ohos.geoLocationManager
    return new Promise<string>((resolve) => {
      setTimeout(() => resolve('武汉市'), 1000);
    });
  }

  // 模拟天气获取
  static async fetchWeather(city: string) {
    // 实际开发时这里调用网络请求 API
    return city === '武汉市' ? '26°C 多云' : '22°C 晴';
  }
}