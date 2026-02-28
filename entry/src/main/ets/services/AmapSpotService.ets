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

  private static readonly VENUE_EXCLUDED_CITIES = [
    '北京',
    '天津',
    '上海',
    '武汉',
    '重庆',
    '成都'
  ];

  private static readonly CITY_CORE_LANDMARKS: Map<string, RegExp> = new Map([
    ['北京', /故宫|天安门|颐和园|天坛|长城|圆明园/],
    ['天津', /古文化街|意式风情区|五大道/],
    ['上海', /外滩|东方明珠|豫园|南京路/],
    ['武汉', /黄鹤楼|东湖|武汉长江大桥|汉口江滩/],
    ['重庆', /洪崖洞|解放碑|磁器口|朝天门/],
    ['成都', /宽窄巷子|锦里|都江堰|青城山/]
  ]);

  static async fetchSpots(city: string): Promise<ScenicSpot[]> {
    const key = AmapSpotService.API_KEY;
    const keywords = encodeURIComponent('景区|地标|公园|博物馆');
    const types = '110000|140000';

    const url = `https://restapi.amap.com/v3/place/text?key=${key}&keywords=${keywords}&types=${types}&city=${encodeURIComponent(
      city
    )}&offset=50&page=1&extensions=all&sortrule=weight`;

    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(url);
      if (response.responseCode !== 200) return [];

      const result = JSON.parse(response.result as string) as AmapResponse;
      if (result.status !== '1' || !result.pois) return [];

      const coreRegex = AmapSpotService.CITY_CORE_LANDMARKS.get(city);
      const finalPois: AmapPoi[] = [];

      result.pois.forEach((poi) => {
        const name = poi.name || '';

        if (coreRegex && coreRegex.test(name)) {
          finalPois.push(poi);
          return;
        }

        const isInfrastructure = /(停车场|厕所|出入口|服务区|码头|站)$/.test(name);
        if (isInfrastructure) return;

        const rating = parseFloat(poi.biz_ext?.rating || '0');
        const photos = poi.photos || [];

        if (rating > 3.5 || photos.length > 0) {
          finalPois.push(poi);
        }
      });

      const uniquePois = Array.from(new Set(finalPois));

      return uniquePois.map((poi): ScenicSpot => {
        const photos = poi.photos || [];
        let image = '';
        if (photos.length > 0) {
          const index = Math.floor(photos.length / 2);
          image = photos[index]?.url || photos[0].url;
        }

        const costValue = poi.biz_ext?.cost || '0';

        return {
          id: poi.id,
          name: poi.name,
          image: image.replace('http:', 'https:'),
          rating: poi.biz_ext?.rating || '4.0',
          price: (costValue === '[]' || !costValue) ? '0' : costValue,
          isFree: parseInt(costValue) === 0 || costValue === '' || costValue === '[]',
          distance: parseInt(poi.distance || '0'),
          address: poi.address,
          tags: AmapSpotService.parseProTags(poi),
          isMuseum: /(博物馆|美术馆|纪念馆)/.test(poi.name)
        };
      });
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