import { calendarManager } from '@kit.CalendarKit';
import { common, abilityAccessCtrl } from '@kit.AbilityKit';
import { promptAction, router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import preferences from '@ohos.data.preferences';
import http from '@ohos.net.http';
import { formProvider, formBindingData } from '@kit.FormKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit'; // 新增：相册选择器
import { LocationManager } from '../../../services/LocationManager';

// --- 1. 定义日程接口：增加截图凭证字段 ---
interface MySchedule {
  id: string;
  title: string;
  location: string;
  description: string;
  date: Date;
  evidenceImage?: string; // ✅ 新增：存储截图的路径
}

interface AmapPoi { name: string; address: string; }
interface AmapResponse { status: string; pois: AmapPoi[]; }

@Entry
@Component
struct TravelScheduleView {
  @State eventTitle: string = '';
  @State eventLocation: string = '';
  @State eventDescription: string = '';
  @State selectedDate: Date = new Date();
  @State isSubmitting: boolean = false;

  // --- 新增：截图管理状态 ---
  @State evidenceImage: string = ''; // 当前编辑中的截图路径
  @State showFullImage: boolean = false; // 全屏预览控制
  @State previewImageUrl: string = ''; // 预览图地址

  @State localSchedules: MySchedule[] = [];
  @State isManageMode: boolean = false;
  @State editingId: string | null = null;

  @State showLocationSearch: boolean = false;
  @State searchKey: string = '';
  @State searchResults: AmapPoi[] = [];
  private readonly AMAP_KEY: string = 'd4552bc3e20af2857f9cfd5ac95ded1d';

  private calendarMgr: calendarManager.CalendarManager | null = null;
  private pref: preferences.Preferences | null = null;

  async aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params.presetTitle) {
      // ✅ 2. 自动填充与截图关联逻辑
      this.eventTitle = params.presetTitle;
      this.eventLocation = params.presetLocation;
      this.eventDescription = params.presetDesc;
      // 捕获从 WebView 传过来的自动截图
      if (params.evidenceImage) {
        this.evidenceImage = params.evidenceImage;
      }
      this.isManageMode = false;
    }

    this.initCalendarManager();
    await this.initPreferences();
  }

  // --- 新增：系统相册联动（PhotoPicker） ---
  async selectImageFromAlbum() {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      if (photoSelectResult && photoSelectResult.photoUris.length > 0) {
        this.evidenceImage = photoSelectResult.photoUris[0];
        promptAction.showToast({ message: '凭证已关联' });
      }
    } catch (err) {
      console.error('选择图片失败');
    }
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
        date: new Date(item.date),
        evidenceImage: item.evidenceImage // ✅ 恢复图片路径
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
      date: this.selectedDate,
      evidenceImage: this.evidenceImage // ✅ 保存截图
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
      const fId = await this.pref?.get('current_form_id', '') as string;
      if (fId) {
        await formProvider.updateForm(fId, formBindingData.createFormBindingData({
          'schedules': this.localSchedules
        }));
      }
    } catch (err) { console.error('Card update failed'); }

    const context = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR']);
      if (grantStatus.authResults[0] === 0 && grantStatus.authResults[1] === 0) {
        await this.doWriteCalendar();
      } else {
        promptAction.showToast({ message: '本地已保存，请开启权限同步日历' });
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
    this.evidenceImage = ''; // ✅ 重置截图
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
        message: '已存入系统日历，凭证已就绪',
        buttons: [{ text: '完成', color: '#007DFF' }]
      }).then(() => { this.exitEditing(); });
    } catch (error) { promptAction.showToast({ message: '日历写入失败' }); }
  }

  build() {
    Stack() {
      Column() {
        // --- 页头 ---
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
          Text(this.isManageMode ? '行程管理' : '完善日程').fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 12 })
          Blank()
          Text(this.isManageMode ? '添加' : '列表').fontSize(16).fontColor('#007DFF')
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
              this.EvidenceUploadCard() // ✅ 新增：上传凭证卡片
              this.TipsCard()

              Button() {
                if (this.isSubmitting) {
                  LoadingProgress().width(24).height(24).color(Color.White)
                } else {
                  Text(this.editingId ? '确认更新' : '确认并同步日历').fontColor(Color.White).fontWeight(FontWeight.Bold)
                }
              }
              .width('100%').height(54).borderRadius(27).backgroundColor('#007DFF').margin({ top: 10, bottom: 40 })
              .onClick(() => this.handleSyncAction())
            }.padding(16)
          }.layoutWeight(1)
        }
      }.width('100%').height('100%').backgroundColor('#F2F3F5')

      // ✅ 3. 全屏大图预览层
      if (this.showFullImage) {
        Stack() {
          Rect().width('100%').height('100%').fill(Color.Black).opacity(0.95)
          Image(this.previewImageUrl)
            .width('100%')
            .objectFit(ImageFit.Contain)
            .onClick(() => { this.showFullImage = false })

          SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
            .fontSize(35).fontColor([Color.White])
            .position({ x: '85%', y: '5%' })
            .onClick(() => { this.showFullImage = false })
        }
        .width('100%').height('100%').zIndex(999)
      }

      if (this.showLocationSearch) {
        this.LocationSearchPanel()
      }
    }
  }

  @Builder FormCard() {
    Column({ space: 12 }) {
      this.InputLabel('日程主题')
      TextArea({ placeholder: '输入主题...', text: this.eventTitle })
        .constraintSize({ minHeight: 50 })
        .padding(10)
        .backgroundColor('#F5F5F7').borderRadius(10)
        .onChange((v: string) => { this.eventTitle = v; })

      this.InputLabel('地点')
      Row() {
        TextInput({ placeholder: '选择地点', text: this.eventLocation })
          .layoutWeight(1).backgroundColor(Color.Transparent)
          .onChange(v => this.eventLocation = v)
        SymbolGlyph($r('sys.symbol.mappin_and_rectangle')).fontSize(22).fontColor(['#007DFF'])
          .onClick(() => { this.showLocationSearch = true; this.searchPoi(''); })
      }.width('100%').height(50).backgroundColor('#F5F5F7').borderRadius(10).padding({ right: 10 })

      this.InputLabel('提醒日期')
      DatePicker({ start: new Date(), selected: this.selectedDate })
        .height(140).onDateChange((v) => this.selectedDate = v)
    }
    .padding(16).backgroundColor(Color.White).borderRadius(16).alignItems(HorizontalAlign.Start)
  }

  // ✅ 新增：凭证上传编辑卡片
  @Builder EvidenceUploadCard() {
    Column({ space: 10 }) {
      // ✅ 修改点 1：动态标题
      this.InputLabel(this.eventTitle ? '预约凭证 (进门核验用)' : '行程附件')

      if (this.evidenceImage) {
        Stack({ alignContent: Alignment.TopEnd }) {
          Image(this.evidenceImage)
            .width('100%').height(150).borderRadius(10).objectFit(ImageFit.Cover)
            .onClick(() => {
              this.previewImageUrl = this.evidenceImage;
              this.showFullImage = true;
            })
          SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
            .fontSize(24).fontColor(['#FF4D4F']).margin(5)
            .onClick(() => { this.evidenceImage = '' })
        }
      } else {
        Row() {
          SymbolGlyph($r('sys.symbol.plus_square_fill')).fontSize(30).fontColor(['#999'])

          // ✅ 修改点 2：动态提示文字
          Text(this.eventTitle ? '点击上传预约成功截图' : '点击上传相关图片或凭证')
            .fontColor('#999').margin({ left: 10 })
        }
        .width('100%').height(100).justifyContent(FlexAlign.Center)
        .border({ width: 1, color: '#DDD', style: BorderStyle.Dashed }).borderRadius(10)
        .onClick(() => this.selectImageFromAlbum())
      }
    }
    .padding(16).backgroundColor(Color.White).borderRadius(16).alignItems(HorizontalAlign.Start)
  }

  @Builder ScheduleItemCard(item: MySchedule) {
    Row() {
      Column() {
        Text('距离').fontSize(10).fontColor('#999')
        Text(this.getDaysLeft(item.date)).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#007DFF')
        Text('天').fontSize(10).fontColor('#999')
      }.width(50).alignItems(HorizontalAlign.Center)

      Column({ space: 4 }) {
        Text(item.title).fontSize(16).fontWeight(FontWeight.Bold).maxLines(1)
        Text(item.location).fontSize(12).fontColor('#666').maxLines(1)
        Text(item.date.toLocaleDateString()).fontSize(10).fontColor('#999')
      }.layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: 10 })

      // ✅ 4. 卡片右侧显示缩略图，点击可放大
      if (item.evidenceImage) {
        Image(item.evidenceImage)
          .width(50).height(50).borderRadius(6).margin({ right: 10 })
          .onClick(() => {
            this.previewImageUrl = item.evidenceImage!;
            this.showFullImage = true;
          })
      }

      SymbolGlyph($r('sys.symbol.square_and_pencil')).fontSize(20).fontColor(['#007DFF'])
        .onClick(() => {
          this.editingId = item.id;
          this.eventTitle = item.title;
          this.eventLocation = item.location;
          this.eventDescription = item.description;
          this.selectedDate = item.date;
          this.evidenceImage = item.evidenceImage || '';
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
            await formProvider.updateForm(fId, formBindingData.createFormBindingData({ 'schedules': this.localSchedules }));
          }
        } catch (e) {}
        promptAction.showToast({ message: '日程已删除' });
      })
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
          }.onClick(() => { this.eventLocation = item.name; this.showLocationSearch = false; })
        })
      }.layoutWeight(1).divider({ strokeWidth: 1, color: '#F1F3F5' })
    }
    .width('100%').height('80%').backgroundColor(Color.White)
    .borderRadius({ topLeft: 20, topRight: 20 })
  }

  @Builder TipsCard() {
    Row() {
      SymbolGlyph($r('sys.symbol.watch')).fontSize(20).fontColor(['#007DFF'])
      Column() {
        Text('凭证管家').fontSize(13).fontWeight(FontWeight.Bold)
        Text('点击行程卡片缩略图可全屏出示二维码').fontSize(11).fontColor('#888').margin({ top: 2 })
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