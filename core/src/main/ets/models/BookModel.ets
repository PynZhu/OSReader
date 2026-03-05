export interface BookInfo {
  id: string;
  title: string;
  author: string;
  path: string;       // 文件存储路径
  format: string;     // 格式：PDF, TXT, EPUB 等
  cover: string;
  lastChapter: string;
}

export interface BookSource {
  id: string;
  name: string;
  url: string;
}