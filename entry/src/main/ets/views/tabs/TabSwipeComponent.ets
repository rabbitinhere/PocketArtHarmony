import SwipeViewModel from "../../viewModel/SwipeViewModel";

@Component
export struct TabSwipeComponent {
  @Link swipeViewModel: SwipeViewModel;

  aboutToAppear() {
  }
  build() {
    Text('页面2')
      .fontSize(30)
      .fontWeight(FontWeight.Bold)
      .align(Alignment.Center)
  }
}