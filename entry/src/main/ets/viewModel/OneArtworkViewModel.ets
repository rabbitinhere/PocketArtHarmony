import { http } from '@kit.NetworkKit'; // ✅ 注意这里要解构导入
import { HttpHelper } from '../http/NetworkService';

@Observed
export class OneArtworkViewModel {
  @Track artwork: Artwork = new Artwork();
  @Track isFinish: boolean = false;

  async fetchArtworkData(id: number):Promise<OneArtworkViewModel> {
    try {
      const response = await HttpHelper.getInstance().request(`https://collectionapi.metmuseum.org/public/collection/v1/objects/${id}`,
        {
          method: http.RequestMethod.GET,
        })
      const result: Artwork = JSON.parse(response.result as string) as Artwork;
      this.artwork = result as Artwork;

    } catch (e) {
      console.error(`Failed to fetch artwork ${id}: ${e}`);
    }
    return this;
  }
}

@Observed
export class Artwork {
  @Track objectID: number = 0;
  @Track title: string = '';
  @Track primaryImage: string = '';
  @Track primaryImageSmall: string = '';
  @Track artistDisplayName: string = ''; // 艺术家
  @Track objectDate: string = ''; // 创作日期
  @Track medium: string = ''; // 媒介/材料
  @Track dimensions: string = ''; // 尺寸
  @Track culture: string = ''; // 文化
  @Track department: string = ''; // 部门
}


