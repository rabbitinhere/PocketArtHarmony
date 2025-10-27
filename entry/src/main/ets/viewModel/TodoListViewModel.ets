import { ThingViewModel } from "./ThingViewModel";
import { http } from '@kit.NetworkKit'; // ✅ 注意这里要解构导入
import { common } from "@kit.AbilityKit";
import TodoListModel from "../model/TodoListModel";

@Observed
export class ThingViewModelArray extends Array<ThingViewModel> {
}

@Observed
export default class TodoListViewModel {
  @Track isChoosen: boolean = true;
  @Track things: ThingViewModelArray = new ThingViewModelArray();
  @Track isLoading: boolean = false; // ✅ 新增：是否显示 Loading


  async loadArtworks() {
    // ✅ 开始加载
    this.isLoading = true;

    try {
      this.things = new ThingViewModelArray();


      const httpRequest = http.createHttp();
      const artListResp = await httpRequest.request(
        `https://collectionapi.metmuseum.org/public/collection/v1/search?q=&isHighlight=true`,
        {
          method: http.RequestMethod.GET,
        }
      );
      if (!artListResp.result) {
        console.error("未获取到返回数据");
        return;
      }

      const artLIstRespBean: ArtworkListResp = JSON.parse(artListResp.result as string) as ArtworkListResp;
      if (!artLIstRespBean || !artLIstRespBean.objectIDs || artLIstRespBean.objectIDs.length === 0) {
        console.error("objectIDs 为空");
        return;
      }
      const tasks: Promise<ThingViewModel>[] = [];

      for (let i = 0; i <= 4; i++) {
        const vm = new ThingViewModel();
        const task = vm.fetchArtworkData(artLIstRespBean.objectIDs[i]).then(() => vm);
        tasks.push(task);
      }

      const results = await Promise.all(tasks);
      this.things = results as ThingViewModelArray;
    } catch (e) {
      console.error('加载艺术品失败:', e);
    } finally {
      // ✅ 加载结束
      this.isLoading = false;
    }
  }

  chooseAll(): void {
    for (let thing of this.things) {
      thing.isFinish = this.isChoosen;
    }
    this.isChoosen = !this.isChoosen;
  }
}


@Observed
export class ArtworkListResp {
  total: number = 0;
  objectIDs: number[] = [];
}
