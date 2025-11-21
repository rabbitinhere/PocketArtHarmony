import TabMainViewModel from "../../viewModel/TabMainViewModel";
import { OneArtworkViewModel } from "../../viewModel/OneArtworkViewModel";

@Component
export struct TabMainComponent {
  @Link todoListViewModel: TabMainViewModel;

  aboutToAppear() {
    this.todoListViewModel.loadArtworks();
  }

  build() {
    Stack() { //使用 Stack 让 Loading 层叠在列表上
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
            ListItem() {

              Row() {
                // 输入框 - 使用 layoutWeight 自动填充剩余空间
                TextInput({ placeholder: "请输入艺术品名" })
                  .layoutWeight(1) // 占据剩余所有空间
                  .height(40)
                  .backgroundColor('#F0F0F0')
                  .padding(10)
                  .borderRadius(8)
                  .margin({ left: 10, right: 10 }) // 用右边距替代左侧的 margin
                  .onChange((value: string) => {
                    this.todoListViewModel.searchKeyword = value;
                  })

                // 搜索按钮 - 固定宽度
                Button('搜索')
                  .width(80) // 固定宽度
                  .height(40)
                  .backgroundColor('#007DFF')
                  .fontColor(Color.White)
                  .fontSize(16)
                  .borderRadius(8)
                  .onClick(() => {
                    this.todoListViewModel.searchArtworks();
                  }).margin({ right: 10 })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ bottom: 10 })
            }

            ForEach(this.todoListViewModel.things, (item: OneArtworkViewModel, index: number) => {
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
            if (!this.todoListViewModel.isLoadingMore && this.todoListViewModel.hasMoreData) {
              console.info("reach_end_load")
              this.todoListViewModel.loadNextPage(false);
            }
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