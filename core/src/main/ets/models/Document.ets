export enum DocType {
  TXT = 'TXT',
  PDF = 'PDF',
  EPUB = 'EPUB',
  MOBI = 'MOBI',
  AZW3 = 'AZW3'
}

export interface IDocumentParser {
  type: DocType;
  load(path: string): Promise<void>;
  getTitle(): string;
  getToc(): Array<string>; // 获取目录
  getContent(chapterIndex: number): Promise<string>; // 获取正文
}