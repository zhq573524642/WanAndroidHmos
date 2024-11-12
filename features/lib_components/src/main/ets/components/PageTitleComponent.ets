@Component
export struct PageTitleComponent {
  title: string = '标题'
  titleFontSize?: ResourceStr | number = 30
  isShowLeftIcon?: boolean = false
  isShowRightIcons?: boolean = false
  isShowRightTexts?: boolean = false
  rightIcons?: ResourceStr[]=[]
  rightTexts?: ResourceStr[] = []
  onLeftIconClick?: () => void
  onRightIconClick?: (icon:ResourceStr,index:number) => void
  onRightTextClick?: (title: ResourceStr, index: number) => void
  @BuilderParam onCustomRightView?: () => void

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
      if (this.onCustomRightView) {
        this.onCustomRightView()
      } else {
        if (this.isShowRightTexts) {
          ForEach(this.rightTexts, (value: ResourceStr, index: number) => {
            Text(value)
              .fontColor(Color.Blue)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .margin({ left: 12 })
              .onClick(() => {
                this.onRightTextClick?.(value, index)
              })
          }, (value: string) => value)
        }
        if (this.isShowRightIcons) {
          ForEach(this.rightIcons, (value: ResourceStr, index: number) => {
            Image(value)
              .width(28)
              .objectFit(ImageFit.Cover)
              .height(28)
              .margin({ left: 12 })
              .onClick(() => {
                this.onRightIconClick?.(value,index)
              })
          }, (value: ResourceStr) => value.toString())

        }
      }


    }.width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: 20, right: 20 })
  }
}