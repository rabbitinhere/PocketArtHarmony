import SwipeViewModel from "../../viewModel/SwipeViewModel";

@Component
export struct TabSwipeComponent {
  @Link swipeViewModel: SwipeViewModel;

  // 手势相关状态
  @State private startY: number = 0;
  @State private currentOffsetY: number = 0;
  @State private isSwiping: boolean = false;

  aboutToAppear() {
    this.swipeViewModel.initialize();
  }

  // 处理触摸开始
  private handleTouchStart(event: TouchEvent) {
    if (this.swipeViewModel.isLoading) return;

    this.startY = event.touches[0].y;
    this.isSwiping = true;
    this.currentOffsetY = 0;
  }

  // 处理触摸移动
  private handleTouchMove(event: TouchEvent) {
    if (!this.isSwiping || this.swipeViewModel.isLoading) return;

    const currentY = event.touches[0].y;
    this.currentOffsetY = currentY - this.startY;
  }

  // 处理触摸结束
  private handleTouchEnd() {
    if (!this.isSwiping || this.swipeViewModel.isLoading) return;

    this.isSwiping = false;

    // 滑动距离阈值
    const threshold = 100;

    if (this.currentOffsetY < -threshold) {
      console.info("ra_todo 上滑")
      // 上滑 - 下一张
      this.swipeViewModel.swipeToNext();
    } else if (this.currentOffsetY > threshold && this.swipeViewModel.canSwipePrevious) {
      console.info("ra_todo 下滑")
      // 下滑 - 上一张
      this.swipeViewModel.swipeToPrevious();
    }

    this.currentOffsetY = 0;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 主要内容区域
      this.buildContent()

      // 加载指示器
      this.buildLoadingIndicator()

      // 错误提示
      this.buildErrorTip()

      // 操作提示
      this.buildSwipeHint()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  // 构建内容区域
  @Builder
  buildContent() {
    Column() {
      if (this.swipeViewModel.currentArtwork) {
        // 艺术品图片
        Image(this.swipeViewModel.currentArtwork.artwork.primaryImageSmall)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .interpolation(ImageInterpolation.High) // 高质量插值
          .renderMode(ImageRenderMode.Original) // 原图渲染

        // 艺术品信息遮罩
        this.buildArtworkInfo()
      } else {
        // 无数据时的占位图
        Image($r('app.media.startIcon'))
          .width(120)
          .height(120)
          .objectFit(ImageFit.Contain)
          .opacity(0.5)
      }
    }
    .width('100%')
    .height('100%')
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.handleTouchStart(event);
      } else if (event.type === TouchType.Move) {
        this.handleTouchMove(event);
      } else if (event.type === TouchType.Up) {
        this.handleTouchEnd();
      }
    })
  }

  // 构建艺术品信息遮罩
  @Builder
  buildArtworkInfo() {
    Column({ space: 8 }) {
      if (this.swipeViewModel.currentArtwork) {
        Text(this.swipeViewModel.currentArtwork.artwork.title || '未知标题')
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)

        Text(this.swipeViewModel.currentArtwork.artwork.title || '未知标题')
          .fontSize(16)
          .fontColor(Color.White)
          .opacity(0.9)

        Text(this.swipeViewModel.currentArtwork.artwork.title || '未知标题')
          .fontSize(14)
          .fontColor(Color.White)
          .opacity(0.7)
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 40 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.End)
    .height('100%')
    .backgroundBlurStyle(BlurStyle.Thin)
    .backdropBlur(10)
    .linearGradient({
      angle: 180,  // 修正：去掉引号，使用数字
      colors: [[0x00000000, 0x00000080], [0x00000080, 0x000000E6]]  // 修正：使用16进制数字
    })
  }
  // 构建加载指示器
  @Builder
  buildLoadingIndicator() {
    if (this.swipeViewModel.isLoading) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
          .color(Color.White)

        Text('加载中...')
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ top: 12 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#00000040')
    }
  }

  // 构建错误提示
  @Builder
  buildErrorTip() {
    if (this.swipeViewModel.errorMessage) {
      Column() {
        Text(this.swipeViewModel.errorMessage)
          .fontSize(16)
          .fontColor(Color.White)
          .padding(16)
          .backgroundColor('#FF000080')
          .borderRadius(8)

        Button('重试')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#007DFF')
          .padding({ left: 24, right: 24, top: 8, bottom: 8 })
          .margin({ top: 12 })
          .borderRadius(20)
          .onClick(() => {
            this.swipeViewModel.initialize();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }

  // 构建滑动提示
  @Builder
  buildSwipeHint() {
    if (!this.swipeViewModel.isLoading &&
      !this.swipeViewModel.errorMessage &&
    this.swipeViewModel.currentArtwork) {

      Column() {
        Text('上滑查看下一张 • 下滑回到上一张')
          .fontSize(14)
          .fontColor(Color.White)
          .opacity(0.8)
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .backgroundColor('#00000060')
          .borderRadius(20)
      }
      .width('100%')
      .margin({ top: 60 })
      .alignItems(HorizontalAlign.Center)
    }
  }
}