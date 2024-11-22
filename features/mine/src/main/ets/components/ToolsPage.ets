import { ToolsListBean } from "../model/ToolsListBean"
import { SettingItemComponent } from "./SettingItemComponent"
import { WebViewPage } from "lib_components/src/main/ets/components/WebViewPage"
import { CommonPageTitle, FeatureUtils } from "lib_components"

@Component
export struct ToolsPage {
  scroller: Scroller = new Scroller()
  @State toolsList: Array<ToolsListBean> = []
  navPathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
        List({ scroller: this.scroller }) {
          ForEach(this.toolsList, (item: ToolsListBean,index:number) => {
            ListItem() {
              SettingItemComponent({
                title: item.name,
                subTitle: item.desc,
                onItemClick: () => {
                  WebViewPage.startPage(this.navPathStack,item.link, true, item.name)
                }
              })
            }.margin({ top: index == 0 ? 16 : 8, bottom: 8 })
          }, (item: ToolsListBean) => item.id + '')
        }.layoutWeight(1)
        .alignListItem(ListItemAlign.Center)
      }.width('100%')
      .height('100%')
      .backgroundColor(FeatureUtils.getGrayBgColor())
    }.title(CommonPageTitle('工具'))
    .mode(NavDestinationMode.STANDARD)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context?.pathStack
      let params = context?.pathInfo?.param as Record<string, Object>
      if (params) {
        this.toolsList = params.toolsList as Array<ToolsListBean>
      }
    })
    .padding({
      top: AppStorage.get<number>('statusBarHeight'),
      bottom: AppStorage.get<number>('naviIndicatorHeight')
    })
  }
}

@Builder
export function ToolsPageBuilder() {
  ToolsPage()
}