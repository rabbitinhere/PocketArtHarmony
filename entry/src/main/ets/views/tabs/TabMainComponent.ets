import TodoListViewModel from "../../viewModel/TodoListViewModel";

import { ThingViewModel } from "../../viewModel/ThingViewModel";

@Component
export struct TabMainComponent {
  @Link todoListViewModel: TodoListViewModel;
  aboutToAppear() {
    this.todoListViewModel.loadArtworks();
  }
  build() {
    Stack() { // ✅ 使用 Stack 让 Loading 层叠在列表上
      Column() {


        if (!this.todoListViewModel.isLoading) {

          // 艺术品列表
          List() {
            ListItem() {
              Text('掌上艺术馆')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .width('100%')
                .margin({ top: 20, bottom: 20 })
            }
            ForEach(this.todoListViewModel.things, (item: ThingViewModel, index: number) => {
              ListItem() {
                Row() {
                  Image($r('app.media.startIcon'))
                    .width(80)
                    .height(80)
                    .margin({ left: 20, right: 20 })

                  Text(item.artwork.title)
                    .fontSize(18)
                    .fontWeight(500)
                }
                .width('100%')
                .height(160)
                .borderRadius(12)
                .backgroundColor(Color.White)
                .shadow({ radius: 8, color: '#1A000000', offsetX: 2, offsetY: 4 })
              }
              .margin({ top: 8, bottom: 8 })
            })
          }
        }
      }

      // ✅ Loading 弹框层（条件渲染）
      if (this.todoListViewModel.isLoading) {
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