import { CardListParameter, MySchedule } from '../viewmodel/CardListParameter';

@Component
export struct CardListComponent {
  @Prop schedules: MySchedule[] = [];
  @Prop isLarge: boolean = false;

  build() {
    Stack() {
      if (this.schedules.length === 0) {
        this.EmptyView()
      } else {
        Column() {
          if (this.isLarge) {
            this.ListView()
          } else {
            this.SingleView(this.schedules[0])
          }
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SingleView(item: MySchedule) {
    Column({ space: 6 }) {
      Text(item.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .maxLines(2);

      Text(item.location)
        .fontSize(12)
        .fontColor('#666')
        .maxLines(1);

      Text(`剩余 ${CardListParameter.getDaysLeft(item.date)} 天`)
        .fontSize(14)
        .fontColor('#007DFF')
        .margin({ top: 4 });
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }

  @Builder
  ListView() {
    Column({ space: 10 }) {
      ForEach(this.schedules, (item: MySchedule) => {
        Row() {
          Column({ space: 2 }) {
            Text(item.title)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .maxLines(1);

            Text(item.location)
              .fontSize(11)
              .fontColor('#888')
              .maxLines(1);
          }
          Blank()
          Text(`${CardListParameter.getDaysLeft(item.date)}天`)
            .fontSize(12)
            .fontColor('#007DFF');
        }
        .padding(10)
        .backgroundColor('#F5F6F8')
        .borderRadius(8);
      })
    }
    .padding(12)
    .width('100%')
    .height('100%')
  }

  @Builder
  EmptyView() {
    Column() {
      Text('暂无行程')
        .fontSize(14)
        .fontColor('#999');
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }
}
