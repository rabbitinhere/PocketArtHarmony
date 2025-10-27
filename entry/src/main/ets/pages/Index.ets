import { common } from '@kit.AbilityKit';
// import ViewModel
import TodoListViewModel from '../viewModel/TodoListViewModel';

import { TabMainComponent } from '../views/tabs/TabMainComponent';

// ra_todo 在这里看官方怎么写mvvm的，先copy过来跑起来，再看，看文章的最下面。https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-mvvm#mvvm%E6%A8%A1%E5%BC%8F%E4%BB%8B%E7%BB%8D
@Entry
@Component
struct TodoList {
  @State todoListViewModel: TodoListViewModel = new TodoListViewModel();
  @State currentPage: number = 0; // 当前页面索引
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  async aboutToAppear() {
    // await this.todoListViewModel.loadTasks(this.context);
  }

  build() {
    Column() {
      // 内容区域
      Stack() {
        // 页面1：原有待办列表
        if (this.currentPage === 0) {
          TabMainComponent({ todoListViewModel: this.todoListViewModel })
        }

        // 页面2
        if (this.currentPage === 1) {
          Text('页面2')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .align(Alignment.Center)
        }

        // 页面3
        if (this.currentPage === 2) {
          Text('页面3')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .align(Alignment.Center)
        }
      }
      .height('90%')

      // 底部导航栏
      Row() {
        Button('页面1')
          .onClick(() => this.currentPage = 0)
          .backgroundColor(this.currentPage === 0 ? '#409EFF' : '#444444')

        Button('页面2')
          .onClick(() => this.currentPage = 1)
          .backgroundColor(this.currentPage === 1 ? '#409EFF' : '#444444')

        Button('页面3')
          .onClick(() => this.currentPage = 2)
          .backgroundColor(this.currentPage === 2 ? '#409EFF' : '#444444')
      }
      .width('100%')
      .height('10%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#90f1f3f5')
  }
}