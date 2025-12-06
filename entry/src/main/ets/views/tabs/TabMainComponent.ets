import TabMainViewModel from "../../viewModel/TabMainViewModel";
import { Artwork, OneArtworkViewModel } from "../../viewModel/OneArtworkViewModel";
import router from '@ohos.router'; // 导入 router 模块
import { promptAction } from '@kit.ArkUI'; // ✅ 导入 promptAction 用于显示弹框


@Component
export struct TabMainComponent {
  @Link todoListViewModel: TabMainViewModel;

  aboutToAppear() {
    this.todoListViewModel.loadArtworks();
  }

  // ✅ 定义弹窗内容
  private readonly DIALOG_TITLE: string = 'Data Source Statement';
  private readonly DIALOG_MESSAGE: string = `This is a personal learning project that showcases open access artworks from The Metropolitan Museum of Art's collection. This application utilizes The Met's public API to display art pieces for educational and non-commercial purposes only.

This project uses The Metropolitan Museum of Art's Collection API:
API Documentation: https://metmuseum.github.io/
Official Website: https://www.metmuseum.org/

Usage Restrictions:
Users of this application must adhere to The Metropolitan Museum of Art's terms and conditions:
Terms of Use: https://www.metmuseum.org/policies/terms-and-conditions

Disclaimer:
This application is not affiliated with, endorsed by, or connected to The Metropolitan Museum of Art. All artwork rights remain with their respective copyright holders as specified by The Met's Open Access policy.`;

  build() {
    Stack() { //使用 Stack 让 Loading 层叠在列表上
      Column() {
        if (!this.todoListViewModel.isInitLoading) {

          // 艺术品列表
          List() {
            ListItem() {
              Text('')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .width('100%')
                .margin({ top: 20, bottom: 20 })
            }

            // ✅ 新增：信息提示条
            ListItem() {
              Row() {
                Text('Data Source Statement')
                  .fontSize(12)
                  .fontColor('#007DFF') // 蓝色，表示可点击
                  .textAlign(TextAlign.Center)
                  .width('100%')
              }
              .height(30)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                promptAction.showDialog({
                  title: this.DIALOG_TITLE,
                  message: this.DIALOG_MESSAGE,
                  buttons: [
                    {
                      text: 'OK',
                      color: '#007DFF'
                    }
                  ]
                });
              })
            }
            // --- 保持原有的输入框和搜索按钮 ---
            ListItem() {
              Row() {
                // 输入框 - 使用 layoutWeight 自动填充剩余空间
                TextInput({ placeholder: "Enter the artwork name" })
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
                  Image(item.artwork.primaryImageSmall || $r('app.media.no_img'))
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
              .onClick(() => {
                this.gotoDetail(item.artwork);
              })
            })

            // 加载更多提示项
            ListItem() {
              Row()
              {
                if (this.todoListViewModel.isLoadingMore) {
                  LoadingProgress()
                    .width(30)
                    .height(30)
                  Text('Loading...')
                    .margin({ left: 8 })
                } else {
                  Text('Pull up to load more')
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
            Text('Loading...')
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

  gotoDetail(artwork: Artwork) {
    router.pushUrl({
      url: 'pages/ArtworkDetailComponent', // 新增的详情页路径
      params: {
        // 传入完整的艺术品详情对象
        artwork: artwork as Artwork
      }
    })
      .then(() => {
        console.info(`Mapsd to detail for objectID: ${artwork.objectID}`);
      })
      .catch((err: Error) => {
        console.error(`Navigation failed: ${err.message}`);
      });
  }
}