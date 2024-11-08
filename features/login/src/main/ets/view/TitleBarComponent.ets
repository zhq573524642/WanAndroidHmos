@Component
export struct TitleBarComponent {
  @Prop navIcon: ResourceStr
  @Prop navTitle: string
  onNavBackCallback?: () => void

  build() {
    Column({ space: 40 }) {
      Image(this.navIcon)
        .objectFit(ImageFit.Fill)
        .width(20)
        .height(20)
        .onClick(() => {
          this.onNavBackCallback?.()
        })
      Text(this.navTitle)
        .fontColor(Color.Black)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
    }.margin({ left: 20, top: 30 })
    .alignItems(HorizontalAlign.Start)
  }
}