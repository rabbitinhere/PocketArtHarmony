// ArtworkDetailComponent.ets

import router from '@ohos.router';
import { common } from '@kit.AbilityKit';
import { Artwork } from '../viewModel/OneArtworkViewModel';

interface DetailParams {
  artwork: Artwork;
}

@Entry // 标记为页面入口
@Component
export struct ArtworkDetailComponent {
  // 使用 @State 接收通过 router.pushUrl 传入的参数，提供默认值
  @State artwork: Artwork = {
    objectID: 0,
    title: '加载中...',
    primaryImage: '',
    primaryImageSmall: '',
    artistDisplayName: 'N/A',
    objectDate: 'N/A',
    medium: 'N/A',
    dimensions: 'N/A',
    culture: 'N/A',
    department: 'N/A',
  };


  aboutToAppear() {
    // 从路由参数中获取艺术品详情数据
    const params = router.getParams() as DetailParams | undefined;
    if (params && params.artwork) {
      // 使用扩展运算符或 Object.assign 确保属性完整
      this.artwork = params.artwork as Artwork;
      this.artwork = params.artwork as Artwork;
    } else {
      console.error('未接收到艺术品详情数据，将显示默认内容');
    }
  }

  build() {
    Column() {
      // 1. 全屏展示艺术品图片 (使用 primaryImage)
      Stack({ alignContent: Alignment.TopStart }) {
        Image(this.artwork.primaryImageSmall || '')
          .objectFit(ImageFit.Contain) // 确保图片完整显示
          .backgroundColor(Color.Black) // 图片背景
          .width('100%')
          .height('100%') // 占满 Stack 剩余空间

        // 返回按钮
        Button() {
          Image($r('app.media.ic_back')) // 假设你有一个返回图标
            .width(50)
            .height(50)
            .fillColor(Color.White)
        }
        .type(ButtonType.Circle)
        .width(50)
        .height(50)
        .backgroundColor('#00000080')
        .margin(20)
        .onClick(() => {
          router.back();
        })
      }
      .width('100%')
      .height('70%') // 图片区域占据 70% 垂直空间

      // 2. 底部文字介绍
      Scroll() {
        Column({ space: 10 }) {
          // 标题
          Text(this.artwork.title || '无标题')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
            .textAlign(TextAlign.Start)
            .width('100%')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 详情信息
          this.DetailRow('艺术家', this.artwork.artistDisplayName)
          this.DetailRow('创作日期', this.artwork.objectDate)
          this.DetailRow('媒介/材料', this.artwork.medium)
          this.DetailRow('尺寸', this.artwork.dimensions)
          this.DetailRow('文化', this.artwork.culture)
          this.DetailRow('部门', this.artwork.department)
          Text(`ID: ${this.artwork.objectID}`)
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')

          // 底部留白
          // Spacer().height(20)
        }
        .width('100%')
        .padding({ left: 15, right: 15, top: 15 })
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1) // 占据剩余 30% 空间
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%') // 全屏展示
    .backgroundColor(Color.White)
  }

  // 封装详情行
  @Builder DetailRow(label: string, value: string) {
    Row() {
      Text(`${label}: `)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
      Text(value || 'N/A')
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
  }
}