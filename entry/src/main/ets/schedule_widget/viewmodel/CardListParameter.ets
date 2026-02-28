import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';

export interface MySchedule {
  id: string;
  title: string;
  location: string;
  description: string;
  date: Date;
}

export class CardListParameter {
  private schedules: MySchedule[] = [];

  async load(ctx?: common.Context): Promise<MySchedule[]> {
    let list: MySchedule[] = [];

    if (ctx) {
      const pref = await preferences.getPreferences(ctx, 'travel_db');
      const raw = await pref.get('schedules', '[]');
      const rawArray = JSON.parse(raw as string) as Array<Record<string, string>>;

      this.schedules = rawArray.map((item): MySchedule => {
        return {
          id: item.id,
          title: item.title,
          location: item.location,
          description: item.description,
          date: new Date(item.date)
        } as MySchedule;
      });
    } else {
      this.schedules = [];
    }

    this.schedules.sort((a, b) => a.date.getTime() - b.date.getTime());
    return this.schedules;
  }

  getUpcoming(limit: number): MySchedule[] {
    const now = Date.now();
    return this.schedules
      .filter(item => item.date.getTime() >= now)
      .slice(0, limit);
  }

  static getDaysLeft(date: Date): number {
    const diff = date.getTime() - Date.now();
    return Math.max(0, Math.ceil(diff / (1000 * 60 * 60 * 24)));
  }
}
