import { router } from '@kit.ArkUI';
import { FileManager } from 'core';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct ReaderPage {
  private context = getContext(this) as common.UIAbilityContext;
  private scroller: Scroller = new Scroller();

  @State content: string = '正在加载内容...';
  @State title: string = '';
  @State fontSize: number = 18;

  private filePath: string = '';
  private bookId: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      this.filePath = params['path'] || '';
      this.title = params['title'] || '阅读中';
      this.bookId = params['id'] || '';
      this.loadData();
    }
  }

  async loadData() {
    if (this.filePath) {
      this.content = await FileManager.readTextFile(this.filePath);
      // 强制转化为数字类型
      const lastPos: number = await FileManager.getProgress(this.context, this.bookId);

      // 修复：使用兼容性最好的 scrollTo 写法
      setTimeout(() => {
        this.scroller.scrollTo({
          xOffset: 0,
          yOffset: lastPos
        });
      }, 200);
    }
  }

  onBackPress() {
    // 获取当前偏移量并保存
    const currentOffset = this.scroller.currentOffset();
    const currentPos = currentOffset.yOffset;
    FileManager.saveProgress(this.context, this.bookId, currentPos);
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('🏠').fontSize(22).onClick(() => router.back())
        Text(this.title).fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).margin({left:15}).maxLines(1)
        Text('A-').fontSize(16).margin({right:15}).onClick(() => { this.fontSize -= 2 })
        Text('A+').fontSize(16).onClick(() => { this.fontSize += 2 })
      }
      .width('100%').padding(16).backgroundColor('#FFFFFF')

      // 文本滚动区
      Scroll(this.scroller) {
        Text(this.content)
          .fontSize(this.fontSize)
          .lineHeight(this.fontSize * 1.6)
          .padding(20)
      }
      .layoutWeight(1)
      .backgroundColor('#F4F4F4')
      .edgeEffect(EdgeEffect.Spring) // 增加回弹效果，更有阅读质感
    }
    .width('100%').height('100%')
  }
}