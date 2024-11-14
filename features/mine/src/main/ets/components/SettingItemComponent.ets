@Component
export struct SettingItemComponent {
  title: string = ''
  subTitle: string = ''
  onItemClick?: () => void

  build() {
    Row() {
      Column({ space: 8 }) {
        Text(this.title).fontColor(Color.Black).fontSize(14)
        if (this.subTitle !== '') {
          Text(this.subTitle).fontColor(Color.Gray).fontSize(12)
        }
      }.alignItems(HorizontalAlign.Start)

      Blank().layoutWeight(1)
      Image($r('app.media.ic_into_black')).width(25).height(25)
    }
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .padding({
      left: 20,
      right: 20,
      top: 12,
      bottom: 12
    })
    .width('95%')
    .borderRadius(10)
    .onClick(() => {
      this.onItemClick?.()
    })
  }
}