import { CardListComponent } from '../view/CardListComponent';
import { CardListParameter, MySchedule } from '../viewmodel/CardListParameter';

let storage = new LocalStorage();

@Entry(storage)
@Component
struct Schedule_widgetCard {
  @Prop formFactor: string | number = '';
  @LocalStorageProp('schedules') schedulesFromApp: MySchedule[] = [];
  @State schedules: MySchedule[] = [];
  @State isLarge: boolean = false;

  aboutToAppear() {
    this.isLarge = (this.formFactor === '2x4' || this.formFactor === 2);

    if (this.schedulesFromApp && this.schedulesFromApp.length > 0) {
      this.schedules = this.schedulesFromApp;
    }
  }

  build() {
    Stack() {
      CardListComponent({
        schedules: this.schedulesFromApp && this.schedulesFromApp.length > 0 ? this.schedulesFromApp : this.schedules,
        isLarge: this.isLarge
      })
    }
    .width('100%')
    .height('100%')
  }
}