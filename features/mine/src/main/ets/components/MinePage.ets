import { BreakpointTypeEnum, RouterUtil } from 'utils'
import { CollectionsPage } from './CollectionsPage';
import { OfficialAccountsPage } from './OfficialAccountsPage';

import('login/src/main/ets/components/LoginPage');

@Component
export struct MinePage {
  @Consume('minePathStack') minePathStack: NavPathStack;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @State currentTabIndex: number = 0
  outScroller: Scroller = new Scroller()

  build() {

    Navigation(this.minePathStack) {
      Stack({ alignContent: Alignment.Top }) {
        // BackgroundImage view;
        if (this.currentBreakpoint !== BreakpointTypeEnum.LG) {
          this.MineBackGroundImage()
        }
        Column() {
          this.MineToolsView()
          Scroll(this.outScroller) {
            Column() {
              this.UserInfoView()
              this.MineTabView()
            }.width('100%')
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .layoutWeight(1)

      }
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }

  @Builder
  MineToolsView() {
    Row() {
      Blank().layoutWeight(1)
      Image($r('app.media.ic_integral'))
        .width(25)
        .height(25)
        .objectFit(ImageFit.Cover)
        .margin({ right: 20 })
      Image($r('app.media.ic_setting'))
        .width(25)
        .height(25)
        .objectFit(ImageFit.Cover)
        .margin({ right: 20 })
        .onClick(() => {
          RouterUtil.pushNamedRoute('LoginPage')
        })
    }.width('100%')
    .margin({ top: 10, bottom: 10 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  UserInfoView() {
    Column({ space: 12 }) {
      Image($r('app.media.ic_default_avatar'))
        .width(48)
        .height(48)
        .borderRadius(50)
        .borderWidth(2)
        .borderColor(Color.White)
      Text('用户xxxxxxx')
        .fontColor(Color.White)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
    }.alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({ left: 20, right: 20 })
    .margin({ top: 15 })
  }

  @Builder
  MineTabView() {
    Tabs({ index: this.currentTabIndex }) {
      TabContent() {
        CollectionsPage()
      }.tabBar(this.MineTabs(0, '收藏'))
      .backgroundColor($r('app.color.color_FAFAFA'))
      .padding({ top: 12 })

      TabContent() {
      }.tabBar(this.MineTabs(1, '问答'))
      .backgroundColor($r('app.color.color_FAFAFA'))
      .padding({ top: 12 })

      TabContent() {
        OfficialAccountsPage()
      }.tabBar(this.MineTabs(2, '公众号'))
      .backgroundColor($r('app.color.color_FAFAFA'))
      .padding({ top: 12 })
    }
    .backgroundColor(Color.White)
    .borderRadius({
      topLeft: 20,
      topRight: 20,
      bottomLeft: 0,
      bottomRight: 0
    })
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentTabIndex = index
    })
    .barWidth(200)
    .barHeight(56)
    .margin({ top: 65 })
    .onTabBarClick((index: number) => {
      this.currentTabIndex = index
    })
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  MineTabs(index: number, barName: ResourceStr) {
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

  @Builder
  MineBackGroundImage() {
    // background Image
    Column() {
      Image($r('app.media.ic_mine_bg'))
        .width('100%')
        .objectFit(ImageFit.Cover)
        .foregroundBlurStyle(BlurStyle.Thin,
          { colorMode: ThemeColorMode.DARK, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.04 })
    }
    .width('100%')
    .aspectRatio(16 / 9)
  }
}

