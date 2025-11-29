import { http } from '@kit.NetworkKit'; // 导入必要的模块，尽管这里我们只使用模拟数据
import { OneArtworkViewModel } from "./OneArtworkViewModel";

@Observed
export class YearListArray extends Array<number> {
}

@Observed
export default class TabHistoryViewModel {
  @Track yearList: YearListArray = new YearListArray();
  @Track isInitLoading: boolean = false;
  @Track isLoadingMore: boolean = false;
  @Track hasMoreData: boolean = true;
  @Track currentPage: number = 0;

  private startYear: number = 2000;
  private endYear: number = -2000;
  private step: number = 100;
  private perPage: number = 5; // 每页加载 5 个时间段

  // 计算总页数和总数据量，虽然这里是固定的，但为了和网络请求逻辑保持一致
  private totalYears: number = Math.floor((this.startYear - this.endYear) / this.step) + 1;


  // 初始化加载/刷新
  async initLoadYears() {
    this.isInitLoading = true;
    try {
      this.yearList = new YearListArray();
      this.currentPage = 0;
      this.hasMoreData = true;

      await this.loadNextPage(true);
    } catch (e) {
      console.error('初始化加载年份失败:', e);
    } finally {
      this.isInitLoading = false;
    }
  }

  // 加载下一页年份数据
  async loadNextPage(firstPage: boolean) {
    if (!this.hasMoreData) return;

    if (firstPage == false) {
      this.isLoadingMore = true;
    }

    try {
      const start = this.currentPage * this.perPage;
      const end = start + this.perPage;

      // 计算实际要加载的年份列表
      const newYears: number[] = [];
      for (let i = start; i < Math.min(end, this.totalYears); i++) {
        const year = this.startYear - i * this.step;
        newYears.push(year);
      }

      this.yearList = [...this.yearList, ...newYears];

      this.currentPage++;

      // 检查是否还有更多数据
      if (this.currentPage * this.perPage >= this.totalYears) {
        this.hasMoreData = false;
      }

    } catch (e) {
      console.error('加载更多年份失败:', e);
    } finally {
      if (firstPage == false) {
        this.isLoadingMore = false;
      }
    }
  }
}

// 保持原有的 ViewModel 结构，尽管在这个场景下不需要 ArtworkListResp
@Observed
export class ArtworkListResp {
  total: number = 0;
  objectIDs: number[] = [];
}