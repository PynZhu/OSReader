import { picker } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

export class FileManager {
  /**
   * 导入书籍：调起系统文件选择器并拷贝到沙盒
   */
  static async importBook(context: common.Context): Promise<string | null> {
    try {
      // 1. 配置选择器：过滤常见的电子书后缀
      const documentPicker = new picker.DocumentViewPicker(context);
      const options = new picker.DocumentSelectOptions();
      options.fileSuffixFilters = ['.txt', '.pdf', '.epub', '.mobi', '.azw3'];
      options.maxSelectNumber = 1;

      // 2. 唤起选择器
      const uris = await documentPicker.select(options);
      if (!uris || uris.length === 0) return null;

      const sourceUri = uris[0];
      // 获取文件名
      const fileInfo = await fs.open(sourceUri, fs.OpenMode.READ_ONLY);
      const fileName = fileInfo.name || `book_${Date.now()}`;

      // 3. 拷贝到应用沙盒 (filesDir)
      // 为什么要拷贝？因为 Picker 返回的 URI 在应用重启后可能会失效，拷贝到沙盒才能永久保存。
      const destPath = `${context.filesDir}/${Date.now()}_${fileName}`;
      const destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);

      // 执行流式拷贝
      await fs.copyFile(fileInfo.fd, destFile.fd);

      // 关闭文件句柄
      fs.closeSync(fileInfo);
      fs.closeSync(destFile);

      return destPath; // 返回存放在沙盒里的最终路径
    } catch (err) {
      console.error('Import failed:', JSON.stringify(err));
      return null;
    }
  }
}