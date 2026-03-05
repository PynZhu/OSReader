import { BookInfo, FileManager } from 'core';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  private context = getContext(this) as common.UIAbilityContext;

  @State shelfList: Array<BookInfo> = [
    {
      id: '1',
      title: "鸿蒙开发实战",
      author: "PynZhu",
      cover: "",
      path: "",
      format: 'PDF',
      lastChapter: "第10章"
    },
    {
      id: '2',
      title: "公考申论技巧",
      author: "考公搭档",
      cover: "",
      path: "",
      format: 'TXT',
      lastChapter: "终章"
    }
  ];

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        // --- 标题栏 ---
        Row() {
          Text('OSReader 书架')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')

          Blank()

          // 【修改点】用 Emoji 字符代替系统图标，防止找不到资源
          Text('🔍')
            .fontSize(22)
            .onClick(() => {
              promptAction.showToast({ message: '搜索功能开发中' })
            })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 24, bottom: 12 })

        // --- 书架网格 ---
        if (this.shelfList.length > 0) {
          Grid() {
            ForEach(this.shelfList, (book: BookInfo) => {
              GridItem() {
                this.BookItemBuilder(book)
              }
            }, (item: BookInfo) => item.id)
          }
          .columnsTemplate('1fr 1fr 1fr')
          .columnsGap(16)
          .rowsGap(24)
          .padding({ left: 16, right: 16, top: 10, bottom: 100 })
          .layoutWeight(1)
        } else {
          Column() {
            // 【修改点】用 Emoji 字符代替系统图标
            Text('📚')
              .fontSize(60)
            Text('书架空空如也').margin({ top: 12 }).fontColor('#999999')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')

      // --- 悬浮导入按钮 ---
      Button({ type: ButtonType.Circle }) {
        // 【修改点】用简单的 "+" 文本代替图标
        Text('+')
          .fontSize(35)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width(60)
      .height(60)
      .backgroundColor('#007DFF')
      .shadow({ radius: 15, color: '#30007DFF', offsetX: 0, offsetY: 8 })
      .margin({ right: 24, bottom: 40 })
      .onClick(async () => {
        await this.handleImport();
      })
    }
    .width('100%')
    .height('100%')
  }

  private async handleImport() {
    try {
      const savedPath = await FileManager.importBook(this.context);
      if (savedPath) {
        const fileName = savedPath.split('/').pop() || "未知书籍";
        const ext = fileName.split('.').pop()?.toUpperCase() || "TXT";

        const newBook: BookInfo = {
          id: Date.now().toString(),
          title: fileName.replace(`.${ext.toLowerCase()}`, ''),
          author: "本地导入",
          path: savedPath,
          format: ext,
          cover: "",
          lastChapter: "尚未阅读"
        };

        this.shelfList.push(newBook);
        promptAction.showToast({ message: `导入成功: ${fileName}` });
      }
    } catch (err) {
      promptAction.showToast({ message: "操作取消" });
    }
  }

  @Builder
  BookItemBuilder(book: BookInfo) {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Rect()
          .width('100%')
          .aspectRatio(0.7)
          .fill(this.getFormatColor(book.format))
          .borderRadius(10)

        Text(book.format)
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 40 })
      }
      .shadow({ radius: 8, color: '#15000000', offsetY: 4 })

      Text(book.title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 10 })
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(book.author)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Start)
  }

  private getFormatColor(format: string): string {
    if (format === 'PDF') return '#E91E63';
    if (format === 'EPUB') return '#2196F3';
    if (format === 'TXT') return '#4CAF50';
    if (format === 'MOBI') return '#FF9800';
    return '#9E9E9E';
  }
}