import SwipeViewModel from "../../viewModel/SwipeViewModel";
import { Artwork } from "../../viewModel/OneArtworkViewModel";

@Component
export struct TabSwipeComponent {
  @Link swipeViewModel: SwipeViewModel;

  // 手势与动画状态
  @State private startY: number = 0;
  @State private currentOffsetY: number = 0; // 手指拖动的实时偏移
  @State private animatedOffset: number = 0; // 动画的目标偏移
  @State private isSwiping: boolean = false;
  @State private containerHeight: number = 0; // 容器高度

  aboutToAppear() {
    this.swipeViewModel.initialize();
  }

  // 触摸开始
  private handleTouchStart(event: TouchEvent) {
    if (this.swipeViewModel.isLoading) return;
    this.startY = event.touches[0].y;
    this.isSwiping = true;

    // 停止之前的动画，从当前位置开始
    this.currentOffsetY = this.animatedOffset;
    this.animatedOffset = this.currentOffsetY;
  }

  // 触摸移动（跟手逻辑）
  private handleTouchMove(event: TouchEvent) {
    if (!this.isSwiping || this.swipeViewModel.isLoading || this.containerHeight === 0) return;

    const currentY = event.touches[0].y;
    let deltaY = currentY - this.startY;

    // 边界阻尼：【修复点 4】：直接使用 @Track 属性
    if (deltaY > 0 && !this.swipeViewModel.canSwipePrevious) {
      deltaY = deltaY * 0.3; // 阻尼效果
    } else if (deltaY < 0 && !this.swipeViewModel.canSwipeNext) {
      deltaY = deltaY * 0.3;
    }

    this.currentOffsetY = deltaY;
  }

