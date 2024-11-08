@Component
export struct PageTitleComponent {
  title: string = '标题'
  isShowRightIcon?: boolean = false
  rightIcon?: ResourceStr
  onRightIconClick?: () => void

  build() {
    Row() {
      Text(this.title)
        .fontSize(30)
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 15, bottom: 15 })
      Blank().layoutWeight(1)
      if (this.isShowRightIcon) {
        Image(this.rightIcon)
          .width(28)
          .objectFit(ImageFit.Cover)
          .height(28)
          .onClick(() => {
            this.onRightIconClick?.()
          })
      }


    }.width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: 20, right: 20 })
  }
}