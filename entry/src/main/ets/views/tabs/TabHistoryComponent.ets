import TabHistoryViewModel from "../../viewModel/TabHistoryViewModel";
import { OneArtworkViewModel } from "../../viewModel/OneArtworkViewModel";

interface TimelineItemParams {
  year: number;
  isFirst: boolean;
  isLast: boolean;
}

@Component
export struct TabHistoryComponent {
  @Link tabHistoryViewModel: TabHistoryViewModel;

  // 测试数据：从2000年到-2000年，每100年一个间隔
  private yearList: number[] = this.generateYearList();

  // 生成年份列表：2000, 1900, 1800, ... , -2000
  private generateYearList(): number[] {
    const years: number[] = [];
    for (let year = 2000; year >= -2000; year -= 100) {
      years.push(year);
    }
    return years;
  }

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
          ForEach(this.yearList, (year: number, index: number) => {
            ListItem() {
              this.YearTimelineItem({
                year: year,
                isFirst: index === 0,
                isLast: index === this.yearList.length - 1
              } as TimelineItemParams)
            }
          })
        }
        .width('100%')
        .layoutWeight(1) // 占据剩余空间
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
    }
  }

  // 时间轴项组件 - 修正时间轴连线问题
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