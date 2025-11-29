import { common } from '@kit.AbilityKit';
import SwipeViewModel from '../viewModel/SwipeViewModel';
import TabHistoryViewModel from '../viewModel/TabHistoryViewModel';
// import ViewModel
import TabMainViewModel from '../viewModel/TabMainViewModel';
import { TabHistoryComponent } from '../views/tabs/TabHistoryComponent';
import { TabMainComponent } from '../views/tabs/TabMainComponent';
import { TabSwipeComponent } from '../views/tabs/TabSwipeComponent';

// ra_todo 在这里看官方怎么写mvvm的，先copy过来跑起来，再看，看文章的最下面。https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-mvvm#mvvm%E6%A8%A1%E5%BC%8F%E4%BB%8B%E7%BB%8D
@Entry
@Component
struct MainPage {
  @State todoListViewModel: TabMainViewModel = new TabMainViewModel();
  @State swipeViewModel: SwipeViewModel = new SwipeViewModel();
  @State tabHistoryViewModel: TabHistoryViewModel = new TabHistoryViewModel();
  @State currentPage: number = 0; // 当前页面索引
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;


  private tabConfigs: TabConfig[] = [
    { index: 0, name: 'Search' },
    { index: 1, name: 'Swipe' },
    { index: 2, name: 'History' }
  ];
  async aboutToAppear() {
    // await this.todoListViewModel.loadTasks(this.context);
  }

  build() {
    Column() {
      // 内容区域
      Stack() {
        // 页面1
        TabMainComponent({ todoListViewModel: this.todoListViewModel }).visibility(this.currentPage === 0 ? Visibility.Visible : Visibility.None)

        // 页面2
        TabSwipeComponent({ swipeViewModel: this.swipeViewModel }).visibility(this.currentPage === 1 ? Visibility.Visible : Visibility.None)

        TabHistoryComponent({ tabHistoryViewModel: this.tabHistoryViewModel }).visibility(this.currentPage === 2 ? Visibility.Visible : Visibility.None)

      }
      .height('90%')

      // 使用封装的底部导航栏
      this.TabBar()
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#90f1f3f5')
  }

  // 底部导航栏组件
  @Builder TabBar() {
    Row() {
      ForEach(this.tabConfigs, (tab: TabConfig) => {
        this.TabItem(tab)
      })
    }
    .width('100%')
    .height('10%')
    .justifyContent(FlexAlign.SpaceBetween)
    .border({ width: { top: 1 }, color: '#E5E5E5' })
  }

  // 封装的标签页组件
  @Builder TabItem(tab: TabConfig) {

    Column() {
      Text(tab.name)
        .fontSize(16)
        .fontColor(this.currentPage === tab.index ? '#409EFF' : '#666666')
        .fontWeight(this.currentPage === tab.index ? FontWeight.Bold : FontWeight.Normal)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .border({
      width: {
        left: tab.index === 0 ? 0 : 1,  // 第一个元素左边框为0
        right: 1
      },
      color: '#E5E5E5'
    })
    .onClick(() => {
      this.currentPage = tab.index;
    })
  }
}

// 底部导航栏配置数据
interface TabConfig {
  index: number;
  name: string;
}