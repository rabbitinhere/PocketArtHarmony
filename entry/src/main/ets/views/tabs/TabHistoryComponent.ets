import TabHistoryViewModel, { YearTimelineItem, TimelineArtwork } from "../../viewModel/TabHistoryViewModel";
import { OneArtworkViewModel } from "../../viewModel/OneArtworkViewModel";
// 导入 promptAction 用于 Toast
import { promptAction } from '@kit.ArkUI';

// 更新接口，使用新的数据结构
interface TimelineItemParams {
  item: YearTimelineItem;
  isFirst: boolean;
  isLast: boolean;
}

@Component
export struct TabHistoryComponent {
  @Link tabHistoryViewModel: TabHistoryViewModel;

  // 移除 generateSampleImages 方法，因为现在数据来自 ViewModel

  aboutToAppear() {
    this.tabHistoryViewModel.initLoadYears();
  }

  build() {
    Stack() {
      Column() {
        // 标题
        Text('Art Timeline')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: 20, bottom: 20 })

        // 时间轴列表
        List() {
          ForEach(this.tabHistoryViewModel.yearList, (item: YearTimelineItem, index: number) => {
            ListItem() {
              // 传递整个 item 对象
              this.YearTimelineItem({
                item: item,
                isFirst: index === 0,
                isLast: index === this.tabHistoryViewModel.yearList.length - 1
              } as TimelineItemParams)
            }
          })

          // 加载更多提示项 (保持不变)
          ListItem() {
            Row()
            {
              if (this.tabHistoryViewModel.isLoadingMore) {
                LoadingProgress()
                  .width(30)
                  .height(30)
                Text('加载中...')
                  .margin({ left: 8 })
              } else {
                Text('上拉加载更多')
                  .fontColor('#666')
              }
            }
            .width('100%')
            .height(60)
            .justifyContent(FlexAlign.Center)
            .visibility(this.tabHistoryViewModel.hasMoreData ? Visibility.Visible : Visibility.None)
          }

        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .onReachEnd(() => {
          if (!this.tabHistoryViewModel.isLoadingMore && this.tabHistoryViewModel.hasMoreData) {
            console.info("history_reach_end_load")
            this.tabHistoryViewModel.loadNextPage(false);
          }
        })
      }
      .width('100%')
      .height('100%')

      // Loading 弹框层 (保持不变)
      if (this.tabHistoryViewModel.isInitLoading) {
        Stack() {
          Rect()
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Black)
            .opacity(0.3)

          Column() {
            LoadingProgress()
              .color('#ffffff')
              .width(60)
              .height(60)
            Text('加载中...')
              .fontSize(18)
              .fontColor('#ffffff')
              .margin({ top: 12 })
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
    }
  }

  // 时间轴项组件 (重点改造)
  @Builder
  YearTimelineItem(params: TimelineItemParams) {

    Row() {
      // 左侧时间轴区域 (保持不变)
      Column() {
        Column() {
          Column()
            .width(2)
            .height('100%')
            .backgroundColor('#E5E5E5')
            .alignSelf(ItemAlign.Center)
            .position({ x: 0, y: 0 })

          Column() {
            Column()
              .width(2)
              .height('100%')
              .backgroundColor('#007DFF')
              .alignSelf(ItemAlign.Center)
          }
          .width(2)
          .height('100%')
          .alignSelf(ItemAlign.Center)

          Circle()
            .width(20)
            .height(20)
            .fill('#007DFF')
            .stroke('#FFFFFF')
            .strokeWidth(2)
        }
        .width(2)
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      .width(60)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 年份文本
      Text(params.item.year >= 0 ? `${params.item.year}年` : `${Math.abs(params.item.year)}年 BCE`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width(80)
        .textAlign(TextAlign.Center)

      // 右侧图片区域
      Column() {
        // 4 张图片水平排列，来自 ViewModel 的真实数据
        Row() {
          // 循环展示艺术品图片
          ForEach(params.item.artworkList, (artwork: TimelineArtwork) => {
            Image(artwork.imageUrl ? artwork.imageUrl : $r('app.media.no_img')) // 使用真实 URL，为空则使用默认图
              .width(48)
              .height(48)
              .objectFit(ImageFit.Cover) // 确保图片适应大小
              .backgroundColor('#F0F0F0')
              .borderRadius(4)
              .margin({ right: 5 })
              .onClick(() => {
                // 添加点击事件，Toast 提示显示艺术品名字 (title)
                promptAction.showToast({
                  message: artwork.title,
                  duration: 2000
                })
              })
          })

          // 如果艺术品数量不足4个，留空占位 (可选，这里不占位，让图片自然排列)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        // 年份描述文本
        Text(`公元${params.item.year >= 0 ? params.item.year : Math.abs(params.item.year)}年${params.item.year >= 0 ? '' : '前'}的代表性艺术作品`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 8 })
          .width('100%')

        // 提示：如果没有图片，额外显示一个文本提示
        if (params.item.artworkList.length === 0) {
          Text('该时间段暂无艺术品数据')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 5 })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .margin({ left: 10, right: 10 })
      .padding(10)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .shadow({ radius: 4, color: '#1A000000', offsetX: 1, offsetY: 2 })
    }
    .width('100%')
    .height(120)
    .padding({ top: 10, bottom: 10 })
    .margin({ left: 20, right: 20 })
  }
}