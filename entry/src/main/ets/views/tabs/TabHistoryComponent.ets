import TabHistoryViewModel, { YearTimelineItem } from "../../viewModel/TabHistoryViewModel";
import { Artwork, OneArtworkViewModel } from "../../viewModel/OneArtworkViewModel";
import { promptAction } from '@kit.ArkUI';

interface TimelineItemParams {
  item: YearTimelineItem;
  isFirst: boolean;
  isLast: boolean;
}

@Component
export struct TabHistoryComponent {
  @Link tabHistoryViewModel: TabHistoryViewModel;

  // 将常量定义为组件的私有只读成员
  private readonly IMAGE_SIZE: number = 65;
  private readonly IMAGE_MARGIN: number = 8;

  aboutToAppear() {
    this.tabHistoryViewModel.initLoadYears();
  }

  build() {
    Stack() {
      Column() {

        // 时间轴列表
        List() {
          ForEach(this.tabHistoryViewModel.yearList, (item: YearTimelineItem, index: number) => {
            ListItem() {
              this.YearTimelineItem({
                item: item,
                isFirst: index === 0,
                isLast: index === this.tabHistoryViewModel.yearList.length - 1
              } as TimelineItemParams)
            }
          })

          // 加载更多提示项
          ListItem() {
            Row()
            {
              if (this.tabHistoryViewModel.isLoadingMore) {
                LoadingProgress()
                  .width(30)
                  .height(30)
                Text('博物馆有访问限制15秒，请耐心等待...')
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

      // Loading 弹框层
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

  // 时间轴项组件 (已修正局部变量问题)
  @Builder
  YearTimelineItem(params: TimelineItemParams) {
    // 移除 const year = ... 和 const artworkList = ...
    // 直接使用 params.item.year 和 params.item.artworkList

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

      // 年份文本 - 直接使用 params.item.year
      Text(params.item.year >= 0 ? `${params.item.year}年` : `${Math.abs(params.item.year)}年 BCE`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width(80)
        .textAlign(TextAlign.Center)

      // 右侧图片区域
      Column() {
        // 第一行图片 (2x2 grid)
        Row() {
          // 只显示前两张图片 - 直接使用 params.item.artworkList
          ForEach(params.item.artworkList.slice(0, 2), (artwork: Artwork) => {
            Image(artwork.primaryImageSmall ? artwork.primaryImageSmall : $r('app.media.no_img'))
              .width(this.IMAGE_SIZE)
              .height(this.IMAGE_SIZE)
              .objectFit(ImageFit.Cover)
              .backgroundColor('#F0F0F0')
              .borderRadius(4)
              .margin({ right: this.IMAGE_MARGIN })
              .onClick(() => {
                promptAction.showToast({
                  message: artwork.title,
                  duration: 2000
                })
              })
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: this.IMAGE_MARGIN })

        // 第二行图片
        Row() {
          // 显示第三、第四张图片 - 直接使用 params.item.artworkList
          ForEach(params.item.artworkList.slice(2, 4), (artwork: Artwork) => {
            Image(artwork.primaryImageSmall ? artwork.primaryImageSmall : $r('app.media.no_img'))
              .width(this.IMAGE_SIZE)
              .height(this.IMAGE_SIZE)
              .objectFit(ImageFit.Cover)
              .backgroundColor('#F0F0F0')
              .borderRadius(4)
              .margin({ right: this.IMAGE_MARGIN })
              .onClick(() => {
                promptAction.showToast({
                  message: artwork.title,
                  duration: 2000
                })
              })
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)


        // 提示：如果没有图片，额外显示一个文本提示 - 直接使用 params.item.artworkList
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
    .height(180)
    .padding({ top: 10, bottom: 10 })
    .margin({ left: 20, right: 20 })
  }
}