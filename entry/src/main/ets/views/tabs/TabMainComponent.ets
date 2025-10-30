import TabMainViewModel from "../../viewModel/TodoListViewModel";

import { ThingViewModel } from "../../viewModel/ThingViewModel";

@Component
export struct TabMainComponent {
  @Link todoListViewModel: TabMainViewModel;

  aboutToAppear() {
    this.todoListViewModel.loadArtworks();
  }
  build() {
    Stack() { // ✅ 使用 Stack 让 Loading 层叠在列表上
      Column() {
        if (!this.todoListViewModel.isInitLoading) {

          // 艺术品列表
          List() {
            ListItem() {
              Text('Pocket Art')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .width('100%')
                .margin({ top: 20, bottom: 20 })
            }
            ForEach(this.todoListViewModel.things, (item: ThingViewModel, index: number) => {
              ListItem() {
                Row() {
                  Image(item.artwork.primaryImageSmall || $r('app.media.startIcon'))
                    .width(80)
                    .height(80)
                    .margin({ left: 20, right: 20 })

                  Text(item.artwork.title)
                    .fontSize(18)
                    .fontWeight(500)
                    .padding({ right: 10 }) // 添加右侧间距
                    .layoutWeight(1) // 让文本占据剩余空间
                }
                .width('100%')
                .height(160)
                .borderRadius(12)
                .backgroundColor(Color.White)
                .shadow({ radius: 8, color: '#1A000000', offsetX: 2, offsetY: 4 })
              }
              .margin({ top: 8, bottom: 8 })
            })

            // 加载更多提示项
            ListItem() {
              Row()
              {
                if (this.todoListViewModel.isLoadingMore) {
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
              .visibility(this.todoListViewModel.hasMoreData ? Visibility.Visible : Visibility.None)
            }
          }.onReachEnd(() => {
            this.todoListViewModel.loadNextPage(false);
          })
        }
      }

      // ✅ Loading 弹框层（条件渲染）
      if (this.todoListViewModel.isInitLoading) {
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
}