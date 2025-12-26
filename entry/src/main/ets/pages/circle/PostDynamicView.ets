import router from '@ohos.router';
import http from '@ohos.net.http';
import { PostItem } from '../../models/PostItem';
import { PROVINCE_CITY_DATA } from '../explore/CityData';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
// 修正：在 API 12 中推荐使用 @kit 导入或确保引用路径正确
import { promptAction } from '@kit.ArkUI';

interface AmapPoi {
  name: string;
  address: string;
  adname: string;
}
interface AmapResponse {
  status: string;
  pois: AmapPoi[];
}

@Entry
@Component
struct PostDynamicView {
  @State postText: string = '';
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @State selectedLocation: string = '选择位置';
  @StorageLink('mainIndex') mainIndex: number = 0;

  @State selectedImages: (string | Resource)[] = [];
  @State tags: string[] = ['旅行', '美食', '探店', '打卡'];
  @State selectedTags: string[] = [];
  @State showLocationSearch: boolean = false;
  @State searchKey: string = '';
  @State searchResults: AmapPoi[] = [];
  @State isSearching: boolean = false;

  // --- 1. 相册选择逻辑 ---
  async selectImages() {
    try {
      let photoSelectOptions: photoAccessHelper.PhotoSelectOptions = {
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 9 - this.selectedImages.length
      };
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      let photoSelectResult = await photoPicker.select(photoSelectOptions);

      if (photoSelectResult && photoSelectResult.photoUris.length > 0) {
        // 这里的 push 不会触发 Grid 刷新，需要通过解构重新赋值
        this.selectedImages = [...this.selectedImages, ...photoSelectResult.photoUris];
      }
    } catch (err) {
      promptAction.showToast({ message: '选择图片失败' });
    }
  }

  // --- 2. 标签提取逻辑 ---
  extractHashTags(text: string): string[] {
    if (!text) return [];
    let tags: string[] = [];
    let words = text.split(/\s+/);
    words.forEach(word => {
      if (word.startsWith('#') && word.length > 1) {
        tags.push(word.substring(1));
      }
    });
    return tags;
  }

  // --- 3. 地点搜索逻辑 ---
  async searchPoi(keyword: string) {
    let httpRequest = http.createHttp();
    const amapKey = 'd4552bc3e20af2857f9cfd5ac95ded1d';
    let query = keyword ? keyword : '地标';
    try {
      this.isSearching = true;
      let url = `https://restapi.amap.com/v3/place/text?keywords=${encodeURIComponent(query)}&city=${encodeURIComponent(this.currentCity)}&offset=20&page=1&key=${amapKey}`;
      let response = await httpRequest.request(url);
      if (response.responseCode === 200) {
        let res = JSON.parse(response.result as string) as AmapResponse;
        if (res.status === '1' && res.pois) {
          this.searchResults = res.pois;
        }
      }
    } catch (err) {
      console.error('POI_Search_Error: ' + JSON.stringify(err));
    } finally {
      this.isSearching = false;
      httpRequest.destroy();
    }
  }

  // --- 【修复点】重命名为 myDragPreview，避开系统属性名冲突 ---
  @Builder myDragPreview(uri: string | Resource) {
    Image(uri)
      .width(100)
      .height(100)
      .borderRadius(8)
      .objectFit(ImageFit.Cover)
      .opacity(0.8)
  }

