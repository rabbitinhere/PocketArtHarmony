import TabHistoryViewModel from "../../viewModel/TabHistoryViewModel";
import { OneArtworkViewModel } from "../../viewModel/OneArtworkViewModel";

interface TimelineItemParams {
  year: number;
  isFirst: boolean;
  isLast: boolean;
}

@Component
export struct TabHistoryComponent {
  // 绑定新的 TabHistoryViewModel
  @Link tabHistoryViewModel: TabHistoryViewModel;

  // 移除本地的 yearList 和 generateYearList 方法

  // 生成测试图片数据（5张小图片）
  private generateSampleImages(): string[] {
    return [
      'sample_image_1',
      'sample_image_2',
      'sample_image_3',
      'sample_image_4',
      'sample_image_5'
    ];
  }

  aboutToAppear() {
    // 组件出现时，初始化加载年份数据
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
          // 使用 ViewModel 中的 yearList
          ForEach(this.tabHistoryViewModel.yearList, (year: number, index: number) => {
            ListItem() {
              this.YearTimelineItem({
                year: year,
                isFirst: index === 0,
                isLast: index === this.tabHistoryViewModel.yearList.length - 1
              } as TimelineItemParams)
            }
          })

          // 加载更多提示项 (参考 TabMainComponent)
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
            // 只有当 hasMoreData 为 true 时才显示提示
            .visibility(this.tabHistoryViewModel.hasMoreData ? Visibility.Visible : Visibility.None)
          }

        }
        .width('100%')
        .layoutWeight(1) // 占据剩余空间
        .scrollBar(BarState.Off)
        // 绑定滑动到底部事件
        .onReachEnd(() => {
          if (!this.tabHistoryViewModel.isLoadingMore && this.tabHistoryViewModel.hasMoreData) {
            console.info("history_reach_end_load")
            this.tabHistoryViewModel.loadNextPage(false);
          }
        })
      }
      .width('100%')
      .height('100%')

      // 添加 Loading 弹框层（参考 TabMainComponent）
      if (this.tabHistoryViewModel.isInitLoading) {
        // 半透明背景 + 居中圆形加载指示器
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

  // 时间轴项组件 (保持不变)
  @Builder
  YearTimelineItem(item: TimelineItemParams) {
    Row() {
      // 左侧时间轴区域
      Column() {
        // 时间轴竖线容器 - 使用绝对定位确保连线连续
        Column() {
          // 完整的竖线背景（贯穿整个区域）
          Column()
            .width(2)
            .height('100%')
            .backgroundColor('#E5E5E5') // 浅灰色背景线
            .alignSelf(ItemAlign.Center)
            .position({ x: 0, y: 0 })

          // 高亮的活动线段（根据位置调整）
          Column() {
            // 中间项：显示完整竖线
            Column()
              .width(2)
              .height('100%')
              .backgroundColor('#007DFF')
              .alignSelf(ItemAlign.Center)
          }
          .width(2)
          .height('100%')
          .alignSelf(ItemAlign.Center)

          // 年份圆点（在最上层）
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
      Text(item.year >= 0 ? `${item.year}年` : `${Math.abs(item.year)}年 BCE`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width(80)
        .textAlign(TextAlign.Center)

      // 右侧图片区域
      Column() {
        // 5张图片水平排列
        Row() {
          ForEach(this.generateSampleImages(), (image: string, imgIndex: number) => {
            Image($r('app.media.startIcon')) // 使用默认图片
              .width(48)
              .height(48)
              .backgroundColor('#F0F0F0')
              .borderRadius(4)
              .margin({ right: 5 })
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        // 年份描述文本
        Text(`公元${item.year >= 0 ? item.year : Math.abs(item.year)}年${item.year >= 0 ? '' : '前'}的代表性艺术作品`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 8 })
          .width('100%')
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