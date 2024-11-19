import { MessageListPage } from "./MessageListPage"

@Component
export struct MessagesPage {
  @State currentTabIndex: number = 0
  navPathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
        Tabs() {
          TabContent() {
            MessageListPage({
              isRead: false
            })
          }.tabBar(this.MessageTabs(0, '未读'))

          TabContent() {
            MessageListPage({
              isRead: true
            })
          }.tabBar(this.MessageTabs(1, '已读'))
        }
        .barMode(BarMode.Fixed)
        .barHeight(56)
        .layoutWeight(1)
        .onTabBarClick((index: number) => {
          this.currentTabIndex = index
        })
        .onChange((index: number) => {
          this.currentTabIndex = index
        })

      }.width('100%')
      .height('100%')
    }.title('消息')
    .mode(NavDestinationMode.STANDARD)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context?.pathStack

    })
  }

  @Builder
  MessageTabs(index: number, barName: ResourceStr) {
    Column() {
      Text(barName)
        .fontColor(index === this.currentTabIndex ? Color.Blue : Color.Gray)
        .fontWeight(index === this.currentTabIndex ? FontWeight.Medium : FontWeight.Normal)
        .fontSize(16)
        .margin({ top: 8, bottom: 5 })
      Divider()
        .strokeWidth(2)
        .lineCap(LineCapStyle.Round)
        .width(32)
        .color(index === this.currentTabIndex ? Color.Blue : Color.Transparent)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
  }
}

@Builder
export function MessagesPageBuilder() {
  MessagesPage()
}