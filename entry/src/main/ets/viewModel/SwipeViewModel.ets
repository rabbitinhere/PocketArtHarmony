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
        // 循环遍历所有艺术品ID，直到找到一个有图片的艺术品
        for (let i = 0; i < this.artworkIDs.length; i++) {
          const success = await this.loadArtworkByIndex(i, this.artworkIDs[i]);
          if (success) {
            break; // 如果加载成功（有图片），则跳出循环
          }
          // 如果加载失败（没有图片），继续尝试下一个
        }
      }
    } catch (error) {
      console.error('初始化失败:', error);
      this.errorMessage = '加载失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }


  /**
   * 根据索引加载艺术品
   * @param index
   * @param artworkID
   * @returns false：这个艺术品没有图片， true：这个艺术品有图片或者网络错误
   */
  private async loadArtworkByIndex(index: number, artworkID: number): Promise<boolean> {
    if (this.artworks[index]) { //初始化时这里是空，虽然加载了artworkId的列表，但是没有对id请求艺术品详情，所以没有艺术品详情列表
      this.currentIndex = index;
      this.updateCurrentArtwork();
      return true;
    }

    try {
      const artworkVM = new OneArtworkViewModel();
      await artworkVM.fetchArtworkData(artworkID);

      if (!artworkVM.artwork.primaryImage) {
        return false;
      }

      this.artworks[index] = artworkVM;
      this.currentIndex = index;
      this.updateCurrentArtwork(); // 更新当前艺术品
      return true;
    } catch (error) {
      console.error(`加载艺术品 ${artworkID} 失败:`, error);
      return true;
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
        if (this.artworkIDs.length > 0) {
          // 循环遍历所有艺术品ID，直到找到一个有图片的艺术品
          for (let i = nextIndex; i < this.artworkIDs.length; i++) {
            const success = await this.loadArtworkByIndex(i, this.artworkIDs[i]);
            if (success) {
              console.info("ra_todo  有图，break ", this.artworkIDs[i])
              break; // 如果加载成功（有图片），则跳出循环
            }else {
              console.info("ra_todo  没有图，continue ", this.artworkIDs[i])
            }
            // 如果加载失败（没有图片），继续尝试下一个
          }
        }
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

    for (let i = this.currentIndex - 1; i >= 0; i--) {
      // 先检查 artworks[i] 是否存在
      if (!this.artworks[i]) {
        console.info("ra_todo  artwork不存在，continue ", this.artworkIDs[i]);
        this.currentIndex = i;
        continue;
      }

      const success = this.artworks[i].artwork.primaryImage !== "";
      if (success) {
        console.info("ra_todo  有图，break ", this.artworkIDs[i])
        this.currentIndex = i;
        break;
      }else {
        console.info("ra_todo  没有图，continue ", this.artworkIDs[i])
        this.currentIndex = i;
      }

    }
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