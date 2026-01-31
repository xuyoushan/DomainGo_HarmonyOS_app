import { http } from '@kit.NetworkKit'
import { AmapSpotService, ScenicSpot } from '../../../services/AmapSpotService'
import { router, promptAction } from '@kit.ArkUI'

interface AIMessage { content: string; role: string; }
interface AIChoice { message: AIMessage; }
interface AIResponse { choices: AIChoice[] }

interface AIChatItem { role: 'user' | 'assistant', content: string }

interface ScenicUIItem {
  id: string
  name: string
  cover: string
  rating: number
  heatLevel?: 'low' | 'mid' | 'high'
  tags: string[]
  price?: string
  bookable?: boolean
  isAClass?: boolean
  address: string
  opacity: number
  translateY: number
}

@Entry
@Component
struct ScenicRecommendView {
  @StorageLink('currentCity') cityName: string = '北京市'
  @State currentCategory: string = '全部'
  @State currentSort: string = '热门'
  @State searchKeyword: string = ''
  @State categories: string[] = ['全部', '人文', '自然', '一日路线']
  @State scenicList: ScenicUIItem[] = []
  @State bgBaseColor: string = '#F6F7F9'
  @State locationTips: string = '正在为您寻觅城中的诗意...'
  @State aiChats: AIChatItem[] = []
  @State showAI: boolean = false
  @State aiQuery: string = ''
  @State aiLoading: boolean = false
  @State routeSpots: ScenicUIItem[] = [];
  @State filteredList: ScenicUIItem[] = [];

  private static lastYOffset: number = 0
  private scroller: Scroller = new Scroller()
  private aiScroller: Scroller = new Scroller();
  private lastCityLoaded: string = '';
  private readonly timeMap: string[] = ['上午', '下午', '傍晚', '夜游'];

  private aiTimer: number = -1;
  private searchTimer: number = -1;

  private getSortedScenicList(): ScenicUIItem[] {
    return this.scenicList
      .filter(item => {
        if (this.searchKeyword) {
          const kw = this.searchKeyword.trim();
          const matchName = item.name.includes(kw);
          const matchTags = item.tags.some(tag => tag.includes(kw));
          const matchAddress = item.address.includes(kw);
          if (!matchName && !matchTags && !matchAddress) {
            return false;
          }
        }
        if (this.currentCategory === '全部') return true;
        if (this.currentCategory === '人文') return item.tags.includes('人文');
        if (this.currentCategory === '自然') {
          const natureKeywords = ['公园', '山', '湖', '水', '林', '岛', '自然', '郊野', '滩'];
          const hasNatureTag = item.tags.includes('自然') || item.tags.includes('风景区');
          const hasNatureName = natureKeywords.some(key => item.name.includes(key));
          return hasNatureTag || hasNatureName;
        }
        return true;
      })
      .sort((a, b) => this.calcHeat(b) - this.calcHeat(a));
  }

