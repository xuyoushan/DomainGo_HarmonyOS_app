import { http } from '@kit.NetworkKit';

interface AmapPhoto {
  url: string;
}

interface AmapBizExt {
  rating: string;
  cost: string;
}

interface AmapPoi {
  id: string;
  name: string;
  type: string;
  address: string;
  distance: string;
  photos: AmapPhoto[];
  biz_ext: AmapBizExt;
}

interface AmapResponse {
  status: string;
  pois: AmapPoi[];
}

export interface ScenicSpot {
  id: string;
  name: string;
  image: string;
  rating: string;
  price: string;
  isFree: boolean;
  distance: number;
  address: string;
  tags: string[];
  isMuseum: boolean;
}

export class AmapSpotService {
  private static readonly API_KEY = 'd4552bc3e20af2857f9cfd5ac95ded1d';

  // 🔹 场馆已单独适配的“超大城市”
  private static readonly VENUE_EXCLUDED_CITIES = [
    '北京',
    '天津',
    '上海',
    '武汉',
    '重庆',
    '成都'
  ];

  // 🔹 全国顶级地标兜底
  private static readonly TOP_LANDMARK_REGEX =
    /故宫|天安门|颐和园|天坛|长城|圆明园|西湖|黄鹤楼|岳阳楼|滕王阁|兵马俑|布达拉宫|九寨沟|张家界|泰山|华山|嵩山/;

  static async fetchSpots(city: string): Promise<ScenicSpot[]> {
    const key = AmapSpotService.API_KEY;
    const keywords = encodeURIComponent('景区|风景名胜|世界遗产|地标');

    const url = `https://restapi.amap.com/v3/place/text?key=${key}&keywords=${keywords}&city=${encodeURIComponent(
      city
    )}&offset=50&page=1&extensions=all&sortrule=weight`;

    const isVenueExcludedCity =
      AmapSpotService.VENUE_EXCLUDED_CITIES.includes(city);

    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(url);
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as AmapResponse;

        if (result.status === '1' && result.pois) {
          return result.pois
            .filter((poi) => {
              const name = poi.name || '';
              const rating = parseFloat(poi.biz_ext?.rating || '0');
              const photos = poi.photos || [];
              const hasPhoto = photos.length > 0;

              if (AmapSpotService.TOP_LANDMARK_REGEX.test(name)) {
                return hasPhoto;
              }

              const junkRegex =
                /(厕所|停车场|入口|出口|售票处|游客服务中心|服务区|码头|站|路段)/;
              if (junkRegex.test(name)) return false;

              const subSpotRegex =
                /-(入口|出口|停车|售票)|·(入口|出口|售票)/;
              if (subSpotRegex.test(name)) return false;

              const isVenue =
                /(博物馆|纪念馆|美术馆|科技馆)/.test(name);

              if (isVenueExcludedCity) {
                if (isVenue) return false;
              } else {
                if (isVenue && rating < 4.5) return false;
              }

              if (
                /(广场|商业街|步行街|商圈)/.test(name) &&
                  (isVenueExcludedCity || rating < 4.4)
              ) {
                return false;
              }

              let score = 0;

              if (rating >= 4.6) score += 3;
              else if (rating >= 4.3) score += 2;
              else if (rating >= 4.0) score += 1;

              if (photos.length >= 6) score += 3;
              else if (photos.length >= 3) score += 2;
              else if (photos.length >= 1) score += 1;

              if (poi.type?.includes('风景名胜')) score += 2;
              if (/景区|名胜|遗址|公园$/.test(name)) score += 2;

              return isVenueExcludedCity ? score >= 7 : score >= 6;
            })
            .map((poi): ScenicSpot => {
              const costValue = poi.biz_ext?.cost || '0';
              const photos = poi.photos || [];

              let image = '';
              if (photos.length > 0) {
                const index = Math.floor(photos.length / 2);
                image = photos[index]?.url || photos[0].url;
              }

              return {
                id: poi.id,
                name: poi.name,
                image,
                rating: poi.biz_ext?.rating || '4.0',
                price: costValue,
                isFree: parseInt(costValue) === 0 || costValue === '',
                distance: parseInt(poi.distance || '0'),
                address: poi.address,
                tags: AmapSpotService.parseProTags(poi),
                isMuseum: /(博物馆|纪念馆)/.test(poi.name)
              };
            });
        }
      }
    } catch (e) {
      console.error('Fetch Scenic Data Failed', e);
    }

    return [];
  }

  private static parseProTags(poi: AmapPoi): string[] {
    const tags: string[] = [];
    const name = poi.name || '';
    const typeStr = poi.type || '';

    if (typeStr.includes('5A')) tags.push('5A景区');
    else if (typeStr.includes('4A')) tags.push('4A景区');
    else if (typeStr.includes('3A')) tags.push('3A景区');

    const natureRegex = /山|湖|海|岛|林|峰|泉|滩|瀑|草原/;
    if (natureRegex.test(name) || typeStr.includes('自然')) {
      tags.push('自然');
    } else {
      tags.push('人文');
    }

    if (parseInt(poi.biz_ext?.cost || '0') === 0) {
      tags.push('免费');
    }

    return tags.slice(0, 3);
  }
}
