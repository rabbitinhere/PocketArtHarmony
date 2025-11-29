import { Artwork, OneArtworkViewModel } from "./OneArtworkViewModel";
import { http } from '@kit.NetworkKit';
import { HttpHelper } from "../http/NetworkService";
// 假设您有一个 ArtworkListResp 类型，这里保持原样
// import { ArtworkListResp } from "./TabMainViewModel";

// 假设 ArtworkListResp 的类型定义
interface ArtworkListResp {
  objectIDs: number[];
  total: number;
}

@Observed
export default class SwipeViewModel {
  @Track currentIndex: number = -1;
  @Track artworks: OneArtworkViewModel[] = [];//避免重复请求网络，把已经请求的艺术品存起来一个列表
  @Track isLoading: boolean = false;
  @Track errorMessage: string = '';
  @Track testNext: string = '上滑查看更多';
  @Track curArtBean: Artwork | null = null;
  @Track preArtBean: Artwork | null = null;
  @Track nextArtBean: Artwork | null = null;

  @Track artworkIDs: number[] = [];

  // 【修复点 1】：将 Getter 属性改为 @Track 属性
  @Track canSwipePrevious: boolean = false;
  @Track canSwipeNext: boolean = false;

  // 统一更新当前、上一张、下一张的引用和状态
  private updateArtworks() {
    this.curArtBean = (this.artworks[this.currentIndex] || null)?.artwork;
    this.preArtBean = (this.artworks[this.currentIndex - 1] || null)?.artwork;
    this.nextArtBean = (this.artworks[this.currentIndex + 1] || null)?.artwork;

    // 【修复点 2】：在这里计算并更新 @Track 属性
    this.canSwipePrevious = this.currentIndex > 0;
    this.canSwipeNext = this.currentIndex < this.artworkIDs.length - 1;

  }


  private async timerTest() {
    setInterval(() => {
    }, 1000);
  }

  // 获取随机艺术品ID列表 (保持不变)
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
      this.curArtBean = null;
      this.preArtBean = null;
      this.nextArtBean = null;
      this.artworkIDs = await this.fetchRandomArtworkIDs();

      // 【修复点 3】：循环查找第一个有图的ID作为初始图
      if (this.artworkIDs.length > 0) {
        for (let i = 0; i < this.artworkIDs.length; i++) {
          const success = await this.loadArtworkByIndex(i, this.artworkIDs[i]);
          if (success) {
            // loadArtworkByIndex 内部会更新 currentIndex 和 updateArtworks
            break;
          }
        }
      }

      this.preloadNextArtwork();
    } catch (error) {
      let msg = '';
      if (error instanceof Error) msg = error.message;
      console.error('初始化失败:', msg);
      this.errorMessage = '加载失败，请重试';
    } finally {
      this.isLoading = false;
    }
    this.timerTest()
  }

  /**
   * 加载指定索引的艺术品
   * @returns true 如果成功加载且有 primaryImageSmall，否则 false
   */
  private async loadArtworkByIndex(index: number, artworkID: number): Promise<boolean> {
    // 如果缓存里已经有了
    if (this.artworks[index] && this.artworks[index].artwork.primaryImageSmall) {
      if (this.currentIndex === -1) {
        this.currentIndex = index;
        this.updateArtworks();
      } else if (index === this.currentIndex + 1) {
        this.updateArtworks();
      }
      return true;
    }

    // 如果已缓存但没图，则直接返回 false，让上层逻辑继续找
    if (this.artworks[index] && !this.artworks[index].artwork.primaryImageSmall) {
      return false;
    }

    try {
      const artworkVM = new OneArtworkViewModel();
      await artworkVM.fetchArtworkData(artworkID);

      this.artworks[index] = artworkVM; // 占位，避免重复请求

      // 【关键修复】：如果没图，返回 false，让上层循环继续
      if (!artworkVM.artwork.primaryImageSmall) {
        return false;
      }

      // 如果当前还未设置初始图，或者加载的是当前/下一张，刷新视图状态
      if (this.currentIndex === -1) {
        this.currentIndex = index;
      }
      this.updateArtworks();

      return true;
    } catch (error) {
      // 加载失败，也返回 false，让上层逻辑继续找下一个
      console.error(`加载艺术品 ${artworkID} 失败`);
      return false;
    }
  }

  /**
   * 预加载下一张（静默执行，不阻塞UI）
   */
  private preloadNextArtwork() {
    const nextIndex = this.currentIndex + 1;
    if (nextIndex >= this.artworkIDs.length) return;

    // 如果已经存在或正在加载，不需要操作
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


  doTestNext(){
    this.testNext = "dfdfdf"
  }
  // UI动画结束后调用：确认切换到下一张
  async confirmSwipeToNext(): Promise<void> {
    const nextIndex = this.currentIndex + 1;

    // 逻辑修正：找下一个有图的ID
    if (nextIndex < this.artworkIDs.length) {
      this.isLoading = true;
      try {
        for (let i = nextIndex; i < this.artworkIDs.length; i++) {
          const success = await this.loadArtworkByIndex(i, this.artworkIDs[i]);
          if (success) {
            this.currentIndex = i;
            this.updateArtworks();
            break;
          }
        }
        this.preloadNextArtwork();
      } finally {
        this.isLoading = false;
      }
    }

  }

  // UI动画结束后调用：确认切换到上一张
  confirmSwipeToPrevious() {
    const prevIndex = this.currentIndex - 1;
    // 逻辑修正：往前找第一个有图的
    for (let i = prevIndex; i >= 0; i--) {
      if (this.artworks[i] && this.artworks[i].artwork.primaryImageSmall) {
        this.currentIndex = i;
        this.updateArtworks();
        return;
      }
    }
  }

  // 移除 Getter，仅保留 @Track 属性
  reset(): void {
    this.artworks = [];
    this.currentIndex = -1;
    this.curArtBean = null;
    this.preArtBean = null;
    this.nextArtBean = null;
    this.errorMessage = '';
    this.canSwipePrevious = false;
    this.canSwipeNext = false;
  }
}