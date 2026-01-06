import { calendarManager } from '@kit.CalendarKit';
import { common, abilityAccessCtrl } from '@kit.AbilityKit';
import { promptAction, router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import preferences from '@ohos.data.preferences';
import http from '@ohos.net.http';
import { formProvider, formBindingData } from '@kit.FormKit';
import { LocationManager } from '../../services/LocationManager';

// 定义日程接口
interface MySchedule {
  id: string;
  title: string;
  location: string;
  description: string;
  date: Date;
}

// 高德POI接口
interface AmapPoi { name: string; address: string; }
interface AmapResponse { status: string; pois: AmapPoi[]; }

@Entry
@Component
struct TravelScheduleView {
  // --- 状态变量 ---
  @State eventTitle: string = '';
  @State eventLocation: string = '';
  @State eventDescription: string = '';
  @State selectedDate: Date = new Date();
  @State isSubmitting: boolean = false;

  // --- 本地管理状态 ---
  @State localSchedules: MySchedule[] = [];
  @State isManageMode: boolean = false;
  @State editingId: string | null = null;

  // --- 新增：地图搜索状态 ---
  @State showLocationSearch: boolean = false;
  @State searchKey: string = '';
  @State searchResults: AmapPoi[] = [];
  private readonly AMAP_KEY: string = 'd4552bc3e20af2857f9cfd5ac95ded1d';

  private calendarMgr: calendarManager.CalendarManager | null = null;
  private pref: preferences.Preferences | null = null;

  async aboutToAppear() {
    this.initCalendarManager();
    await this.initPreferences();
  }

  async initPreferences() {
    const context = getContext(this) as common.UIAbilityContext;
    this.pref = await preferences.getPreferences(context, 'travel_db');
    const data = await this.pref.get('schedules', '[]');
    const rawList = JSON.parse(data as string) as Array<MySchedule>;
    const processedList: MySchedule[] = [];
    for (let i = 0; i < rawList.length; i++) {
      const item = rawList[i];
      const schedule: MySchedule = {
        id: item.id,
        title: item.title,
        location: item.location,
        description: item.description,
        date: new Date(item.date)
      };
      processedList.push(schedule);
    }
    this.localSchedules = processedList;
  }

  async saveToDisk() {
    if (this.pref) {
      await this.pref.put('schedules', JSON.stringify(this.localSchedules));
      await this.pref.flush();
    }
  }

  // 地图搜索逻辑
  async searchPoi(keyword: string) {
    let httpRequest = http.createHttp();
    try {
      let url = `https://restapi.amap.com/v3/place/text?keywords=${encodeURIComponent(keyword || '景点')}&key=${this.AMAP_KEY}`;
      let response = await httpRequest.request(url);
      if (response.responseCode === 200) {
        let res = JSON.parse(response.result as string) as AmapResponse;
        this.searchResults = res.pois || [];
      }
    } catch (err) { console.error('搜索失败'); }
  }

  getDaysLeft(targetDate: Date): string {
    const now = new Date();
    const diff = targetDate.getTime() - now.getTime();
    const days = Math.ceil(diff / (1000 * 60 * 60 * 24));
    return days > 0 ? days.toString() : '0';
  }

  private initCalendarManager() {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      this.calendarMgr = calendarManager.getCalendarManager(context);
    } catch (e) {
      console.error('[Schedule] CalendarManager初始化失败', JSON.stringify(e));
    }
  }

  async handleSyncAction() {
    if (!this.eventTitle.trim()) {
      promptAction.showToast({ message: '请输入日程名称' });
      return;
    }
    if (this.isSubmitting) return;
    this.isSubmitting = true;
    const newSchedule: MySchedule = {
      id: this.editingId === null ? Date.now().toString() : this.editingId,
      title: this.eventTitle,
      location: this.eventLocation,
      description: this.eventDescription,
      date: this.selectedDate
    };
    if (this.editingId) {
      const index = this.localSchedules.findIndex(s => s.id === this.editingId);
      this.localSchedules[index] = newSchedule;
    } else {
      this.localSchedules.push(newSchedule);
    }
    this.localSchedules.sort((a: MySchedule, b: MySchedule) => a.date.getTime() - b.date.getTime());
    await this.saveToDisk();
    try {
      // 修正：从数据库取出保存好的 formId
      const fId = await this.pref?.get('current_form_id', '') as string;
      if (fId) {
        await formProvider.updateForm(fId, formBindingData.createFormBindingData({
          'schedules': this.localSchedules // 这里的 key 'schedules' 必须和卡片组件接收的一致
        }));
      }
    } catch (err) {
      console.error('Card update failed');
    }
    const context = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR']);
      if (grantStatus.authResults[0] === 0 && grantStatus.authResults[1] === 0) {
        await this.doWriteCalendar();
      } else {
        promptAction.showToast({ message: '本地已保存，真机需开启日历权限' });
        this.exitEditing();
      }
    } catch (err) { this.exitEditing(); } finally { this.isSubmitting = false; }
  }

  private exitEditing() {
    this.isManageMode = true;
    this.resetForm();
  }

  private resetForm() {
    this.eventTitle = '';
    this.eventLocation = '';
    this.eventDescription = '';
    this.editingId = null;
    this.selectedDate = new Date();
  }

  private async doWriteCalendar() {
    if (!this.calendarMgr) return;
    try {
      const calendar = await this.calendarMgr.getCalendar();
      const startTimestamp = this.selectedDate.getTime();
      const event: calendarManager.Event = {
        title: `[寻域] ${this.eventTitle}`,
        location: { location: this.eventLocation },
        description: this.eventDescription,
        startTime: startTimestamp,
        endTime: startTimestamp + (90 * 60 * 1000),
        type: calendarManager.EventType.IMPORTANT,
        reminderTime: [15, 60]
      };
      await calendar.addEvent(event);
      promptAction.showDialog({
        title: '同步成功',
        message: '已存入系统日历，元服务卡片同步开启',
        buttons: [{ text: '完成', color: '#007DFF' }]
      }).then(() => { this.exitEditing(); });
    } catch (error) { promptAction.showToast({ message: '日历写入失败' }); }
  }

  build() {
    Stack() {
      Column() {
        // --- 精美页头 ---
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24)
            .onClick(() => {
              if (this.isManageMode) {
                this.isManageMode = false;
                this.resetForm();
              } else {
                router.back();
              }
            })
          Text(this.isManageMode ? '行程管理' : '新增行程').fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 12 })
          Blank()
          Text(this.isManageMode ? '添加' : '列表').fontSize(16).fontColor('#007DFF').fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.isManageMode = !this.isManageMode;
              if (!this.isManageMode) this.resetForm();
            })
        }
        .width('100%').padding({ left: 16, right: 16, top: 20, bottom: 10 })

        if (this.isManageMode) {
          List({ space: 12 }) {
            ForEach(this.localSchedules, (item: MySchedule) => {
              ListItem() { this.ScheduleItemCard(item) }
              .swipeAction({ end: this.DeleteButton(item.id) })
            })
          }.padding(16).layoutWeight(1).edgeEffect(EdgeEffect.Spring)
        } else {
          Scroll() {
            Column({ space: 20 }) {
              this.FormCard()
              this.TipsCard()
              Button() {
                if (this.isSubmitting) {
                  LoadingProgress().width(24).height(24).color(Color.White)
                } else {
                  Text(this.editingId ? '保存修改' : '存入系统日历').fontColor(Color.White).fontWeight(FontWeight.Bold)
                }
              }
              .width('100%').height(54).borderRadius(27).backgroundColor('#007DFF').margin({ top: 10, bottom: 40 })
              .onClick(() => this.handleSyncAction())
            }.padding(16)
          }.layoutWeight(1)
        }
      }.width('100%').height('100%').backgroundColor('#F2F3F5')

      // 地点搜索半屏弹窗
      if (this.showLocationSearch) {
        this.LocationSearchPanel()
      }
    }
  }

  @Builder FormCard() {
    Column({ space: 12 }) {
      this.InputLabel('日程主题')
      // 1. 自动增高且自动换行的 TextArea
      TextArea({ placeholder: '输入内容，换行自动增高...', text: this.eventTitle })
        .constraintSize({ minHeight: 50 }) // 代替 autoHeight
        .padding(10)
        .backgroundColor('#F5F5F7').borderRadius(10)
        .onChange((v: string) => { this.eventTitle = v; }) // 修正3：显式指定 string

      this.InputLabel('地点')
      // 2. 集成地图选点
      Row() {
        TextInput({ placeholder: '点击右侧图标定位', text: this.eventLocation })
          .layoutWeight(1).backgroundColor(Color.Transparent)
          .onChange(v => this.eventLocation = v)
        SymbolGlyph($r('sys.symbol.mappin_and_rectangle')).fontSize(22).fontColor(['#007DFF'])
          .onClick(() => {
            this.showLocationSearch = true;
            this.searchPoi('');
          })
      }.width('100%').height(50).backgroundColor('#F5F5F7').borderRadius(10).padding({ right: 10 })

      this.InputLabel('提醒日期')
      // 3. 动态日期限制与平滑翻动
      DatePicker({
        start: new Date(), // 锁定今天为起点
        end: new Date(new Date().getFullYear() + 5, 11, 31), // 限制未来5年
        selected: this.selectedDate
      })
        .height(140)
        .onDateChange((v) => this.selectedDate = v)

      this.InputLabel('备注')
      TextArea({ placeholder: '补充说明...', text: this.eventDescription })
        .height(100).backgroundColor('#F5F5F7').borderRadius(10)
        .onChange(v => this.eventDescription = v)
    }
    .padding(16).backgroundColor(Color.White).borderRadius(16).alignItems(HorizontalAlign.Start)
  }

  @Builder LocationSearchPanel() {
    Column() {
      Row() {
        Text('搜索位置').fontWeight(FontWeight.Bold)
        Blank()
        SymbolGlyph($r('sys.symbol.xmark')).onClick(() => this.showLocationSearch = false)
      }.width('100%').padding(20)

      Search({ placeholder: '输入关键字', value: this.searchKey }).width('90%')
        .onChange(v => { this.searchKey = v; this.searchPoi(v); })

      List() {
        ForEach(this.searchResults, (item: AmapPoi) => {
          ListItem() {
            Column() {
              Text(item.name).fontSize(16)
              Text(item.address).fontSize(12).fontColor('#999').margin({ top: 4 })
            }.width('100%').alignItems(HorizontalAlign.Start).padding(15)
          }.onClick(() => {
            this.eventLocation = item.name;
            this.showLocationSearch = false;
          })
        })
      }.layoutWeight(1).divider({ strokeWidth: 1, color: '#F1F3F5' })
    }
    .width('100%').height('80%').backgroundColor(Color.White)
    .borderRadius({ topLeft: 20, topRight: 20 })
    .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 300 }))
  }

  @Builder ScheduleItemCard(item: MySchedule) {
    Row() {
      Column() {
        Text('距离').fontSize(10).fontColor('#999')
        Text(this.getDaysLeft(item.date)).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#007DFF')
        Text('天').fontSize(10).fontColor('#999')
      }.width(50).alignItems(HorizontalAlign.Center)
      Column({ space: 4 }) {
        Text(item.title).fontSize(16).fontWeight(FontWeight.Bold)
        Text(item.location).fontSize(12).fontColor('#666')
        Text(item.date.toLocaleDateString()).fontSize(10).fontColor('#999')
      }.layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: 10 })
      SymbolGlyph($r('sys.symbol.square_and_pencil')).fontSize(20).fontColor(['#007DFF'])
        .onClick(() => {
          this.editingId = item.id;
          this.eventTitle = item.title;
          this.eventLocation = item.location;
          this.eventDescription = item.description;
          this.selectedDate = item.date;
          this.isManageMode = false;
        })
    }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(16)
  }

  @Builder DeleteButton(id: string) {
    Button('删除').backgroundColor('#FF4D4F').height('100%').width(80)
      .onClick(async () => {
        this.localSchedules = this.localSchedules.filter(s => s.id !== id);
        await this.saveToDisk();

        try {
          const fId = await this.pref?.get('current_form_id', '') as string;
          if (fId) {
            // 修正：删除后也要同步更新卡片数据
            await formProvider.updateForm(fId, formBindingData.createFormBindingData({
              'schedules': this.localSchedules
            }));
          }
        } catch (e) {}
        promptAction.showToast({ message: '日程已删除' });
      })
  }

  @Builder TipsCard() {
    Row() {
      SymbolGlyph($r('sys.symbol.watch')).fontSize(20).fontColor(['#007DFF'])
      Column() {
        Text('元服务：倒计时卡片').fontSize(13).fontWeight(FontWeight.Bold)
        Text('数据已加密存入磁盘，桌面卡片实时读取').fontSize(11).fontColor('#888').margin({ top: 2 })
      }.margin({ left: 12 }).alignItems(HorizontalAlign.Start)
    }.width('100%').padding(16).backgroundColor('#E6F1FF').borderRadius(12)
  }

  @Builder InputLabel(text: string) {
    Row() {
      Circle({ width: 4, height: 4 }).fill('#007DFF').margin({ right: 8 })
      Text(text).fontSize(14).fontColor('#666').fontWeight(FontWeight.Medium)
    }.margin({ bottom: 4, top: 4 })
  }
}