import { PageTitleComponent } from "lib_components/src/main/ets/components/PageTitleComponent"
import { router } from "@kit.ArkUI"
import { ToolsListBean } from "../model/ToolsListBean"
import { SettingItemComponent } from "./SettingItemComponent"
import { RouterUtil } from "utils"
import { WebViewPage } from "lib_components/src/main/ets/components/WebViewPage"
import { FeatureUtils } from "lib_components"

@Entry({ routeName: 'ToolsPage' })
@Component
export struct ToolsPage {
  scroller: Scroller = new Scroller()
  @State toolsList: Array<ToolsListBean> = []

  static startPage(toolsList: Array<ToolsListBean>) {
    RouterUtil.pushNamedRoute('ToolsPage', {
      "toolsList": toolsList
    })
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      this.toolsList = params.toolsList as Array<ToolsListBean>
    }
  }

  build() {
    Column() {
      PageTitleComponent({
        title: '工具',
        isShowLeftIcon: true,
        onLeftIconClick: () => {
          router.back()
        }
      })
      List({ scroller: this.scroller, space: 10 }) {
        ForEach(this.toolsList, (item: ToolsListBean) => {
          ListItem() {
            SettingItemComponent({
              title: item.name,
              subTitle: item.desc,
              onItemClick: () => {
                WebViewPage.startPage(item.link, true, item.name)
              }
            })
          }
        }, (item: ToolsListBean) => item.id + '')
      }.layoutWeight(1)
      .alignListItem(ListItemAlign.Center)
    }.width('100%')
    .height('100%')
    .backgroundColor(FeatureUtils.getGrayBgColor())
  }
}