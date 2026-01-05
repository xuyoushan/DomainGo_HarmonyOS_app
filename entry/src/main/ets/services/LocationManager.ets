import { geoLocationManager } from '@kit.LocationKit'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import http from '@ohos.net.http'

/* ========= 对外暴露的类型 ========= */
export interface RealLocation {
  latitude: number
  longitude: number
  accuracy: number
  timestamp: number // 新增缓存时间戳
}

/* ========= 高德逆地理最小结构 ========= */
interface AMapAddressComponent {
  city?: string | string[]
  province?: string
}

interface AMapReGeocode {
  addressComponent?: AMapAddressComponent
}

interface AMapGeoResult {
  regeocode?: AMapReGeocode
}

interface LocationResult {
  latitude: number
  longitude: number
  accuracy?: number
}

export class LocationManager {
  private static readonly AMAP_KEY: string = 'd4552bc3e20af2857f9cfd5ac95ded1d'

  // 缓存定位 + 时间戳
  private static cachedLocation: RealLocation | null = null
  private static CACHE_MAX_AGE = 30 * 1000 // 30秒缓存

  /* ========= 权限 ========= */
  static async requestPermission(
    context: common.UIAbilityContext
  ): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager()
    try {
      const res = await atManager.requestPermissionsFromUser(context, [
        'ohos.permission.APPROXIMATELY_LOCATION',
        'ohos.permission.LOCATION'
      ])
      return res.authResults.length > 0 && res.authResults[0] === 0
    } catch {
      return false
    }
  }

  /* ========= GuideView 唯一使用的入口 ========= */
  static async getLocation(
    context: common.UIAbilityContext
  ): Promise<RealLocation> {
    const now = Date.now()
    if (
      LocationManager.cachedLocation &&
        now - LocationManager.cachedLocation.timestamp < LocationManager.CACHE_MAX_AGE
    ) {
      return LocationManager.cachedLocation
    }

    const isAuth = await LocationManager.requestPermission(context)
    if (!isAuth) throw new Error('定位权限未开启')

    const loc = (await geoLocationManager.getCurrentLocation({
      priority: geoLocationManager.LocationRequestPriority.ACCURACY,
      scenario: geoLocationManager.LocationRequestScenario.NAVIGATION,
      maxAccuracy: 100
    })) as LocationResult

    const real: RealLocation = {
      latitude: loc.latitude,
      longitude: loc.longitude,
      accuracy: loc.accuracy ?? 999,
      timestamp: now
    }

    LocationManager.cachedLocation = real
    return real
  }

  /* ========= 探索页等需要城市名的场景 ========= */
  static async getRealCity(
    context: common.UIAbilityContext
  ): Promise<string> {
    try {
      const isAuth = await LocationManager.requestPermission(context)
      if (!isAuth) return '定位失败'

      const loc = (await geoLocationManager.getCurrentLocation({
        priority: geoLocationManager.LocationRequestPriority.ACCURACY,
        scenario: geoLocationManager.LocationRequestScenario.NAVIGATION,
        maxAccuracy: 100
      })) as LocationResult

      const city = await LocationManager.reverseGeocode(loc.latitude, loc.longitude)
      return city ?? '定位失败'
    } catch {
      return '定位失败'
    }
  }

  private static async reverseGeocode(latitude: number, longitude: number): Promise<string | null> {
    const httpRequest = http.createHttp()
    try {
      const url = `https://restapi.amap.com/v3/geocode/regeo` +
        `?key=${LocationManager.AMAP_KEY}` +
        `&location=${longitude},${latitude}` +
        `&radius=1000&extensions=base`

      const res = await httpRequest.request(url)
      if (res.responseCode !== 200) return null

      const result: AMapGeoResult = JSON.parse(res.result as string) as AMapGeoResult
      const comp: AMapAddressComponent | undefined = result.regeocode?.addressComponent
      if (!comp) return null

      if (typeof comp.city === 'string' && comp.city.length > 0) return comp.city
      if (Array.isArray(comp.city) && comp.city.length > 0) return comp.city[0]
      return comp.province ?? null
    } catch {
      return null
    } finally {
      httpRequest.destroy()
    }
  }

  /* ========= 清除缓存 ========= */
  static clearCache(): void {
    LocationManager.cachedLocation = null
  }
}
