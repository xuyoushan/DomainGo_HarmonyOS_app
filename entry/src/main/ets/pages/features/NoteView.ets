import { router } from '@kit.ArkUI'
import preferences from '@ohos.data.preferences'

interface NoteItem {
  id: number
  content: string
  time: string
  tags: string[]
  lastEdit: number
}

@Entry
@Component
struct NoteView {
  /* ---------------- 1. 原封不动的完整 State ---------------- */
  @State notes: NoteItem[] = []
  @State editorVisible: boolean = false
  @State detailNote: NoteItem | null = null

  @State inputText: string = ''
  @State inputTags: string = ''
  @State editingId: number | null = null
  @State keyword: string = ''

  private pref: preferences.Preferences | null = null

  /* ---------------- 2. 新增：全局页面转场动画 (解决瞬移) ---------------- */
  pageTransition() {
    PageTransitionEnter({ duration: 350, curve: Curve.Smooth }).slide(SlideEffect.Right)
    PageTransitionExit({ duration: 350, curve: Curve.Smooth }).slide(SlideEffect.Right)
  }

  /* ---------------- 3. 原封不动的 Lifecycle ---------------- */
  async aboutToAppear() {
    this.pref = await preferences.getPreferences(getContext(this), 'note_store')
    const raw = this.pref.getSync('notes', '[]') as string
    this.notes = JSON.parse(raw)
  }

  /* ---------------- 4. 原封不动的 Utils 逻辑 ---------------- */
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

  /* ---------------- 5. 原封不动的 CRUD 业务 ---------------- */
  private openEditor(note?: NoteItem) {
    this.editorVisible = true
    this.detailNote = null

    if (note) {
      this.editingId = note.id
      this.inputText = note.content
      this.inputTags = note.tags.join(',')
    } else {
      this.editingId = null
      this.inputText = ''
      this.inputTags = ''
    }
  }

  private save() {
    if (!this.inputText.trim()) return

    const tags = this.inputTags.split(',').map(t => t.trim()).filter(t => t)

    if (this.editingId !== null) {
      this.notes = this.notes.map((n: NoteItem) => {
        if (n.id === this.editingId) {
          return {
            id: n.id,
            content: this.inputText,
            time: n.time,
            tags: tags,
            lastEdit: Date.now()
          }
        }
        return n
      })
    } else {
      this.notes = [{
        id: Date.now(),
        content: this.inputText,
        time: this.now(),
        tags,
        lastEdit: Date.now()
      }, ...this.notes]
    }

    this.persist()
    this.editorVisible = false
    this.editingId = null
    this.inputText = ''
    this.inputTags = ''
  }

  private remove(id: number) {
    this.notes = this.notes.filter(n => n.id !== id)
    this.persist()
    this.detailNote = null
  }

  /* ---------------- 6. Build 渲染 ---------------- */
  build() {
    Column() {

      /* ---------- 改进后的 Top Bar (符合你要求的图标左右分布逻辑) ---------- */
      Row() {
        // 返回图标固定在最左侧
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(22)
          .padding({ top: 12, bottom: 12 })
          .onClick(() => {
            if (this.detailNote) {
              this.detailNote = null
            } else if (this.editorVisible) {
              this.editorVisible = false
            } else {
              router.back()
            }
          })

        Text(this.detailNote ? '内容详情' : (this.editorVisible ? '编辑内容' : '随手笔记'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })

        // ✅ 核心：Blank 占位符将两侧内容推开
        Blank()

        // 功能图标固定在最右侧
        if (!this.editorVisible && !this.detailNote) {
          SymbolGlyph($r('sys.symbol.plus_circle_fill'))
            .fontSize(26)
            .fontColor(['#007DFF'])
            .onClick(() => this.openEditor())
        } else if (this.editorVisible) {
          Text('保存')
            .fontColor('#007DFF')
            .fontWeight(FontWeight.Bold)
            .onClick(() => this.save())
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#F5F1E8')

      /* ---------- 原有的 Search 逻辑 (保持不变) ---------- */
      if (!this.detailNote && !this.editorVisible) {
        TextInput({ placeholder: '搜索内容或标签', text: this.keyword })
          .margin({ left: 16, right: 16, bottom: 8 })
          .onChange(v => this.keyword = v)
      }

      /* ---------- 原有的 Editor 逻辑 (增加淡入淡出动画) ---------- */
      if (this.editorVisible) {
        Column() {
          TextArea({ placeholder: '写点什么…', text: this.inputText })
            .height(180)
            .backgroundColor('#FFF')
            .borderRadius(12)
            .onChange(v => this.inputText = v)

          TextInput({ placeholder: '标签（英文逗号分隔）', text: this.inputTags })
            .margin({ top: 8 })
            .onChange(v => this.inputTags = v)

          Row() {
            Text(`字数：${this.wordCount(this.inputText)}`)
              .fontSize(12)
              .fontColor('#999')

            Blank()

            Button('取消')
              .fontSize(14)
              .backgroundColor('#EEE')
              .fontColor('#666')
              .onClick(() => this.editorVisible = false)

            Button('确认保存')
              .fontSize(14)
              .margin({ left: 8 })
              .onClick(() => this.save())
          }
          .margin({ top: 10 })
        }
        .padding(16)
        .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 50 })))
      }

