import { http } from '@kit.NetworkKit';
// 假设 HttpHelper 和 OneArtworkViewModel 已经被正确导入
import { HttpHelper } from "../http/NetworkService";
import { OneArtworkViewModel } from "./OneArtworkViewModel"; // 保留导入，尽管这里不直接使用 OneArtworkViewModel

// 定义单个艺术品的数据结构，用于组件显示
export interface TimelineArtwork {
  objectID: number;
  imageUrl: string; // primaryImageSmall
  title: string;
}

// 定义时间轴列表项的数据结构
export interface YearTimelineItem {
  year: number; // 当前年份（作为范围的 dateEnd）
  artworkList: TimelineArtwork[]; // 艺术品列表
}

@Observed
export class YearListArray extends Array<YearTimelineItem> {
}

// 博物馆 API 搜索结果的结构
interface ArtworkListResp {
  total: number;
  objectIDs: number[];
}

// 博物馆 API 详情结果的结构
interface ArtworkDetailResp {
  objectID: number;
  primaryImageSmall: string;
  title: string;
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

  // 计算总时间段数量
  private totalPeriods: number = Math.floor((this.startYear - this.endYear) / this.step) + 1;


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
      this.hasMoreData = false;
    } finally {
      this.isInitLoading = false;
    }
  }

  // 获取单个年份范围的艺术品数据
  private async fetchArtworksForYearRange(dateBegin: number, dateEnd: number): Promise<TimelineArtwork[]> {
    const artworks: TimelineArtwork[] = [];
    const SEARCH_API = `https://collectionapi.metmuseum.org/public/collection/v1/search?q=&dateBegin=${dateBegin}&dateEnd=${dateEnd}`;
    const DETAIL_BASE_API = `https://collectionapi.metmuseum.org/public/collection/v1/objects/`;

    try {
      // 1. 调用搜索 API 获取 objectIDs
      const searchResp = await HttpHelper.getInstance().request(SEARCH_API, { method: http.RequestMethod.GET });
      const searchData = JSON.parse(searchResp.result as string) as ArtworkListResp;

      const objectIDs = searchData.objectIDs;
      if (!objectIDs || objectIDs.length === 0) {
        console.info(`加载年份范围 ${dateBegin} 至 ${dateEnd} 艺术品为空！`);
        return artworks; // 无结果
      }else{
        console.info(`加载年份范围 ${dateBegin} 至 ${dateEnd} 艺术品数量${objectIDs.length}`);
      }

      // 2. 取前 4 个 objectIDs 调用详情 API
      const detailTasks: Promise<http.HttpResponse>[] = [];
      const idsToFetch = objectIDs.slice(0, 4);

      idsToFetch.forEach(id => {
        detailTasks.push(HttpHelper.getInstance().request(DETAIL_BASE_API + id, { method: http.RequestMethod.GET }));
      });

      const detailResults = await Promise.all(detailTasks);

      // 3. 解析详情结果
      detailResults.forEach(resp => {
        try {
          const detailData = JSON.parse(resp.result as string) as ArtworkDetailResp;

          artworks.push({
            objectID: detailData.objectID,
            // primaryImageSmall 字段可能为空，组件中将使用默认图
            imageUrl: detailData.primaryImageSmall || '',
            title: detailData.title || '未知艺术品'
          });
        } catch (e) {
          console.error('解析艺术品详情失败:', e);
        }
      });

    } catch (e) {
      console.error(`加载年份范围 ${dateBegin} 至 ${dateEnd} 艺术品失败:`, e);
    }

    return artworks;
  }

  // 加载下一页年份数据 (包含艺术品图片)
  async loadNextPage(firstPage: boolean) {
    if (!this.hasMoreData) return;

    if (firstPage == false) {
      this.isLoadingMore = true;
    }

    try {
      const start = this.currentPage * this.perPage;
      const end = start + this.perPage;

      const yearTasks: Promise<YearTimelineItem>[] = [];

      for (let i = start; i < Math.min(end, this.totalPeriods); i++) {
        // 计算当前时间段的结束年份 (year)
        const dateEnd = this.startYear - i * this.step;
        // 计算当前时间段的开始年份
        const dateBegin = dateEnd - this.step;

        // 异步获取当前时间段的艺术品数据
        const task = this.fetchArtworksForYearRange(dateBegin, dateEnd).then(artworkList => ({
          year: dateEnd,
          artworkList: artworkList
        } as YearTimelineItem));

        yearTasks.push(task);
      }

      const newYearItems = await Promise.all(yearTasks);

      // 更新列表，使用新的数据结构
      this.yearList = [...this.yearList, ...newYearItems];

      this.currentPage++;

      // 检查是否还有更多数据
      if (this.currentPage * this.perPage >= this.totalPeriods) {
        this.hasMoreData = false;
      }

    } catch (e) {
      console.error('加载更多年份和艺术品失败:', e);
    } finally {
      if (firstPage == false) {
        this.isLoadingMore = false;
      }
    }
  }
}