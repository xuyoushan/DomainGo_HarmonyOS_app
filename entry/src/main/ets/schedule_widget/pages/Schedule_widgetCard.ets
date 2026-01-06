import { CardListComponent } from '../view/CardListComponent';
import { CardListParameter, MySchedule } from '../viewmodel/CardListParameter';

let storage = new LocalStorage();

@Entry(storage)
@Component
struct Schedule_widgetCard {
  /** 必须传入 Widget 表格大小 */
  @Prop formFactor: string | number = '';

  /** * 核心：通过 LocalStorageProp 接收数据
   * 对应 EntryFormAbility.ets 中 updateForm 推送的 'schedules' 键
   */
  @LocalStorageProp('schedules') schedulesFromApp: MySchedule[] = [];

  @State schedules: MySchedule[] = [];
  @State isLarge: boolean = false;

  aboutToAppear() {
    // 判定尺寸逻辑
    this.isLarge = (this.formFactor === '2x4' || this.formFactor === 2);

    // 如果 localSchedules 为空（比如首次启动），尝试同步 schedulesFromApp
    if (this.schedulesFromApp && this.schedulesFromApp.length > 0) {
      this.schedules = this.schedulesFromApp;
    }
  }

  build() {
    Stack() {
      CardListComponent({
        // 优先使用同步过来的数据
        schedules: this.schedulesFromApp && this.schedulesFromApp.length > 0 ? this.schedulesFromApp : this.schedules,
        isLarge: this.isLarge
      })
    }
    .width('100%')
    .height('100%')
  }
}