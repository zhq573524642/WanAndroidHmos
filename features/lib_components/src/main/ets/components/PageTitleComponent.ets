@Component
export struct PageTitleComponent {
  title: string = '标题'
  titleFontSize?: ResourceStr | number = 30
  isShowLeftIcon?: boolean = false
  isShowRightIcon?: boolean = false
  isShowRightText?: boolean = false
  rightIcon?: ResourceStr
  rightText?: ResourceStr
  onLeftIconClick?: () => void
  onRightIconClick?: () => void
  onRightTextClick?: () => void

  build() {
    Row() {
      if (this.isShowLeftIcon) {
        Image($r('app.media.ic_back'))
          .width(30)
          .height(30)
          .objectFit(ImageFit.Fill)
          .margin({ right: 10 })
          .onClick(() => {
            this.onLeftIconClick?.()
          })
      }


      Text(this.title)
        .fontSize(this.titleFontSize)
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 15, bottom: 15 })
      Blank().layoutWeight(1)
      if (this.isShowRightText) {
        Text(this.rightText).fontColor(Color.Blue)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.onRightTextClick?.()
          })
      }
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