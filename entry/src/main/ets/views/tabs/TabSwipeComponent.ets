import SwipeViewModel from "../../viewModel/SwipeViewModel";
import { Artwork } from "../../viewModel/OneArtworkViewModel";

@Component
export struct TabSwipeComponent {
  @Link swipeViewModel: SwipeViewModel;

  // 手势与动画状态
  @State private startY: number = 0;
  @State private currentOffsetY: number = 0; // ⭐️ 统一使用这个变量控制偏移
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
    // ⭐️ 移除之前的 offset 同步逻辑，因为现在只有一个变量
  }

  // 触摸移动（跟手逻辑）
  private handleTouchMove(event: TouchEvent) {
    if (!this.isSwiping || this.swipeViewModel.isLoading || this.containerHeight === 0) return;

    const currentY = event.touches[0].y;
    let deltaY = currentY - this.startY;

    // 边界阻尼
    if (deltaY > 0 && !this.swipeViewModel.canSwipePrevious) {
      deltaY = deltaY * 0.3; // 阻尼效果
    } else if (deltaY < 0 && !this.swipeViewModel.canSwipeNext) {
      deltaY = deltaY * 0.3;
    }

    // ⭐️ 直接更新 currentOffsetY，视图会实时跟随
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
    if (this.currentOffsetY < -threshold && this.swipeViewModel.canSwipeNext) {
      // 上滑 -> 下一张
      targetOffset = -this.containerHeight;
      willChangeIndex = true;
    } else if (this.currentOffsetY > threshold && this.swipeViewModel.canSwipePrevious) {
      // 下滑 -> 上一张
      targetOffset = this.containerHeight;
      willChangeIndex = true;
    } else {
      // 回弹：目标是回到 0
      targetOffset = 0;
      willChangeIndex = false;
    }

    // ⭐️ 执行动画：currentOffsetY 从当前位置平滑过渡到 targetOffset
    animateTo({
      duration: 300,
      curve: Curve.FastOutSlowIn,
      onFinish: () => {
        if (willChangeIndex) {
          // 只有切换了卡片，才通知 ViewModel 更新数据
          if (targetOffset < 0) {
            this.swipeViewModel.currentArtwork = this.swipeViewModel.nextArtwork//避免闪烁上一张图
            setTimeout(() => {//避免闪烁上一张图
              this.swipeViewModel.confirmSwipeToNext();
              // 数据更新后，瞬间将偏移量重置为 0（新卡片归位）
              this.currentOffsetY = 0;
            }, 100);

          } else {
            this.swipeViewModel.currentArtwork = this.swipeViewModel.prevArtwork//避免闪烁上一张图
            setTimeout(() => {//避免闪烁上一张图
              this.swipeViewModel.confirmSwipeToPrevious();
              // 数据更新后，瞬间将偏移量重置为 0（新卡片归位）
              this.currentOffsetY = 0;
            }, 100);
          }
        }

      }
    }, () => {
      // ⭐️ 在动画闭包中设置目标值
      this.currentOffsetY = targetOffset;
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 主要内容区域
      this.buildContent()

      // 辅助层
      this.buildLoadingIndicator()
      this.buildErrorTip()
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
            buildSingleArtwork({artwork : this.swipeViewModel.prevArtwork.artwork})
          }
          .width('100%')
          .height('100%')
          .offset({ y: -this.containerHeight })
        }

        // 2. 当前张（Offset: 0）
        if (this.swipeViewModel.currentArtwork) {
          buildSingleArtwork({artwork : this.swipeViewModel.currentArtwork.artwork})
        } else {
          // 占位
          Stack()
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Black)
        }

        // 3. 下一张（Offset: +Height）
        if (this.swipeViewModel.nextArtwork && this.swipeViewModel.nextArtwork.artwork.primaryImageSmall) {
          Stack() {
            buildSingleArtwork({artwork : this.swipeViewModel.nextArtwork.artwork})
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
      // ⭐️ 修复点：只使用 currentOffsetY 一个变量控制偏移
      .offset({ y: this.currentOffsetY })
    }
    .width('100%')
    .height('100%')
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) this.handleTouchStart(event);
      else if (event.type === TouchType.Move) this.handleTouchMove(event);
      else if (event.type === TouchType.Up || event.type === TouchType.Cancel) this.handleTouchEnd();
    })
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

}

// 封装单个艺术品视图
@Component
struct buildSingleArtwork {
  @Prop artwork: Artwork
  build(){
    Stack({ alignContent: Alignment.BottomStart }) {
      if (this.artwork.primaryImageSmall) {
        Image(this.artwork.primaryImageSmall)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .interpolation(ImageInterpolation.High)
          .renderMode(ImageRenderMode.Original)
      } else {
        Stack().width('100%').height('100%').backgroundColor(Color.Black)
      }

      Column({ space: 8 }) {
        Text(this.artwork.title || '未知标题')
          .fontSize(20).fontColor(Color.White).fontWeight(FontWeight.Bold)
          .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).textAlign(TextAlign.Start)

        Text(this.artwork.artistDisplayName || '未知艺术家')
          .fontSize(16).fontColor(Color.White).opacity(0.9)

        Text(this.artwork.objectDate || '未知年代')
          .fontSize(14).fontColor(Color.White).opacity(0.7)
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 40 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.End)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}