  // 触摸结束（翻页判断）
  private handleTouchEnd() {
    if (!this.isSwiping || this.swipeViewModel.isLoading) return;
    this.isSwiping = false;

    const threshold = this.containerHeight / 4; // 滑动超过1/4屏幕则翻页
    let targetOffset = 0;
    let willChangeIndex = false;

    // 判断意图
    // 【修复点 5】：直接使用 @Track 属性
    if (this.currentOffsetY < -threshold && this.swipeViewModel.canSwipeNext) {
      // 上滑 -> 下一张
      targetOffset = -this.containerHeight;
      willChangeIndex = true;
    } else if (this.currentOffsetY > threshold && this.swipeViewModel.canSwipePrevious) {
      // 下滑 -> 上一张
      targetOffset = this.containerHeight;
      willChangeIndex = true;
    } else {
      // 回弹
      targetOffset = 0;
      willChangeIndex = false;
    }

    // 执行动画
    animateTo({
      duration: 300,
      curve: Curve.FastOutSlowIn,
      onFinish: () => {
        if (willChangeIndex) {
          if (targetOffset < 0) {
            this.swipeViewModel.confirmSwipeToNext();
          } else {
            this.swipeViewModel.confirmSwipeToPrevious();
          }
        }
        // 关键：数据切换后，瞬间重置偏移量到0
        this.currentOffsetY = 0;
        this.animatedOffset = 0;
      }
    }, () => {
      this.animatedOffset = targetOffset;
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 主要内容区域
      this.buildContent()

      // 辅助层
      this.buildLoadingIndicator()
      this.buildErrorTip()
      this.buildSwipeHint()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .onAreaChange((oldV, newV) => {
      this.containerHeight = newV.height as number;
    })
  }

  // 构建内容区域：包含 上一张、当前、下一张
  @Builder
  buildContent() {
    Column() {
      // 核心布局：Stack 包含三张图
      Stack({ alignContent: Alignment.TopStart }) {
        // 1. 上一张（Offset: -Height）
        if (this.swipeViewModel.prevArtwork) {
          Stack() {
            this.buildSingleArtwork(this.swipeViewModel.prevArtwork.artwork)
          }
          .width('100%')
          .height('100%')
          .offset({ y: -this.containerHeight })
        }

        // 2. 当前张（Offset: 0）
        if (this.swipeViewModel.currentArtwork) {
          this.buildSingleArtwork(this.swipeViewModel.currentArtwork.artwork)
        } else {
          // 占位
          Stack().width('100%').height('100%').backgroundColor(Color.Black)
        }

        // 3. 下一张（Offset: +Height）
        if (this.swipeViewModel.nextArtwork && this.swipeViewModel.nextArtwork.artwork.primaryImageSmall) { // 确保下一张有图片才渲染
          Stack() {
            this.buildSingleArtwork(this.swipeViewModel.nextArtwork.artwork)
          }
          .width('100%')
          .height('100%')
          .offset({ y: this.containerHeight })
        } else if (this.swipeViewModel.canSwipeNext) {
          // 下一张还没加载好时的占位
          Stack() {
            LoadingProgress().width(50).height(50).color(Color.White)
          }
          .width('100%').height('100%').backgroundColor(Color.Black)
          .offset({ y: this.containerHeight })
        }
      }
      .width('100%')
      .height('100%')
      // 整个容器跟随手指偏移（动画或手势）
      .offset({ y: this.animatedOffset !== 0 ? this.animatedOffset : this.currentOffsetY })
    }
    .width('100%')
    .height('100%')
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) this.handleTouchStart(event);
      else if (event.type === TouchType.Move) this.handleTouchMove(event);
      else if (event.type === TouchType.Up || event.type === TouchType.Cancel) this.handleTouchEnd();
    })
  }

  // 封装单个艺术品视图
  @Builder
  buildSingleArtwork(artwork: Artwork) {
    Stack({ alignContent: Alignment.BottomStart }) {
      // 【修复点 6】：检查 primaryImageSmall，确保 Image 路径有效，否则使用纯色背景
      if (artwork.primaryImageSmall) {
        Image(artwork.primaryImageSmall)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .interpolation(ImageInterpolation.High)
          .renderMode(ImageRenderMode.Original)
      } else {
        // 没有图片路径，显示黑色占位
        Stack().width('100%').height('100%').backgroundColor(Color.Black)
      }

      // 信息遮罩
      this.buildArtworkInfo(artwork)
    }
    .width('100%')
    .height('100%')
  }

  // ... (其他 Builder 保持不变)
  @Builder
  buildArtworkInfo(artwork: Artwork) {
    Column({ space: 8 }) {
      Text(artwork.title || '未知标题')
        .fontSize(20).fontColor(Color.White).fontWeight(FontWeight.Bold)
        .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).textAlign(TextAlign.Start)

      Text(artwork.title || '未知信息')
        .fontSize(16).fontColor(Color.White).opacity(0.9)

      Text(artwork.objectID.toString())
        .fontSize(14).fontColor(Color.White).opacity(0.7)
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 40 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.End)
    .height('100%')

  }

  @Builder
  buildLoadingIndicator() {
    if (this.swipeViewModel.isLoading && !this.swipeViewModel.currentArtwork) {
      Column() {
        LoadingProgress().width(40).height(40).color(Color.White)
        Text('加载中...').fontSize(16).fontColor(Color.White).margin({ top: 12 })
      }
      .width('100%').height('100%').justifyContent(FlexAlign.Center).backgroundColor('#00000040')
    }
  }

  @Builder
  buildErrorTip() {
    if (this.swipeViewModel.errorMessage) {
      Column() {
        Text(this.swipeViewModel.errorMessage).fontSize(16).fontColor(Color.White).padding(16).backgroundColor('#FF000080').borderRadius(8)
        Button('重试').fontSize(14).fontColor(Color.White).backgroundColor('#007DFF').margin({ top: 12 })
          .onClick(() => this.swipeViewModel.initialize())
      }
      .width('100%').height('100%').justifyContent(FlexAlign.Center)
    }
  }

  @Builder
  buildSwipeHint() {
    if (!this.swipeViewModel.isLoading && !this.swipeViewModel.errorMessage && this.swipeViewModel.currentArtwork) {
      Column() {
        Text('上滑查看更多').fontSize(12).fontColor(Color.White).opacity(0.6)
      }.width('100%').margin({ top: 60 }).alignItems(HorizontalAlign.Center)
    }
  }
}