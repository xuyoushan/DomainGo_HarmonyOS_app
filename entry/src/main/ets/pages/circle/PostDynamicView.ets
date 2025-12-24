import router from '@ohos.router';
import http from '@ohos.net.http';
import { PostItem } from '../../models/PostItem';
// 1. 修正导入路径
import { PROVINCE_CITY_DATA } from '../explore/CityData';

// 接口定义
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
  // 基础内容状态
  @State postText: string = '';
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @State selectedLocation: string = '选择位置';

  // 【核心修复1】必须与 Index.ets 中的变量名保持一致
  // 请确保 Index.ets 里也是 @StorageLink('mainIndex') currentIndex: number = 0;
  @StorageLink('mainIndex') mainIndex: number = 0;

  // 社交功能状态
  @State tags: string[] = ['旅行', '美食', '探店', '打卡'];
  @State selectedTags: string[] = [];

  // 搜索逻辑相关状态
  @State showLocationSearch: boolean = false;
  @State searchKey: string = '';
  @State searchResults: AmapPoi[] = [];
  @State isSearching: boolean = false;

  // --- 高德地图 POI 搜索接口实现 ---
  async searchPoi(keyword: string) {
    let httpRequest = http.createHttp();
    const amapKey = 'd4552bc3e20af2857f9cfd5ac95ded1d';
    let query = keyword ? keyword : '地标';

    try {
      let url = `https://restapi.amap.com/v3/place/text?keywords=${encodeURIComponent(query)}&city=${encodeURIComponent(this.currentCity)}&offset=20&page=1&key=${amapKey}`;
      this.isSearching = true;
      let response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 5000
      });

      if (response.responseCode === 200) {
        let res = JSON.parse(response.result as string) as AmapResponse;
        if (res.status === '1' && res.pois) {
          this.searchResults = res.pois;
        }
      }
    } catch (err) {
      console.error('PostPage_Search_Error: ' + JSON.stringify(err));
    } finally {
      this.isSearching = false;
      httpRequest.destroy();
    }
  }

  build() {
    Stack() {
      Column() {
        // 1. 顶部操作栏
        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor('#333')
            .onClick(() => router.back())
          Blank()
          Button('发布')
            .width(70).height(32).borderRadius(16)
            .backgroundColor(this.postText.length > 0 ? '#007DFF' : '#F5F5F5')
            .fontColor(this.postText.length > 0 ? '#FFFFFF' : '#BBBBBB')
            .enabled(this.postText.length > 0)
            .onClick(() => {
              // 拼接逻辑：最终存入数据库的内容
              const finalLoc = (this.selectedLocation === '选择位置' || this.selectedLocation === '所在位置')
                ? this.currentCity
                : `${this.currentCity} · ${this.selectedLocation}`;

              const newPost: PostItem = {
                id: Date.now().toString(),
                userName: '探险家_1',
                avatar: $r('app.media.ic_mine_active'),
                text: this.postText,
                location: finalLoc,
                timestamp: Date.now(),
                images: [$r('app.media.map_china_tech')],
                isLiked: false,
                likeCount: 0,
                isCollected: false,
                comments: []
              };

              // 获取并更新全局列表
              let posts = AppStorage.Get<PostItem[]>('globalPostList') || [];
              posts.unshift(newPost);
              AppStorage.SetOrCreate('globalPostList', posts);

              // 【核心修复2】强制切换 Tab 到“圈子”(Index 1)
              this.mainIndex = 1;

              router.back();
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })

        Scroll() {
          Column() {
            // 2. 文本输入区
            TextArea({ placeholder: '分享你点亮的领域和探索足迹...', text: this.postText })
              .width('100%').height(160).backgroundColor(Color.Transparent)
              .fontSize(16).onChange((v) => this.postText = v)

            // 3. 图片添加占位
            Flex({ wrap: FlexWrap.Wrap }) {
              this.AddImageBtn()
            }.width('100%').margin({ top: 10 })

            // 4. 功能列表
            List() {
              ListItem() {
                this.MenuRow(
                  $r('sys.symbol.mappin_and_rectangle'),
                  '所在位置',
                  // (this.selectedLocation === '选择位置' || this.selectedLocation === '所在位置')
                  this.selectedLocation//本次修改地方
                    ? this.currentCity
                    : `${this.currentCity} · ${this.selectedLocation}`,
                  true
                )
              }.onClick(() => {
                this.showLocationSearch = true;
                this.searchPoi('');
              })

              ListItem() {
                this.MenuRow($r('sys.symbol.person_crop_circle_fill'), '提醒谁看', '未选择', true)
              }

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

              ListItem() {
                this.MenuRow($r('sys.symbol.lock_fill'), '谁可以看', '公开', true)
              }
            }
            .width('100%').divider({ strokeWidth: 1, color: '#F1F3F5', startMargin: 35 })
          }
          .padding(20)
        }.layoutWeight(1)
      }
      .width('100%').height('100%').backgroundColor('#FFFFFF')

      // 5. 地点搜索半屏弹窗
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
              // this.selectedLocation = '所在位置';
              this.selectedLocation = '';//本次修改地方
              // this.selectedLocation = item.name;
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
        .transition(TransitionEffect.move(TransitionEdge.BOTTOM))
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
  }
}