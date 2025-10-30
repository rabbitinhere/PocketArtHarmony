import { http } from '@kit.NetworkKit'; // ✅ 注意这里要解构导入
import { HttpHelper } from '../http/NetworkService';

@Observed
export class ThingViewModel {
  @Track artwork: Artwork = new Artwork();
  @Track isFinish: boolean = false;

  async fetchArtworkData(id: number):Promise<ThingViewModel> {
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
  objectID: number = 0;
  title: string = '';
  primaryImage: string = '';
  primaryImageSmall: string = '';
}


