import router from '@ohos.router';
import http from '@ohos.net.http';
import { PostItem } from '../../models/PostItem';
import { postRepo } from '../../services/PostRepository';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { promptAction } from '@kit.ArkUI';

interface AmapPoi { name: string;address: string;adname: string; }
interface AmapResponse { status: string;pois: AmapPoi[]; }
interface PostDraft { text: string;images: (string | Resource)[]; }

@Entry
@Component
struct PostDynamicView {
  @State postText: string = '';
  @StorageLink('currentCity') currentCity: string = '定位中...';
  @State selectedLocation: string = '选择位置';
  @StorageLink('mainIndex') mainIndex: number = 0;
  @State selectedImages: (string | Resource)[] = [];
  @State tags: string[] = ['旅行', '美食', '探店', '打卡'];
  @State selectedTags: string[] = [];
  @State showLocationSearch: boolean = false;
  @State searchKey: string = '';
  @State searchResults: AmapPoi[] = [];
  @State isSearching: boolean = false;
  @StorageLink('currentProvince') currentProvince: string = ''; // 引入省份监听

  aboutToAppear() {
    const draft = AppStorage.get<PostDraft>('post_draft_full');
    if (draft) {
      this.postText = draft.text;
      this.selectedImages = draft.images;
    }
  }

  // 拦截系统返回键/手势
  onBackPress() {
    if (this.postText.length > 0 || this.selectedImages.length > 0) {
      promptAction.showDialog({
        title: '是否保存草稿？',
        message: '退出后，已编辑的内容将为您保留。',
        buttons: [
          { text: '不保存', color: '#999999' },
          { text: '保存草稿', color: '#007DFF' }
        ]
      }).then(data => {
        if (data.index === 1) {
          const draft: PostDraft = {
            text: this.postText,
            images: this.selectedImages
          };
          AppStorage.setOrCreate('post_draft_obj', draft);
          promptAction.showToast({ message: '草稿已保存' });
          router.back();
        } else {
          AppStorage.setOrCreate('post_draft_obj', null);
          router.back();
        }
      })
      return true; // 拦截默认返回
    }
    return false; // 内容为空直接返回
  }

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
      // 【关键修改】：增加了 &citylimit=true，确保只在当前城市搜索
      let url = `https://restapi.amap.com/v3/place/text?keywords=${encodeURIComponent(query)}&city=${encodeURIComponent(this.currentCity)}&citylimit=true&offset=20&page=1&key=${amapKey}`;

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
        Row() {
          Text('取消').fontSize(16).fontColor('#333').onClick(() => {
            this.onBackPress() || router.back();
          })
          Blank()
          Button('发布')
            .width(70).height(32).borderRadius(16)
            .backgroundColor(this.postText.length > 0 || this.selectedImages.length > 0 ? '#007DFF' : '#F5F5F5')
            .fontColor(this.postText.length > 0 || this.selectedImages.length > 0 ? '#FFFFFF' : '#BBBBBB')
            .enabled(this.postText.length > 0 || this.selectedImages.length > 0)
            .onClick(async () => {
              const isLoggedIn = AppStorage.get<boolean>('isLoggedIn');
              if (!isLoggedIn) {
                promptAction.showToast({ message: '请先登录后再发布' });
                router.pushUrl({ url: 'pages/mine/RegisterView' });
                return;
              }

              try {
                await postRepo.init(getContext(this));

                const uid = AppStorage.get<string>('currentUserId');
                const uName = AppStorage.get<string>('userName');
                const currentProv = AppStorage.get<string>('currentProvince') || '';

                if (!uid) {
                  promptAction.showToast({ message: '发布失败：账号异常，请重新登录' });
                  return;
                }

                // --- 位置逻辑重构 ---
                let finalLoc = '';
                const isDefaultLoc = (this.selectedLocation === '选择位置' || this.selectedLocation === '');

                if (isDefaultLoc) {
                  // 场景 A：未选位置。优先显示省份，定位中则显示火星
                  if (currentProv && currentProv !== '' && currentProv !== '定位中...' && currentProv !== '未知省份') {
                    finalLoc = currentProv;
                  } else {
                    finalLoc = '未知地区 · 火星';
                  }
                } else {
                  // 场景 B：选了位置。由于搜索已锁定城市，直接：市 · 详细地名
                  const selected = this.selectedLocation;
                  const city = this.currentCity;

                  // 防止出现 “武汉市 · 武汉市”
                  if (selected === city || selected.startsWith(city)) {
                    finalLoc = selected;
                  } else {
                    finalLoc = `${city} · ${selected}`;
                  }
                }

                const autoTags = this.extractHashTags(this.postText);
                const combinedTags = Array.from(new Set([...this.selectedTags, ...autoTags]));

                const newPost: PostItem = {
                  id: Date.now().toString(),
                  userName: uName || '匿名探险家',
                  avatar: $r('app.media.ic_mine_active'),
                  text: this.postText,
                  location: finalLoc,
                  timestamp: Date.now(),
                  images: this.selectedImages.length > 0 ? this.selectedImages : [],
                  isLiked: false,
                  likeCount: 0,
                  isCollected: false,
                  comments: [],
                  tags: combinedTags
                };

                await postRepo.insertPost(newPost, uid);

                let posts = AppStorage.get<PostItem[]>('globalPostList') || [];
                AppStorage.setOrCreate('globalPostList', [newPost, ...posts]);

                // 清空草稿
                AppStorage.setOrCreate('post_draft_obj', null);

                promptAction.showToast({ message: '发布成功' });
                this.mainIndex = 1;

                setTimeout(() => {
                  router.back();
                }, 500);

              } catch (err) {
                promptAction.showToast({ message: `发布失败: ${err.message || '未知错误'}` });
              }
            })
        }
        .width('100%').padding({ left: 20, right: 20, top: 15, bottom: 15 })