      /* ---------- 改进后的 Detail 逻辑 (加入 Scroll 容器解决不能滑动) ---------- */
      if (this.detailNote) {
        Scroll() { // ✅ 新增 Scroll，确保内容长时可滑动
          Column() {
            Text(this.detailNote.time)
              .fontSize(17)
              .fontColor('#999')
              .width('100%')
              .margin({bottom: 10})

            Text(this.detailNote.content)
              .fontSize(26)
              .fontColor('#333')
              .margin({ top: 10 })
              .textAlign(TextAlign.Start)
              .lineHeight(38) // 增加行高，提升详情阅读感
              .width('100%')

            Row({ space: 8 }) {
              ForEach(
                this.detailNote.tags,
                (t: string, index: number) => {
                  Text(`#${t}`)
                    .fontSize(11)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor('#EDE7DA')
                    .borderRadius(8)
                },
                (_: string, index: number): string => `${index}`
              )
            }
            .margin({ top: 15 })
            .width('100%')

            // 详情页操作区
            Row({ space: 16 }) {
              Text('编辑此笔记')
                .fontColor('#007DFF')
                .onClick(() => this.openEditor(this.detailNote!))

              Text('删除此笔记')
                .fontColor('#FF4D4F')
                .onClick(() => this.remove(this.detailNote!.id))
            }
            .margin({ top: 30 })
            .width('100%')
            .justifyContent(FlexAlign.End)
          }
          .padding(16)
          .justifyContent(FlexAlign.Start) // ✅ 确保内容从顶部开始排列
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.9, y: 0.9 })))
      }

      /* ---------- 改进后的 List 逻辑 (支持即时搜索 + 权重排序) ---------- */
      if (!this.editorVisible && !this.detailNote) {
        List({ space: 12 }) {
          ForEach(
            this.notes
              .filter(n => n.content.includes(this.keyword) || n.tags.join(',').includes(this.keyword))
              .sort((a, b) => {
                // ✅ 排序逻辑：
                // 1. 检查标签是否包含关键字
                const aTagMatch = a.tags.join(',').includes(this.keyword) && this.keyword !== '' ? 1 : 0
                const bTagMatch = b.tags.join(',').includes(this.keyword) && this.keyword !== '' ? 1 : 0

                if (aTagMatch !== bTagMatch) {
                  return bTagMatch - aTagMatch // 标签匹配优先
                }
                return b.id - a.id // 否则按时间倒序（ID即时间戳）
              }),
            (item: NoteItem) => {
              ListItem() {
                Column() {
                  Text(item.time)
                    .fontSize(17)
                    .fontColor('#999')

                  Text(item.content)
                    .fontSize(15)
                    .margin({ top: 6 })
                    .maxLines(3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .textAlign(TextAlign.Start)

                  // 搜索时直观展示匹配的标签（可选）
                  if (this.keyword && item.tags.length > 0) {
                    Row({ space: 4 }) {
                      ForEach(item.tags, (tag: string) => {
                        Text(tag).fontSize(10).fontColor('#007DFF')
                      })
                    }.margin({ top: 4 })
                  }
                }
                .padding(16)
                .width('100%')
                .backgroundColor('#FFF')
                .borderRadius(14)
                .onClick(() => {
                  animateTo({ duration: 300 }, () => {
                    this.detailNote = item
                  })
                })
              }
            },
            // ✅ 关键修复：Key 加上 keyword 后缀，强制在输入时刷新 List 索引
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
    .backgroundColor('#F5F1E8')
  }
}