export const STORAGE_KEY_CITY = 'currentCity';
export const STORAGE_KEY_WEATHER = 'currentWeather';

export class LocationService {
  static async fetchLocation() {
    return new Promise<string>((resolve) => {
      setTimeout(() => resolve('武汉市'), 1000);
    });
  }

  // 模拟天气获取
  static async fetchWeather(city: string) {
    return city === '武汉市' ? '26°C 多云' : '22°C 晴';
  }
}