        Scroll() {
          Column() {
            TextArea({ placeholder: '分享你点亮的领域和探索足迹...', text: this.postText })
              .width('100%').height(160).backgroundColor(Color.Transparent)
              .fontSize(16).onChange((v) => this.postText = v)

            Grid() {
              ForEach(this.selectedImages, (uri: string, index: number) => {
                GridItem() {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    Image(uri).width('100%').height(100).borderRadius(8).objectFit(ImageFit.Cover)
                    if (index === 0) {
                      Text('封面').fontSize(10).fontColor(Color.White).backgroundColor('#007DFF')
                        .padding({ left: 4, right: 4 }).borderRadius({ topRight: 8, bottomLeft: 8 })
                    }
                    SymbolGlyph($r('sys.symbol.xmark_circle_fill')).fontSize(20).fontColor(['#CC000000'])
                      .onClick(() => {
                        this.selectedImages.splice(index, 1);
                        this.selectedImages = [...this.selectedImages];
                      })
                  }.width(100).height(100)
                }
              }, (uri: string, index: number) => uri + index)

              if (this.selectedImages.length < 9) {
                GridItem() { this.AddImageBtn() }
              }
            }
            .columnsTemplate('1fr 1fr 1fr').columnsGap(10).rowsGap(10).width('100%').margin({ top: 10 })
            .height(Math.ceil((this.selectedImages.length + 1) / 3) * 110).editMode(true)
            .onItemDragStart((event: ItemDragInfo, itemIndex: number) => {
              if (itemIndex >= this.selectedImages.length) return null;
              return this.myDragPreview(this.selectedImages[itemIndex]);
            })
            .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
              if (!isSuccess || insertIndex >= this.selectedImages.length || itemIndex >= this.selectedImages.length) return;
              let temp = this.selectedImages[itemIndex];
              this.selectedImages.splice(itemIndex, 1);
              this.selectedImages.splice(insertIndex, 0, temp);
              this.selectedImages = [...this.selectedImages];
            })

            List() {
              ListItem() {
                this.MenuRow($r('sys.symbol.mappin_and_rectangle'), '所在位置',
                  (!this.selectedLocation || this.selectedLocation === '选择位置')
                    ? this.currentCity : `${this.currentCity} · ${this.selectedLocation}`, true)
              }.onClick(() => { this.showLocationSearch = true; this.searchPoi(''); })
              ListItem() { this.MenuRow($r('sys.symbol.person_crop_circle_fill'), '提醒谁看', '未选择', true) }
              ListItem() {
                Column() {
                  this.MenuRow($r('sys.symbol.label'), '添加标签', '', false)
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.tags, (tag: string) => {
                      Text(`#${tag}`).fontSize(12).padding({ left: 10, right: 10, top: 5, bottom: 5 }).margin({ right: 8, bottom: 8 })
                        .backgroundColor(this.selectedTags.includes(tag) ? '#E6F2FF' : '#F5F5F5')
                        .fontColor(this.selectedTags.includes(tag) ? '#007DFF' : '#666666')
                        .borderRadius(12).onClick(() => {
                        if (this.selectedTags.includes(tag)) { this.selectedTags = this.selectedTags.filter(t => t !== tag) }
                        else { this.selectedTags.push(tag) }
                      })
                    })
                  }.margin({ top: 5, left: 35 })
                }.padding({ bottom: 15 })
              }
              ListItem() { this.MenuRow($r('sys.symbol.lock_fill'), '谁可以看', '公开', true) }
            }.width('100%').divider({ strokeWidth: 1, color: '#F1F3F5', startMargin: 35 })
          }.padding(20)
        }.layoutWeight(1)
      }.width('100%').height('100%').backgroundColor('#FFFFFF')

      if (this.showLocationSearch) {
        Column() {
          Row() {
            Text('选择位置').fontSize(18).fontWeight(FontWeight.Bold)
            Blank()
            Text('取消').fontColor('#007DFF').onClick(() => this.showLocationSearch = false)
          }.width('100%').padding(20)
          Search({ placeholder: `搜索${this.currentCity}地点...`, value: this.searchKey })
            .width('92%').margin({ bottom: 10 }).onChange(v => { this.searchKey = v; this.searchPoi(v); })
          List() {
            if (this.isSearching) {
              ListItem() { Text('正在搜索附近地点...').width('100%').textAlign(TextAlign.Center).padding(20).fontColor('#999') }
            }
            ListItem() { Text('不显示位置').fontColor('#007DFF').fontSize(16).padding(15) }
            .onClick(() => { this.selectedLocation = ''; this.showLocationSearch = false; })
            ForEach(this.searchResults, (item: AmapPoi) => {
              ListItem() {
                Column() {
                  Text(item.name).fontSize(16).fontColor('#333')
                  Text(item.address || item.adname).fontSize(12).fontColor('#999').margin({ top: 4 })
                }.width('100%').alignItems(HorizontalAlign.Start).padding(15)
              }.onClick(() => { this.selectedLocation = item.name;
                if (item.adname) {
                  this.selectedLocation = item.adname + ' · ' + item.name;
              }
                this.showLocationSearch = false; })
            })
          }.layoutWeight(1).width('100%').divider({ strokeWidth: 1, color: '#F1F3F5' })
        }.width('100%').height('95%').backgroundColor('#FFFFFF').borderRadius({ topLeft: 16, topRight: 16 })
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
      if (showArrow) { SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(14).fontColor(['#CCCCCC']) }
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