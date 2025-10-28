import { http } from '@kit.NetworkKit'; // ✅ 注意这里要解构导入

@Observed
export class ThingViewModel {
  @Track artwork: Artwork = new Artwork();
  @Track isFinish: boolean = false;

  async fetchArtworkData(id: number):Promise<ThingViewModel> {
    try {
      // ✅ 正确创建 http 实例
      const httpRequest = http.createHttp();

      // ✅ 发送请求
      const response = await httpRequest.request(
        `https://collectionapi.metmuseum.org/public/collection/v1/objects/${id}`,
        {
          method: http.RequestMethod.GET,
        }
      );

      // ✅ 从响应中取出数据
      const result: Artwork = JSON.parse(response.result as string) as Artwork;
      this.artwork = result as Artwork;

      // ✅ 关闭请求实例（防止资源泄漏）
      httpRequest.destroy();
    } catch (e) {
      console.error(`Failed to fetch artwork ${id}: ${e}`);
    }
    return this;
  }
}

@Observed
export class Artwork {
  objectID: number = 0;
  title: string = '';
  primaryImage: string = '';
  primaryImageSmall: string = '';
}


