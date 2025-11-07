import { OneArtworkViewModel } from "./OneArtworkViewModel";
import { http } from '@kit.NetworkKit'; //  注意这里要解构导入
import { HttpHelper } from "../http/NetworkService";

@Observed
export class ThingViewModelArray extends Array<OneArtworkViewModel> {
}

@Observed
export default class TabMainViewModel {
  @Track isChoosen: boolean = true;
  @Track things: ThingViewModelArray = new ThingViewModelArray();
  @Track isInitLoading: boolean = false; // 是否显示 Loading
  @Track isLoadingMore: boolean = false; // 是否显示 Loading
  @Track hasMoreData: boolean = true; // 新增：是否还有更多数据可加载
  // 新增实例变量
  private allObjectIDs: number[] = [];
  private currentPage: number = 0;
  @Track searchKeyword: string = ""; // 新增：搜索关键词

  async loadArtworks() {
    this.isInitLoading = true;
    try {
      // 清空原有数据
      this.things = new ThingViewModelArray();

      const artListResp = await HttpHelper.getInstance().request(`https://collectionapi.metmuseum.org/public/collection/v1/search?q=&isHighlight=true`,
        { method: http.RequestMethod.GET })


      // 存储所有对象ID用于分页
      const artLIstRespBean = JSON.parse(artListResp.result as string) as ArtworkListResp;
      this.allObjectIDs = artLIstRespBean.objectIDs;
      this.currentPage = 0; // 重置分页索引
      this.hasMoreData = true;

      // 加载第一页
      await this.loadNextPage(true);
    } catch (e) {
      console.error('初始化加载失败:', e);
    } finally {
      this.isInitLoading = false;
    }
  }

  // 新增：搜索艺术品方法
  async searchArtworks() {
    if (!this.searchKeyword.trim()) {
      // 如果搜索关键词为空，则加载默认列表
      await this.loadArtworks();
      return;
    }

    this.isInitLoading = true;
    try {
      // 清空原有数据
      this.things = new ThingViewModelArray();

      const artListResp = await HttpHelper.getInstance().request(
        `https://collectionapi.metmuseum.org/public/collection/v1/search?q=${encodeURIComponent(this.searchKeyword)}&isHighlight=true`,
        { method: http.RequestMethod.GET }
      )

      const artLIstRespBean = JSON.parse(artListResp.result as string) as ArtworkListResp;
      this.allObjectIDs = artLIstRespBean.objectIDs;
      this.currentPage = 0;
      this.hasMoreData = this.allObjectIDs.length > 0;

      if (this.hasMoreData) {
        await this.loadNextPage(true);
      } else {
        // 没有搜索结果
        this.things = new ThingViewModelArray();
      }
    } catch (e) {
      console.error('搜索失败:', e);
    } finally {
      this.isInitLoading = false;
    }
  }

  async loadNextPage(firstPage: boolean) {
    if (!this.hasMoreData) return;

    if(firstPage == false){
      this.isLoadingMore = true;
    }
    try {
      const start = this.currentPage * 5;
      const end = start + 5;

      if (start >= this.allObjectIDs.length) {
        this.hasMoreData = false;
        return;
      }

      const tasks: Promise<OneArtworkViewModel>[] = [];
      for (let i = start; i < Math.min(end, this.allObjectIDs.length); i++) {
        const vm = new OneArtworkViewModel();
        tasks.push(vm.fetchArtworkData(this.allObjectIDs[i]).then(() => vm));
      }

      const results = await Promise.all(tasks);
      this.things = [...this.things, ...results];

      this.currentPage++;

      if (this.currentPage * 5 >= this.allObjectIDs.length) {
        this.hasMoreData = false;
      }
    } catch (e) {
      console.error('加载更多失败:', e);
    } finally {
      if(firstPage == false){
        this.isLoadingMore = false;
      }
    }
  }

}


@Observed
export class ArtworkListResp {
  total: number = 0;
  objectIDs: number[] = [];
}
