import { router, promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import preferences from '@ohos.data.preferences'
import { geoLocationManager } from '@kit.LocationKit'
import { http } from '@kit.NetworkKit'

class RegeoInfo {formatted_address: string = ''}
class AMapRegeoResult {status: string = ''
  regeocode: RegeoInfo = new RegeoInfo()
}
interface NoteItem { id: number, content: string, time: string, tags: string[], images: string[], lastEdit: number, location?: string }
interface SuggestionTip { name: string;district: string;address: string; }
interface AMapTipsResult { status: string;tips: SuggestionTip[]; }

@Entry
@Component
struct NoteView {
  @State notes: NoteItem[] = []
  @State editorVisible: boolean = false
  @State detailNote: NoteItem | null = null
  @State selectedImages: string[] = []
  @State inputText: string = ''
  @State inputTags: string = ''
  @State editingId: number | null = null
  @State keyword: string = ''
  @State previewImage: string | null = null
  @State currentLocation: string = ''
  @State isLocating: boolean = false
  @State suggestions: SuggestionTip[] = []
  @State showSuggestions: boolean = false
  @StorageLink('currentCity') cityContext: string = ''

  private colorPageBg: string = '#F4F1EC'
  private colorCard: string = '#FBFAF7'
  private colorPrimary: string = '#2F4A5A'
  private colorSecondary: string = '#9C6B3F'
  private colorMuted: string = '#8C857B'
  private amapKey: string = 'd4552bc3e20af2857f9cfd5ac95ded1d' // 高德API Key

  private pref: preferences.Preferences | null = null

  pageTransition() {
    PageTransitionEnter({ duration: 350, curve: Curve.Smooth }).slide(SlideEffect.Right)
    PageTransitionExit({ duration: 350, curve: Curve.Smooth }).slide(SlideEffect.Right)
  }

  async aboutToAppear() {
    this.pref = await preferences.getPreferences(getContext(this), 'note_store')
    const raw = this.pref.getSync('notes', '[]') as string
    this.notes = JSON.parse(raw) as NoteItem[]
  }

  async selectImages() {
    try {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      PhotoSelectOptions.maxSelectNumber = 3;
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      let photoSelectResult = await photoPicker.select(PhotoSelectOptions);

      if (photoSelectResult.photoUris.length > 0) {
        this.selectedImages = [...this.selectedImages, ...photoSelectResult.photoUris].slice(0, 3)
      }
    } catch (err) {
      console.error('Picker failed', JSON.stringify(err));
    }
  }

  async fetchSuggestions(keyword: string) {
    if (!keyword) {
      const targetCity = this.cityContext || '全国'
      keyword = targetCity.replace('市', '')
    }

    try {
      let url = `https://restapi.amap.com/v3/assistant/inputtips?key=${this.amapKey}&keywords=${encodeURIComponent(keyword)}&city=${encodeURIComponent(this.cityContext)}&datatype=all`;
      let httpRequest = http.createHttp();
      let response = await httpRequest.request(url);

      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as AMapTipsResult;
        if (result.status === '1') {
          this.suggestions = result.tips.filter(t => typeof t.name === 'string');
          this.showSuggestions = this.suggestions.length > 0;
        }
      }
    } catch (err) {
      console.error('预测失败', JSON.stringify(err));
    }
  }

  async fetchLocation() {
    this.isLocating = true
    try {
      let request: geoLocationManager.LocationRequest = {
        'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
        'scenario': geoLocationManager.LocationRequestScenario.UNSET,
        'maxAccuracy': 0
      };
      let location = await geoLocationManager.getCurrentLocation(request);

      let url = `https://restapi.amap.com/v3/regeo?key=${this.amapKey}&location=${location.longitude},${location.latitude}`;
      let httpRequest = http.createHttp();
      let response = await httpRequest.request(url);

      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as AMapRegeoResult;
        if (result.status === '1') {
          this.currentLocation = result.regeocode.formatted_address;
        }
      }
    } catch (err) {
      console.error('寻踪失败', JSON.stringify(err));
      promptAction.showToast({ message: '云深不知处，定位失败' });
    } finally {
      this.isLocating = false
    }
  }

  private now(): string {
    const d = new Date()
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()} ${d.getHours()}:${String(d.getMinutes()).padStart(2, '0')}`
  }

  private persist() {
    this.pref?.putSync('notes', JSON.stringify(this.notes))
    this.pref?.flush()
  }

  private wordCount(text: string): number {
    return text.replace(/\s+/g, '').length
  }

  private openEditor(note?: NoteItem) {
    this.editorVisible = true
    this.detailNote = null

    if (note) {
      this.editingId = note.id
      this.inputText = note.content
      this.inputTags = note.tags.join(',')
      this.selectedImages = [...note.images]
      this.currentLocation = note.location || ''
    } else {
      this.editingId = null
      this.inputText = ''
      this.inputTags = ''
      this.selectedImages = []
      this.currentLocation = ''
      this.fetchLocation()
    }
  }

  private save() {
    if (!this.inputText.trim() && this.selectedImages.length === 0) return

    const tags = this.inputTags.split(/,|，/).map(t => t.trim()).filter(t => t)

    if (this.editingId !== null) {
      this.notes = this.notes.map((n: NoteItem): NoteItem => {
        if (n.id === this.editingId) {
          return {
            id: n.id, content: this.inputText, time: n.time,
            tags: tags, lastEdit: Date.now(), images: this.selectedImages,
            location: this.currentLocation
          }
        }
        return n
      })
    } else {
      const newNote: NoteItem = {
        id: Date.now(),
        content: this.inputText,
        time: this.now(),
        tags,
        images: this.selectedImages,
        lastEdit: Date.now(),
        location: this.currentLocation
      }
      this.notes = [newNote, ...this.notes]
    }

    this.persist()
    this.editorVisible = false
    this.editingId = null
    this.inputText = ''
    this.inputTags = ''
    this.currentLocation = ''
  }

  private remove(id: number) {
    this.notes = this.notes.filter(n => n.id !== id)
    this.persist()
    this.detailNote = null
  }

  build() {
    Stack() {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(22)
            .padding({ top: 12, bottom: 12 })
            .fontColor([this.colorPrimary])
            .onClick(() => {
              if (this.detailNote) {
                this.detailNote = null
              } else if (this.editorVisible) {
                this.editorVisible = false
              } else {
                router.back()
              }
            })

          Text(this.detailNote ? '内容详情' : (this.editorVisible ? '笔耕不辍' : '灵感笔记'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })
            .fontColor(this.colorPrimary)

          Blank()

          if (!this.editorVisible && !this.detailNote) {
            SymbolGlyph($r('sys.symbol.plus_circle_fill'))
              .fontSize(26)
              .fontColor([this.colorPrimary])
              .onClick(() => this.openEditor())
          } else if (this.editorVisible) {
            Text('记录')
              .fontColor(this.colorPrimary)
              .fontWeight(FontWeight.Bold)
              .fontSize(17)
              .onClick(() => this.save())
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor(this.colorPageBg)

        if (!this.detailNote && !this.editorVisible) {
          TextInput({ placeholder: '搜索过往足迹或标签', text: this.keyword })
            .margin({ left: 16, right: 16, bottom: 8 })
            .backgroundColor('#E6E1D8')
            .placeholderColor(this.colorMuted)
            .onChange(v => this.keyword = v)
        }

        if (this.editorVisible) {
          Column() {
            Column() {
              Row() {
                SymbolGlyph($r('sys.symbol.location_right_fill'))
                  .fontSize(14)
                  .fontColor([this.isLocating ? this.colorMuted : this.colorSecondary])

                TextInput({ text: this.currentLocation, placeholder: '在此标注足迹地点...' })
                  .fontSize(13)
                  .fontColor(this.colorMuted)
                  .backgroundColor(Color.Transparent)
                  .layoutWeight(1)
                  .padding(0)
                  .margin({ left: 4 })
                  .onFocus(() => { this.fetchSuggestions(this.currentLocation) })
                  .onChange((v) => {
                    this.currentLocation = v
                    if (this.showSuggestions) {this.fetchSuggestions(v)}})

                if (this.isLocating) {
                  LoadingProgress().width(18).height(18).color(this.colorSecondary)
                } else {
                  SymbolGlyph($r('sys.symbol.arrow_clockwise'))
                    .fontSize(12)
                    .margin({ left: 8 })
                    .onClick(() => this.fetchLocation())
                }
              }
              .margin({ bottom: 0, left: 4, right: 4 })
              .padding({ bottom: 6 })
              .width('100%')
              .border({ width: { bottom: 0.5 }, color: '#D1CDC2' })

              if (this.showSuggestions && this.suggestions.length > 0) {
                Column() {
                  List() {
                    ForEach(this.suggestions, (tip: SuggestionTip) => {
                      ListItem() {
                        Column() {
                          Text(tip.name)
                            .fontSize(14)
                            .fontColor(this.colorPrimary)
                            .fontWeight(FontWeight.Medium)
                          if (tip.address && typeof tip.address === 'string' && tip.address.length > 0) {
                            Text(tip.district + tip.address)
                              .fontSize(10)
                              .fontColor(this.colorMuted)
                              .margin({ top: 2 })
                              .maxLines(1)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                          }
                        }
                        .width('100%')
                        .alignItems(HorizontalAlign.Start)
                        .padding({ top: 12, bottom: 12, left: 8, right: 8 })
                        .onClick(() => {
                          this.showSuggestions = false;
                          this.suggestions = [];
                          this.currentLocation = tip.name;
                        })
                      }
                      .border({ width: { bottom: 0.5 }, color: '#F2EFED' })
                    })
                  }
                  .width('100%')
                  .scrollBar(BarState.Off)
                }
                .constraintSize({ maxHeight: 200 })
                .width('100%')
                .backgroundColor(this.colorCard)
                .borderRadius({ bottomLeft: 12, bottomRight: 12 })
                .shadow({ radius: 15, color: '#15000000', offsetY: 8 })
                .zIndex(100)
              }
            }
            .width('100%')
            .margin({ bottom: 10 })

            TextArea({ placeholder: '写下此刻的行走与所见…', text: this.inputText })
              .height(180)
              .backgroundColor(Color.Transparent)
              .fontSize(17)
              .lineHeight(28)
              .fontColor(this.colorPrimary)
              .onChange(v => this.inputText = v)
              .onFocus(() => { this.showSuggestions = false })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.selectedImages, (img: string) => {
                Stack({ alignContent: Alignment.TopEnd }) {
                  Image(img)
                    .width(100).height(100).borderRadius(12).margin(4)
                  SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
                    .fontColor(['#FF4D4F'])
                    .fontSize(20)
                    .offset({ x: -4, y: 4 })
                    .onClick(() => {
                      promptAction.showDialog({
                        title: '移除画面',
                        message: '确定移除此画面吗？记录将不再包含此瞬间。',
                        buttons: [
                          { text: '移除', color: '#FF4D4F' },
                          { text: '保留', color: this.colorPrimary }
                        ]
                      }).then(data => {
                        if (data.index === 0) {
                          this.selectedImages = this.selectedImages.filter(i => i !== img)
                        }
                      })
                    })
                }
              })
              if (this.selectedImages.length < 3) {
                Column() {
                  SymbolGlyph($r('sys.symbol.plus')).fontSize(30).fontColor([this.colorMuted])
                }
                .width(100).height(100).borderRadius(12).margin(4)
                .backgroundColor('#E6E1D8')
                .justifyContent(FlexAlign.Center)
                .onClick(() => this.selectImages())
              }
            }.margin({ top: 10 })

            TextInput({ placeholder: '在此标注主题标签...', text: this.inputTags })
              .margin({ top: 12 })
              .backgroundColor(Color.Transparent)
              .placeholderColor(this.colorMuted)
              .onChange(v => this.inputTags = v)

            Row() {
              Text(`记述共 ${this.wordCount(this.inputText)} 字`)
                .fontSize(13)
                .fontColor(this.colorMuted)

              Blank()

              Text('阁笔')
                .fontSize(15)
                .fontColor(this.colorMuted)
                .margin({ right: 20 })
                .onClick(() => {
                  this.editorVisible = false
                  this.editingId = null
                  this.inputText = ''
                  this.inputTags = ''
                  this.selectedImages = []
                  this.currentLocation = ''
                })
              Text('完成记录')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.colorPrimary)
                .onClick(() => this.save())
            }
            .margin({ top: 20 })
            .width('100%')
          }
          .padding(16).onClick(() => {if (this.showSuggestions) {this.showSuggestions = false}})
          .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 50 })))
        }

        if (this.detailNote) {
          Scroll() {
            Column() {
              Row() {
                Text(`📍 ${this.detailNote.time}`)
                  .fontSize(15)
                  .fontColor(this.colorSecondary)
                if (this.detailNote.location) {
                  Text(` · ${this.detailNote.location}`)
                    .fontSize(14)
                    .fontColor(this.colorMuted)
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .width('100%')
              .margin({ bottom: 12 })

              if (this.detailNote.images.length > 0) {
                Scroll() {
                  Row({ space: 10 }) {
                    ForEach(this.detailNote.images, (img: string) => {
                      Image(img)
                        .width(220).height(160).borderRadius(12)
                        .onClick(() => this.previewImage = img)
                    })
                  }
                }.margin({ top: 12, bottom: 12 }).scrollBar(BarState.Off)
              }

              Text(this.detailNote.content)
                .fontSize(20)
                .fontColor(this.colorPrimary)
                .margin({ top: 10 })
                .textAlign(TextAlign.Start)
                .lineHeight(34)
                .width('100%')

              Row({ space: 8 }) {
                ForEach(
                  this.detailNote.tags,
                  (t: string) => {
                    Text(`# ${t}`)
                      .fontSize(12)
                      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                      .backgroundColor('#E6E1D8')
                      .fontColor(this.colorMuted)
                      .borderRadius(6)
                  }
                )
              }
              .margin({ top: 24 })
              .width('100%')

              Row({ space: 24 }) {
                Text('润色')
                  .fontColor(this.colorPrimary)
                  .onClick(() => this.openEditor(this.detailNote!))

                Text('抹去')
                  .fontColor('#A39480')
                  .onClick(() => {
                    promptAction.showDialog({
                      title: '抹去记录',
                      message: '此段记忆将从纸面消失，确定吗？',
                      buttons: [
                        { text: '确定', color: '#FF4D4F' },
                        { text: '保留', color: this.colorPrimary }
                      ]
                    }).then(data => {
                      if (data.index === 0) this.remove(this.detailNote!.id)
                    })
                  })
              }
              .margin({ top: 40 })
              .width('100%')
              .justifyContent(FlexAlign.End)
            }
            .padding(20)
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.95, y: 0.95 })))
        }

        if (!this.editorVisible && !this.detailNote) {
          List({ space: 12 }) {
            ForEach(
              this.notes
                .filter(n => {
                  const hasContent = n.content && n.content.includes(this.keyword);
                  const hasTags = n.tags && n.tags.join(',').includes(this.keyword);
                  return hasContent || hasTags;
                })
                .sort((a, b) => {
                  const aTags = a.tags ? a.tags.join(',') : '';
                  const bTags = b.tags ? b.tags.join(',') : '';

                  const aTagMatch = aTags.includes(this.keyword) && this.keyword !== '' ? 1 : 0;
                  const bTagMatch = bTags.includes(this.keyword) && this.keyword !== '' ? 1 : 0;

                  if (aTagMatch !== bTagMatch) {
                    return bTagMatch - aTagMatch;
                  }
                  return b.id - a.id;
                }),
              (item: NoteItem) => {
                ListItem() {
                  Column() {
                    Row() {
                      Text(item.time)
                        .fontSize(14)
                        .fontColor(this.colorSecondary)
                      if (item.location) {
                        Text(` · ${item.location}`)
                          .fontSize(11)
                          .fontColor(this.colorMuted)
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .layoutWeight(1)
                          .margin({ left: 4 })
                      }
                    }.width('100%')

                    Text(item.content)
                      .fontSize(16)
                      .fontColor(this.colorPrimary)
                      .margin({ top: 6 })
                      .maxLines(3)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .lineHeight(22)

                    if (item.images.length > 0) {
                      Row({ space: 4 }) {
                        ForEach(item.images.slice(0, 3), (img: string) => {
                          Image(img).width(50).height(50).borderRadius(6).objectFit(ImageFit.Cover)
                        })
                      }.margin({ top: 8 })
                    }

                    if (this.keyword && item.tags.length > 0) {
                      Row({ space: 4 }) {
                        ForEach(item.tags, (tag: string) => {
                          Text(tag).fontSize(10).fontColor(this.colorSecondary)
                        })
                      }.margin({ top: 6 })
                    }
                  }
                  .padding(16)
                  .width('100%')
                  .backgroundColor(this.colorCard)
                  .borderRadius(14)
                  .onClick(() => {
                    animateTo({ duration: 300 }, () => {
                      this.detailNote = item
                    })
                  })
                }
              },
              (item: NoteItem): string => `${item.id}_${this.keyword}`
            )
          }
          .padding(16)
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.colorPageBg)
      if (this.previewImage) {
        Column() {
          Image(this.previewImage)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .onClick(() => this.previewImage = null)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F0000000')
        .zIndex(100)
        .transition(TransitionEffect.OPACITY)
        .onClick(() => this.previewImage = null)
      }
    }
  }
}