import http from '@ohos.net.http';

interface WeatherNow { temperature: string; text: string; }
interface WeatherResult { now: WeatherNow; }
interface WeatherResponse { results: WeatherResult[]; }

@Component
export struct WeatherWidget {
  @StorageLink('currentCity') @Watch('onCityChange') currentCity: string = '武汉市';
  @StorageLink('currentWeather') weatherInfo: string = '...';
  @StorageLink('currentWeatherText') weatherText: string = '阴';
  @StorageLink('currentTemperature') curTemp: string = '';

  onCityChange() {
    this.fetchRealWeather(this.currentCity);
  }

  aboutToAppear() {
    this.fetchRealWeather(this.currentCity);
  }

  getWeatherIcon(text: string): Resource {
    let icon = $r('sys.symbol.cloud_sun_fill');
    if (text.includes('晴')) {
      icon = $r('sys.symbol.sun_max_fill');
    } else if (text.includes('雨')) {
      icon = text.includes('大') || text.includes('暴') ?
        $r('sys.symbol.cloud_heavy_storm') : $r('sys.symbol.light_rain');
    } else if (text.includes('雪')) {
      icon = $r('sys.symbol.snowflake');
    } else if (text.includes('阴')) {
      icon = $r('sys.symbol.cloud_fill');
    } else if (text.includes('多云')) {
      icon = $r('sys.symbol.cloud_sun_fill');
    } else if (text.includes('雾') || text.includes('霾')) {
      icon = $r('sys.symbol.taillight_fog_fill');
    } else if (text.includes('风') || text.includes('沙') || text.includes('尘')) {
      icon = $r('sys.symbol.wind');
    } else if (text.includes('雷')) {
      icon = $r('sys.symbol.bolt_2_fill');
    }

    return icon;
  }

  async fetchRealWeather(city: string) {
    let httpRequest = http.createHttp();
    try {
      let queryCity = city.replace('市', '');
      let url = `https://api.seniverse.com/v3/weather/now.json?key=S7zKUHHMAcavQT0_R&location=${encodeURIComponent(queryCity)}&language=zh-Hans&unit=c`;
      let response = await httpRequest.request(url, { connectTimeout: 5000 });
      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as WeatherResponse;
        if (result.results?.length > 0) {
          let nowData = result.results[0].now;
          this.weatherInfo = `${nowData.temperature}°C`;
          this.curTemp = nowData.temperature;
          this.weatherText = nowData.text;
        }
      }
    } catch (err) {
      this.weatherInfo = '网络异常';
    } finally {
      httpRequest.destroy();
    }
  }

  build() {
    Row() {
      SymbolGlyph(this.getWeatherIcon(this.weatherText))
        .fontSize(22)
        .fontColor([
          this.weatherText.includes('雪') ? '#A5D6F7' :
            this.weatherText.includes('雨') ? '#4FACFE' : '#FFAD0A'
        ])
      Text(this.weatherInfo)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#444')
        .margin({ left: 4 })
    }
    .width('20%')
    .justifyContent(FlexAlign.End)
  }
}