  private async askAI(query: string) {
    if (!query.trim() || this.aiLoading) return;

    this.aiChats.push({ role: 'user', content: query });
    this.scrollAIToBottom();
    this.aiQuery = '';
    this.aiLoading = true;
    this.showAI = true;
    this.trimChats();

    const token = '82e4d46a05264dd19a27e1d91b30dce6.UNpMhFWNznhFSPLo';
    let httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request('https://open.bigmodel.cn/api/paas/v4/chat/completions', {
        method: http.RequestMethod.POST,
        header: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' },
        extraData: {
          model: 'glm-4-flash',
          messages: [
            { role: 'system', content: '你是一位精通中国文旅的智者，请用文雅且富有诗意的语言回答，严格控制在200字以内。' },
            ...this.aiChats
          ]
        }
      });
      const res = JSON.parse(response.result as string) as AIResponse;
      let content = res.choices[0].message.content;
      if (content.length > 200) {
        content = content.slice(0, 200) + '...';
      }
      this.aiChats.push({ role: 'assistant', content });
    } catch (e) {
      this.aiChats.push({ role: 'assistant', content: '灵犀中断，请稍后再试。' });
    }
    this.aiLoading = false;
    this.scrollAIToBottom();
  }

  private calcHeat(item: ScenicUIItem): number {
    let score = 0;
    if (item.tags.includes('5A景区')) score += 50;
    else if (item.tags.includes('4A景区')) score += 35;
    else if (item.tags.includes('3A景区')) score += 20;
    score += item.rating * 6;
    score += item.tags.length * 2;
    if (!item.price) score += 6;
    if (item.name.length <= 4) score -= 5;
    return score;
  }

  private pickRouteSpots(): ScenicUIItem[] {
    const list = [...this.scenicList];
    return list
      .sort((a, b) => this.calcHeat(b) - this.calcHeat(a))
      .slice(0, 5);
  }

  private generateLocalRoute() {
    if (this.scenicList.length === 0) {
      promptAction.showToast({ message: '请等待美景数据加载...' });
      return;
    }

    const pool = [...this.scenicList]
      .filter(s => s.rating >= 4)
      .sort((a, b) => this.calcHeat(b) - this.calcHeat(a));

    if (pool.length < 3) return; // 兜底防止点位不足

    const morning = pool.find(s => s.tags.includes('人文')) || pool[0];
    const afternoon = pool.find(s => s.tags.includes('5A景区')) || pool[1];
    const evening = pool.find(s => s.tags.includes('自然')) || pool[2];
    const backup = pool[3];

    this.routeSpots = [morning, afternoon, evening, backup].filter(Boolean);
  }


  private async generateOneDayRoute() {
    if (this.scenicList.length === 0) return;

    const spots = this.pickRouteSpots();
    const names = spots.map(s => s.name).join('、');
    const prompt = `请基于以下景点生成【紧凑且可执行的一日游路线】：\n${names}\n要求：\n- 控制在200字\n- 必须包含 上午 / 下午 / 傍晚\n- 不要写废话\n- 偏实用，不要散文`;
    this.askAI(prompt);
  }

  private getThemeColor(category: string): string {
    const colorMap: Record<string, string> = {
      '全部': '#F6F7F9', '人文': '#FCF6ED', '自然': '#F0F9F4','一日路线': '#EEF7FF'
    }
    return colorMap[category] || '#F6F7F9'
  }

  private scrollAIToBottom() {
    clearTimeout(this.aiTimer);
    this.aiTimer = setTimeout(() => {
      this.aiScroller.scrollEdge(Edge.Bottom);
    }, 120);
  }

  private trimChats() {
    const MAX = 6;
    if (this.aiChats.length > MAX) {
      this.aiChats.splice(0, this.aiChats.length - MAX);
    }
  }

  private async loadSpots() {
    try {
      if (this.lastCityLoaded === this.cityName && this.scenicList.length > 0) {
        return;
      }
      this.lastCityLoaded = this.cityName;
      const spots = await AmapSpotService.fetchSpots(this.cityName);
      const mapped = spots.map((s: ScenicSpot): ScenicUIItem => {
        const tags = [...s.tags];
        if (!s.price || s.price === '0') {
          tags.push('免费');
        }
        return {
          id: s.id,
          name: s.name,
          cover: s.image,
          rating: parseFloat(s.rating || '0'),
          tags,
          price: (s.price === '0' || !s.price) ? undefined : s.price,
          address: s.address,
          opacity: 0,
          translateY: 40
        };
      });

      this.scenicList = mapped;
      this.filteredList = this.getSortedScenicList();
      this.playEnterAnimation();
    } catch (e) {
      promptAction.showToast({ message: '景点加载失败，请检查网络' });
    }
  }

  private playEnterAnimation() {
    const listCount = this.scenicList.length;
    this.scenicList.forEach((_, index) => {
      animateTo(
        { duration: 600, delay: index * 100, curve: Curve.EaseOut },
        () => {
          if (index < listCount && this.scenicList[index]) {
            this.scenicList[index].opacity = 1;
            this.scenicList[index].translateY = 0;
          }
        }
      );
    });
  }

  async aboutToAppear() {
    await this.loadSpots();
  }

  async onPageShow() {
    await this.loadSpots();
  }

  onPageHide() {
    ScenicRecommendView.lastYOffset = this.scroller.currentOffset().yOffset;
  }

  aboutToDisappear() {
    clearTimeout(this.aiTimer);
    clearTimeout(this.searchTimer);
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        this.TopBar()
        Search({ placeholder: '搜索城中胜景、地标...', value: this.searchKeyword })
          .margin({ left: 16, right: 16, top: 8, bottom: 8 })
          .height(44)
          .onChange(v => {
            clearTimeout(this.searchTimer);
            this.searchTimer = setTimeout(() => {
              this.searchKeyword = v;
              this.filteredList = this.getSortedScenicList();
            }, 300);
          })

        this.CategoryBar()

        Scroll(this.scroller) {
          Column({ space: 25 }) {
            if (this.getSortedScenicList().length === 0 && this.currentCategory !== '一日路线') {
              Column({ space: 10 }) {
                Image($r('app.media.ic_ai_chat')).width(100).opacity(0.3)
                Text('未找到相关胜景').fontColor('#999').fontSize(14)
              }.width('100%').margin({ top: 100 })
            }

            if (['全部', '人文', '自然'].includes(this.currentCategory)) {
              this.VenueEntryCard()
            }

            if (this.currentCategory === '一日路线') {
              ForEach(this.routeSpots,
                (item: ScenicUIItem, index: number) => {
                  this.ScenicCard(item, index)
                },
                (item: ScenicUIItem, index: number) => item.id + index
              )
            } else {
              ForEach(this.getSortedScenicList(),
                (item: ScenicUIItem, index: number) => {
                  this.ScenicCard(item, index)
                },
                (item: ScenicUIItem) => item.id+ this.currentCategory
              )
            }
          }
          .padding({ left: 16, right: 16, bottom: 100 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 180,
        colors: [[this.bgBaseColor, 0], ['#FFFFFF', 1.0]]
      })

      Button() { Image($r('app.media.ic_ai_chat')).width(30).height(30) }
      .width(60).height(60).borderRadius(30).backgroundColor('#2C3E50').margin({ right: 20, bottom: 40 })
      .onClick(() => {
        this.showAI = true;
      })

      if (this.showAI) this.AIPanel()
    }
  }

  @Builder TopBar() {
    Row({ space: 12 }) {
      SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).fontColor(['#111'])
        .onClick(() => router.back())
      Column({ space: 2 }) {
        Row({ space: 4 }) {
          Text(this.cityName).fontSize(18).fontWeight(FontWeight.Bold)
          SymbolGlyph($r('sys.symbol.location_north_up_right_and_circle_dotted_fill')).fontSize(14)
        }
        Text(this.locationTips).fontSize(10).fontColor('#7F8C8D').fontStyle(FontStyle.Italic)
      }.alignItems(HorizontalAlign.Start)
      Blank()
      Text(this.currentSort).fontSize(14).fontColor('#666').padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('rgba(0,0,0,0.05)').borderRadius(12)
    }.width('100%').padding(16)
  }

  @Builder CategoryBar() {
    Scroll() {
      Row({ space: 20 }) {
        ForEach(this.categories, (item: string) => {
          Column() {
            Text(item)
              .fontSize(this.currentCategory === item ? 17 : 15)
              .fontWeight(this.currentCategory === item ? FontWeight.Bold : FontWeight.Regular)
              .fontColor(this.currentCategory === item ? '#111' : '#999')
            if (this.currentCategory === item) {
              Rect().width(20).height(3).fill('#2C3E50').margin({ top: 4 }).borderRadius(2)
            }
          }
          .padding({ left: 10, right: 10 })
          .onClick(() => {
            this.scroller.scrollTo({ xOffset: 0, yOffset: 0 });
            if (item === '一日路线') {
              this.generateLocalRoute();
              this.generateOneDayRoute();
              this.currentCategory = item;
              return;
            }
            animateTo({ duration: 400, curve: Curve.Sharp }, () => {
              this.currentCategory = item
              this.bgBaseColor = this.getThemeColor(item)
              this.filteredList = this.getSortedScenicList();
            })
          })
        }, (item: string) => item)
      }.padding({ left: 16, right: 16 })
    }.scrollBar(BarState.Off).margin({ top: 10, bottom: 15 })
  }

  @Builder VenueEntryCard() {
    Row() {
      Column({ space: 6 }) {
        Text('城市场馆预约').fontSize(20).fontWeight(FontWeight.Bolder).fontColor('#FFF')
        Text('让每一次出行都充满人文仪式感').fontSize(12).fontColor('rgba(255,255,255,0.8)')
      }.alignItems(HorizontalAlign.Start)
      Blank()
      SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(18).fontColor(['#FFF'])
    }
    .width('100%').padding(26).borderRadius(32).margin({ bottom: 10 })
    .linearGradient({ angle: 135, colors: [['#667eea', 0], ['#764ba2', 0.5], ['#ff9a9e', 1]] })
    .shadow({ radius: 20, color: 'rgba(118,75,162,0.3)', offsetY: 10 })
    .onClick(() => router.pushUrl({ url: 'pages/features/explore/VenueBookingView' }))
  }

  @Builder ScenicCard(item: ScenicUIItem, index?: number){
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        if (this.currentCategory === '一日路线' && index !== undefined) {
          Text(this.timeMap[index!])
            .fontSize(11)
            .fontColor(Color.White)
            .backgroundColor('#FF7A45')
            .borderRadius(8)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .position({ x: 12, y: 12 })
            .zIndex(2)
        }

        Image(item.cover).width('100%').height(260).borderRadius(24).objectFit(ImageFit.Cover)

        Row() {
          Text('★').fontColor('#FFD700').fontSize(12)
          Text(item.rating.toFixed(1)).fontColor(Color.White).fontSize(14).fontWeight(FontWeight.Bold).margin({ left: 4 })
        }
        .padding({ left: 10, right: 12, top: 6, bottom: 6 })
        .backgroundColor('rgba(0,0,0,0.5)')
        .borderRadius({ topLeft: 24, bottomRight: 18 })
        .position({ x: 0, y: 0 })

        Button('AI 导读')
          .fontSize(12)
          .height(30)
          .backgroundColor('rgba(0,0,0,0.6)')
          .margin({ top: 12, right: 12 })
          .onClick(() => this.askAI(`请详细介绍一下${item.name}的历史渊源和特色景观。`))
      }

      Row() {
        Column({ space: 4 }) {
          Text(item.name).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#2C3E50')
          if (item.tags.includes('免费')) {
            Text('FREE')
              .fontSize(10)
              .fontColor('#00A86B')
              .backgroundColor('#E8FFF3')
              .borderRadius(6)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          }
          Text(item.address).fontSize(12).fontColor('#7F8C8D').maxLines(1)
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)

        Button() {
          Row({ space: 4 }) {
            Text(item.price ? `¥${item.price}起` : '免费预订')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(14).fontColor([Color.White])
          }
        }
        .height(36)
        .padding({ left: 12, right: 12 })
        .linearGradient({ angle: 135, colors: [['#007DFF', 0], ['#005BB7', 1]] })
        .borderRadius(18)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/features/AllFunctions/TravelServiceView',
            params: { defaultType: '门票预订', destination: item.name }
          })
        })
      }.width('100%').padding({ top: 15, bottom: 10 })
    }
    .opacity(item.opacity)
    .translate({ y: item.translateY })
    .margin({ bottom: 10 })
  }

  @Builder AIPanel() {
    Column() {
      Row() {
        Text('寻域百科').fontWeight(FontWeight.Bold).fontColor('#C9A25D').fontSize(18)
        Blank()
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(20)
          .fontColor(['#999'])
          .onClick(() => this.showAI = false)
      }.width('100%').padding(20).border({ width: { bottom: 1 }, color: '#F5F5F5' })

      List({ space: 16, scroller: this.aiScroller }) {
        ForEach(this.aiChats, (chat: AIChatItem) => {
          ListItem() {
            Row() {
              if (chat.role === 'user') Blank()
              Column() {
                Text(chat.content)
                  .padding(12)
                  .borderRadius(12)
                  .backgroundColor(chat.role === 'user' ? '#007DFF' : '#F4F4F4')
                  .fontColor(chat.role === 'user' ? Color.White : '#333')
                  .fontSize(15)
                  .lineHeight(24)
              }.constraintSize({ maxWidth: '80%' })
              if (chat.role === 'assistant') Blank()
            }.width('100%')
          }
        })
        if (this.aiLoading) {
          ListItem() {
            LoadingProgress().width(32).height(32).margin({ left: 20 })
          }
        }
      }
      .layoutWeight(1)
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .width('100%')
      .edgeEffect(EdgeEffect.Spring)

      Row({ space: 10 }) {
        TextInput({ text: this.aiQuery, placeholder: '在此输入您的追问...' })
          .layoutWeight(1)
          .height(42)
          .backgroundColor('#F5F5F5')
          .onChange(v => this.aiQuery = v)
          .onSubmit(() => this.askAI(this.aiQuery))

        Button('发送')
          .height(42)
          .backgroundColor('#C9A25D')
          .fontColor(Color.White)
          .onClick(() => this.askAI(this.aiQuery))
      }
      .padding({ left: 20, right: 20, bottom: 20, top: 10 })
      .width('100%')
    }
    .width('100%')
    .height('60%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 28, topRight: 28 })
    .shadow({ radius: 40, color: 'rgba(0,0,0,0.15)' })
  }
}