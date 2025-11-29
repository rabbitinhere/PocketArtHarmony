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
  @Track currentArtwork: OneArtworkViewModel | null = null;
  @Track nextArtwork: OneArtworkViewModel | null = null; // 新增：下一张的引用，用于UI预渲染
  @Track prevArtwork: OneArtworkViewModel | null = null; // 新增：上一张的引用

  @Track artworkIDs: number[] = [];

  // 统一更新当前、上一张、下一张的引用
  private updateArtworks() {
    this.currentArtwork = this.artworks[this.currentIndex] || null;
    this.prevArtwork = this.artworks[this.currentIndex - 1] || null;

    // 尝试获取下一张，如果不存在则触发预加载
    const nextIndex = this.currentIndex + 1;
    this.nextArtwork = this.artworks[nextIndex] || null;

    // 触发预加载下一张
    this.preloadNextArtwork();
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

      // 截取一部分避免数据量过大，并打乱
      const shuffled = [...data.objectIDs].sort(() => 0.5 - Math.random()).slice(0, 50);
      return shuffled;
    } catch (error) {
      let msg = '';
      if (error instanceof Error) msg = error.message;
      console.error('获取艺术品ID列表失败:', msg);
      throw new Error('Fetch failed ' + msg);
    }
  }

  // 初始化加载
  async initialize(): Promise<void> {
    if (this.isLoading) return;

    this.isLoading = true;
    this.errorMessage = '';

    try {
      this.artworks = [];
      this.currentIndex = -1;
      this.currentArtwork = null;
      this.nextArtwork = null;

      this.artworkIDs = await this.fetchRandomArtworkIDs();

      // 找到第一张有图的
      if (this.artworkIDs.length > 0) {
        for (let i = 0; i < this.artworkIDs.length; i++) {
          const success = await this.loadArtworkByIndex(i, this.artworkIDs[i]);
          if (success) {
            // loadArtworkByIndex 内部会更新 currentIndex 和 updateArtworks
            break;
          }
        }
      }
    } catch (error) {
      let msg = '';
      if (error instanceof Error) msg = error.message;
      console.error('初始化失败:', msg);
      this.errorMessage = '加载失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载指定索引的艺术品
   */
  private async loadArtworkByIndex(index: number, artworkID: number): Promise<boolean> {
    // 如果缓存里已经有了
    if (this.artworks[index]) {
      // 如果是为了初始化，需要设置 currentIndex
      if (this.currentIndex === -1) {
        this.currentIndex = index;
        this.updateArtworks();
      } else if (index === this.currentIndex + 1) {
        // 如果是预加载的下一张完成了，更新引用
        this.updateArtworks();
      }
      return true;
    }

    try {
      const artworkVM = new OneArtworkViewModel();
      await artworkVM.fetchArtworkData(artworkID);

      // 必须要有一张小图
      if (!artworkVM.artwork.primaryImageSmall) {
        return false;
      }

      this.artworks[index] = artworkVM;

      // 如果当前还未设置初始图，或者加载的是当前/下一张，刷新视图状态
      if (this.currentIndex === -1) {
        this.currentIndex = index;
      }
      this.updateArtworks();

      return true;
    } catch (error) {
      console.error(`加载艺术品 ${artworkID} 失败`);
      return true; // 出错也返回true避免死循环，只是没图显示而已
    }
  }

  /**
   * 预加载下一张（静默执行，不阻塞UI）
   */
  private preloadNextArtwork() {
    const nextIndex = this.currentIndex + 1;
    if (nextIndex >= this.artworkIDs.length) return;

    // 如果已经存在，不需要加载
    if (this.artworks[nextIndex]) return;

    // 异步加载，不使用 await 阻塞
    this.loadArtworkByIndex(nextIndex, this.artworkIDs[nextIndex])
      .then(() => {
        // 加载完成后 updateArtworks 会被调用
      })
      .catch((e: Error) => {
        console.error(`预加载失败: ${e.message}`);
      });
  }

  // UI动画结束后调用：确认切换到下一张
  confirmSwipeToNext() {
    const nextIndex = this.currentIndex + 1;
    if (nextIndex < this.artworkIDs.length && this.artworks[nextIndex]) {
      this.currentIndex = nextIndex;
      this.updateArtworks();
    } else {
      // 如果滑过去发现没数据（极少情况），尝试紧急加载或回滚
      console.info("下一张尚未加载完成");
    }
  }

  // UI动画结束后调用：确认切换到上一张
  confirmSwipeToPrevious() {
    const prevIndex = this.currentIndex - 1;
    if (prevIndex >= 0 && this.artworks[prevIndex]) {
      this.currentIndex = prevIndex;
      this.updateArtworks();
    }
  }

  get canSwipePrevious(): boolean {
    return this.currentIndex > 0;
  }

  get canSwipeNext(): boolean {
    // 只要ID列表还有，理论上就可以滑，即使图还没加载出来（会显示占位）
    return this.currentIndex < this.artworkIDs.length - 1;
  }

  reset(): void {
    this.artworks = [];
    this.currentIndex = -1;
    this.currentArtwork = null;
    this.nextArtwork = null;
    this.errorMessage = '';
  }
}