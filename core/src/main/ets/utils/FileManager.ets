import { picker, fileIo as fs } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';

export class FileManager {
  // 必须显式声明类型
  static readonly PREF_NAME: string = 'ReaderPreferences';

  static async importBook(context: common.Context): Promise<string | null> {
    try {
      const documentPicker = new picker.DocumentViewPicker(context);
      const options = new picker.DocumentSelectOptions();
      options.fileSuffixFilters = ['.txt', '.pdf'];
      const uris = await documentPicker.select(options);
      if (!uris || uris.length === 0) return null;

      const fileInfo = await fs.open(uris[0], fs.OpenMode.READ_ONLY);
      const destPath = `${context.filesDir}/${Date.now()}_${fileInfo.name}`;
      const destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      await fs.copyFile(fileInfo.fd, destFile.fd);
      fs.closeSync(fileInfo);
      fs.closeSync(destFile);
      return destPath;
    } catch (err) { return null; }
  }

  static async readTextFile(path: string): Promise<string> {
    if (!path) return "";
    let file = await fs.open(path, fs.OpenMode.READ_ONLY);
    try {
      let stat = await fs.stat(file.path);
      let buffer = new ArrayBuffer(stat.size);
      await fs.read(file.fd, buffer);
      let uint8Array = new Uint8Array(buffer);
      let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      let result = textDecoder.decodeWithStream(uint8Array);
      if (result.includes('')) {
        textDecoder = util.TextDecoder.create('gbk');
        result = textDecoder.decodeWithStream(uint8Array);
      }
      return result;
    } finally { await fs.close(file); }
  }

  // 修复点：改用 FileManager.PREF_NAME
  static async saveProgress(context: common.Context, bookId: string, position: number): Promise<void> {
    const pref = await preferences.getPreferences(context, FileManager.PREF_NAME);
    await pref.put(bookId, position);
    await pref.flush();
  }

  // 修复点：改用 FileManager.PREF_NAME，并处理返回值类型
  static async getProgress(context: common.Context, bookId: string): Promise<number> {
    const pref = await preferences.getPreferences(context, FileManager.PREF_NAME);
    const value = await pref.get(bookId, 0);
    return Number(value);
  }
}