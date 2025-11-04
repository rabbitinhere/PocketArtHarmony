import { OneArtworkViewModel } from "./OneArtworkViewModel";
import { http } from '@kit.NetworkKit';
import { HttpHelper } from "../http/NetworkService";
import { ArtworkListResp } from "./TabMainViewModel";

@Observed
export default class SwipeViewModel {
  @Track currentIndex: number = -1;
  @Track artworks: OneArtworkViewModel[] = [];
  @Track isLoading: boolean = false;
  @Track errorMessage: string = '';
  @Track currentArtwork: OneArtworkViewModel | null = null; // 改为普通属性
  artworkIDs: number[] = [];
  // 更新当前艺术品的方法
  private updateCurrentArtwork() {
    this.currentArtwork = this.artworks[this.currentIndex] || null;
  }

  // 获取随机艺术品ID列表
  private async fetchRandomArtworkIDs(): Promise<number[]> {
    try {
      const response = await HttpHelper.getInstance().request(
        `https://collectionapi.metmuseum.org/public/collection/v1/search?q=&isHighlight=true`,
        { method: http.RequestMethod.GET }
      );

      const data = JSON.parse(response.result as string) as ArtworkListResp;
      if (!data.objectIDs || data.objectIDs.length === 0) {
        throw new Error('未找到艺术品数据');
      }

      const shuffled = [...data.objectIDs]
        //.sort(() => 0.5 - Math.random());
      return shuffled;
    } catch (error) {
      console.error('获取艺术品ID列表失败:', error);
      throw new Error('Fetch failed ' + error);
    }
  }

  // 初始化加载第一张图片
  async initialize(): Promise<void> {
    if (this.isLoading) return;

    this.isLoading = true;
    this.errorMessage = '';

    try {
      this.artworks = [];
      this.currentIndex = -1;
      this.currentArtwork = null;

      this.artworkIDs = await this.fetchRandomArtworkIDs();
      if (this.artworkIDs.length > 0) {
        await this.loadArtworkByIndex(0, this.artworkIDs[0]);
      }
    } catch (error) {
      console.error('初始化失败:', error);
      this.errorMessage = '加载失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  // 根据索引加载艺术品
  private async loadArtworkByIndex(index: number, artworkID: number): Promise<void> {
    if (this.artworks[index]) { //初始化时这里是空，虽然加载了artworkId的列表，但是没有对id请求艺术品详情，所以没有艺术品详情列表
      this.currentIndex = index;
      this.updateCurrentArtwork();
      return;
    }

    try {
      const artworkVM = new OneArtworkViewModel();
      await artworkVM.fetchArtworkData(artworkID);

      if (!artworkVM.artwork.primaryImage) {
        throw new Error('该艺术品无有效图片');
      }

      this.artworks[index] = artworkVM;
      this.currentIndex = index;
      this.updateCurrentArtwork(); // 更新当前艺术品
    } catch (error) {
      console.error(`加载艺术品 ${artworkID} 失败:`, error);
      throw new Error('load failed ' + error);
    }
  }


  // 滑动到下一张（上滑）
  async swipeToNext(): Promise<void> {
    if (this.isLoading) return;

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const nextIndex = this.currentIndex + 1;

      if (this.artworks[nextIndex]) {
        this.currentIndex = nextIndex;
        this.updateCurrentArtwork();
        this.isLoading = false;
        return;
      }

      if (this.artworkIDs.length > 0) {
        await this.loadArtworkByIndex(nextIndex, this.artworkIDs[nextIndex]);
      }
    } catch (error) {
      console.error('滑动到下一张失败:', error);
      this.errorMessage = '加载失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  // 滑动到上一张（下滑）
  async swipeToPrevious(): Promise<void> {
    if (this.isLoading || this.currentIndex <= 0) return;

    this.errorMessage = '';
    this.currentIndex = this.currentIndex - 1;
    this.updateCurrentArtwork(); // 更新当前艺术品
  }

  // 检查是否可以下滑
  get canSwipePrevious(): boolean {
    return this.currentIndex > 0;
  }

  // 重置状态
  reset(): void {
    this.artworks = [];
    this.currentIndex = -1;
    this.currentArtwork = null;
    this.errorMessage = '';
  }
}