import { FeatureUtils, PageTitleComponent } from "lib_components"
import { router } from "@kit.ArkUI"
import { SettingItemComponent } from "./SettingItemComponent"
import { ToolsListBean } from "../model/ToolsListBean"
import { ToolsPage } from "./ToolsPage"
import mSettingViewModel from "../viewmodel/SettingViewModel"
import { RouterUtil, ToastUtil } from "utils"

@Entry({ routeName: 'SettingPage' })
@Component
export struct SettingPage {
  @State toolsList: Array<ToolsListBean> = []

  static startPage() {
    RouterUtil.pushNamedRoute('SettingPage')
  }

  build() {
    Column() {
      PageTitleComponent({
        title: '设置',
        isShowLeftIcon: true,
        onLeftIconClick: () => {
          router.back()
        }
      })
      Column({ space: 10 }) {
        SettingItemComponent({
          title: '工具',
          onItemClick: () => {
            this.startToolsPage()
          }
        })
      }.layoutWeight(1)
    }
    .width('100%')
    .backgroundColor(FeatureUtils.getGrayBgColor())
    .height('100%')
  }

  private startToolsPage() {
    if (this.toolsList.length > 0) {
      ToolsPage.startPage(this.toolsList)
    } else {
      mSettingViewModel.getToolsListData()
        .then((data: Array<ToolsListBean>) => {
          this.toolsList = data
          this.startToolsPage()
        })
        .catch((msg: string) => {
          ToastUtil.showToast(msg)
        })
    }
  }
}