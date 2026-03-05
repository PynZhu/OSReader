import { BookInfo, FileManager } from 'core';
import { common } from '@kit.AbilityKit';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  // 获取 UIAbility 上下文，用于文件操作和首选项访问
  private context = getContext(this) as common.UIAbilityContext;

  // 书架列表数据状态
  @State shelfList: Array<BookInfo> = [
    {
      id: 'default_1',
      title: "公考申论真题集",
      author: "PynZhu",
      path: "",
      format: 'TXT',
      cover: "",
      lastChapter: "第1页"
    }
  ];

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        // --- 1. 自定义导航栏 ---
        Row() {
          Text('OSReader 书架')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')

          Blank()

          // 搜索图标 (Emoji 代替资源文件，防止报错)
          Text('🔍')
            .fontSize(22)
            .margin({ right: 4 })
            .onClick(() => {
              promptAction.showToast({ message: '搜索功能正在开发中...' });
            })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 24, bottom: 12 })

        // --- 2. 书架内容区 ---
        if (this.shelfList.length > 0) {
          Grid() {
            ForEach(this.shelfList, (book: BookInfo) => {
              GridItem() {
                this.BookItemBuilder(book)
              }
              .onClick(() => {
                // 跳转到阅读页面，并传递关键参数
                router.pushUrl({
                  url: 'pages/ReaderPage',
                  params: {
                    path: book.path,
                    title: book.title,
                    id: book.id  // 必须传递 id，用于阅读进度匹配
                  }
                });
              })
            }, (item: BookInfo) => item.id)
          }
          .columnsTemplate('1fr 1fr 1fr') // 三列布局
          .columnsGap(16)
          .rowsGap(24)
          .padding({ left: 16, right: 16, top: 10, bottom: 100 })
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        } else {
          // 空状态展示
          Column() {
            Text('📚').fontSize(60)
            Text('书架空空如也，点击下方按钮导入').margin({ top: 12 }).fontColor('#999999')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')

      // --- 3. 悬浮导入按钮 ---
      Button({ type: ButtonType.Circle }) {
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

  /**
   * 处理书籍导入逻辑
   */
  private async handleImport() {
    try {
      const savedPath = await FileManager.importBook(this.context);
      if (savedPath) {
        const fileName = savedPath.split('/').pop() || "未知书籍";
        const fileExt = fileName.split('.').pop()?.toUpperCase() || "TXT";

        // 创建新的书籍对象
        const newBook: BookInfo = {
          id: Date.now().toString(), // 使用时间戳作为唯一ID
          title: fileName.split('_').slice(1).join('_') || fileName, // 去掉时间戳前缀显示
          author: "本地导入",
          path: savedPath,
          format: fileExt,
          cover: "",
          lastChapter: "尚未阅读"
        };

        this.shelfList.push(newBook);
        promptAction.showToast({ message: `成功加入书架` });
      }
    } catch (err) {
      promptAction.showToast({ message: "导入已取消" });
    }
  }

  /**
   * 书籍卡片 UI 构建器
   */
  @Builder
  BookItemBuilder(book: BookInfo) {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        // 书籍封面占位矩形
        Rect()
          .width('100%')
          .aspectRatio(0.7)
          .fill(this.getFormatColor(book.format))
          .borderRadius(10)

        // 封面上的格式标识
        Text(book.format)
          .fontSize(14)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 10 })
      }
      .shadow({ radius: 8, color: '#15000000', offsetY: 4 })

      // 书名
      Text(book.title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 10 })
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor('#182431')
    }
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 根据文件格式返回不同的封面颜色
   */
  private getFormatColor(format: string): string {
    switch (format) {
      case 'PDF': return '#E91E63';
      case 'EPUB': return '#2196F3';
      case 'TXT': return '#4CAF50';
      case 'MOBI': return '#FF9800';
      default: return '#9E9E9E';
    }
  }
}