  build() {
    Stack() {
      Column() {
        // 导航栏
        Row() {
          Text('取消').fontSize(16).fontColor('#333').onClick(() => router.back())
          Blank()
          Button('发布')
            .width(70).height(32).borderRadius(16)
            .backgroundColor(this.postText.length > 0 || this.selectedImages.length > 0 ? '#007DFF' : '#F5F5F5')
            .fontColor(this.postText.length > 0 || this.selectedImages.length > 0 ? '#FFFFFF' : '#BBBBBB')
            .enabled(this.postText.length > 0 || this.selectedImages.length > 0)
            .onClick(() => {
              const finalLoc = (this.selectedLocation === '选择位置' || this.selectedLocation === '')
                ? this.currentCity : `${this.currentCity} · ${this.selectedLocation}`;
              const autoTags = this.extractHashTags(this.postText);
              const combinedTags = Array.from(new Set([...this.selectedTags, ...autoTags]));

              const newPost: PostItem = {
                id: Date.now().toString(),
                userName: '探险家_1',
                avatar: $r('app.media.ic_mine_active'),
                text: this.postText,
                location: finalLoc,
                timestamp: Date.now(),
                images: this.selectedImages.length > 0 ? this.selectedImages : [$r('app.media.map_china_tech')],
                isLiked: false,
                likeCount: 0,
                isCollected: false,
                comments: [],
                tags: combinedTags
              };

              let posts = AppStorage.Get<PostItem[]>('globalPostList') || [];
              posts.unshift(newPost);
              AppStorage.SetOrCreate('globalPostList', posts);
              this.mainIndex = 1;
              router.back();
            })
        }
        .width('100%').padding({ left: 20, right: 20, top: 15, bottom: 15 })

        Scroll() {
          Column() {
            TextArea({ placeholder: '分享你点亮的领域和探索足迹...', text: this.postText })
              .width('100%').height(160).backgroundColor(Color.Transparent)
              .fontSize(16).onChange((v) => this.postText = v)

            // --- 【核心修改：Grid 拖拽排序区域】 ---
            Grid() {
              ForEach(this.selectedImages, (uri: string, index: number) => {
                GridItem() {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    Image(uri)
                      .width('100%').height(100).borderRadius(8).objectFit(ImageFit.Cover)

                    if (index === 0) {
                      Text('封面')
                        .fontSize(10).fontColor(Color.White)
                        .backgroundColor('#007DFF').padding({ left: 4, right: 4 })
                        .borderRadius({ topRight: 8, bottomLeft: 8 })
                    }

                    // 删除按钮
                    SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
                      .fontSize(20).fontColor(['#CC000000'])
                      .onClick(() => {
                        this.selectedImages.splice(index, 1);
                        // 触发 UI 刷新
                        this.selectedImages = [...this.selectedImages];
                      })
                  }
                  .width(100).height(100)
                }
              }, (uri: string, index: number) => uri + index) // 【修复关键】加入 index 确保排序位移后 UI 刷新
              // 添加按钮
              if (this.selectedImages.length < 9) {
                GridItem() {
                  this.AddImageBtn()
                }
              }
            }
            .columnsTemplate('1fr 1fr 1fr')
            .columnsGap(10)
            .rowsGap(10)
            .width('100%')
            .margin({ top: 10 })
            .height(Math.ceil((this.selectedImages.length + 1) / 3) * 110) // 动态计算高度
            .editMode(true) // 必须开启
            .onItemDragStart((event: ItemDragInfo, itemIndex: number) => {
              if (itemIndex >= this.selectedImages.length) return null; // “+”号不可拖拽
              // 【同步修改调用名】
              return this.myDragPreview(this.selectedImages[itemIndex]);
            })
            .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
              // 交换逻辑
              if (!isSuccess || insertIndex >= this.selectedImages.length || itemIndex >= this.selectedImages.length) return;
              let temp = this.selectedImages[itemIndex];
              this.selectedImages.splice(itemIndex, 1);
              this.selectedImages.splice(insertIndex, 0, temp);
              this.selectedImages = [...this.selectedImages]; // 强制刷新 State
            })

            // 菜单列表
            List() {
              ListItem() {
                this.MenuRow(
                  $r('sys.symbol.mappin_and_rectangle'),
                  '所在位置',
                  (!this.selectedLocation || this.selectedLocation === '选择位置')
                    ? this.currentCity : `${this.currentCity} · ${this.selectedLocation}`,
                  true
                )
              }.onClick(() => {
                this.showLocationSearch = true;
                this.searchPoi('');
              })

              ListItem() { this.MenuRow($r('sys.symbol.person_crop_circle_fill'), '提醒谁看', '未选择', true) }

              ListItem() {
                Column() {
                  this.MenuRow($r('sys.symbol.label'), '添加标签', '', false)
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.tags, (tag: string) => {
                      Text(`#${tag}`)
                        .fontSize(12).padding({ left: 10, right: 10, top: 5, bottom: 5 }).margin({ right: 8, bottom: 8 })
                        .backgroundColor(this.selectedTags.includes(tag) ? '#E6F2FF' : '#F5F5F5')
                        .fontColor(this.selectedTags.includes(tag) ? '#007DFF' : '#666666')
                        .borderRadius(12)
                        .onClick(() => {
                          if (this.selectedTags.includes(tag)) {
                            this.selectedTags = this.selectedTags.filter(t => t !== tag)
                          } else {
                            this.selectedTags.push(tag)
                          }
                        })
                    })
                  }.margin({ top: 5, left: 35 })
                }.padding({ bottom: 15 })
              }
              ListItem() { this.MenuRow($r('sys.symbol.lock_fill'), '谁可以看', '公开', true) }
            }
            .width('100%').divider({ strokeWidth: 1, color: '#F1F3F5', startMargin: 35 })
          }
          .padding(20)
        }.layoutWeight(1)
      }
      .width('100%').height('100%').backgroundColor('#FFFFFF')

      // 地点搜索半屏弹窗 (完整逻辑)
      if (this.showLocationSearch) {
        Column() {
          Row() {
            Text('选择位置').fontSize(18).fontWeight(FontWeight.Bold)
            Blank()
            Text('取消').fontColor('#007DFF').onClick(() => this.showLocationSearch = false)
          }.width('100%').padding(20)

          Search({ placeholder: `搜索${this.currentCity}地点...`, value: this.searchKey })
            .width('92%').margin({ bottom: 10 })
            .onChange(v => {
              this.searchKey = v;
              this.searchPoi(v);
            })

          List() {
            if (this.isSearching) {
              ListItem() { Text('正在搜索附近地点...').width('100%').textAlign(TextAlign.Center).padding(20).fontColor('#999') }
            }
            ListItem() {
              Text('不显示位置').fontColor('#007DFF').fontSize(16).padding(15)
            }.onClick(() => {
              this.selectedLocation = '';
              this.showLocationSearch = false;
            })
            ForEach(this.searchResults, (item: AmapPoi) => {
              ListItem() {
                Column() {
                  Text(item.name).fontSize(16).fontColor('#333')
                  Text(item.address || item.adname).fontSize(12).fontColor('#999').margin({ top: 4 })
                }
                .width('100%').alignItems(HorizontalAlign.Start).padding(15)
              }.onClick(() => {
                this.selectedLocation = item.name;
                this.showLocationSearch = false;
              })
            })
          }
          .layoutWeight(1).width('100%').divider({ strokeWidth: 1, color: '#F1F3F5' })
        }
        .width('100%').height('95%').backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 16, topRight: 16 })
        .transition(TransitionEffect.asymmetric(
          TransitionEffect.move(TransitionEdge.BOTTOM),
          TransitionEffect.move(TransitionEdge.BOTTOM)
        ))
        .shadow({ radius: 20, color: '#1A000000' })
      }
    }
  }

  @Builder MenuRow(icon: Resource, title: string, value: string, showArrow: boolean) {
    Row() {
      SymbolGlyph(icon).fontSize(20).fontColor(['#333333'])
      Text(title).fontSize(16).margin({ left: 15 }).fontColor('#333333')
      Blank()
      Text(value).fontSize(14).fontColor('#999999').margin({ right: 5 })
      if (showArrow) {
        SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(14).fontColor(['#CCCCCC'])
      }
    }.width('100%').padding({ top: 15, bottom: 15 })
  }

  @Builder AddImageBtn() {
    Column() {
      SymbolGlyph($r('sys.symbol.plus')).fontSize(30).fontColor(['#999999'])
      Text('图片/视频').fontSize(12).fontColor('#999999').margin({ top: 5 })
    }
    .width(100).height(100).backgroundColor('#F7F8FA').borderRadius(8).justifyContent(FlexAlign.Center)
    .onClick(() => this.selectImages())
  }
}