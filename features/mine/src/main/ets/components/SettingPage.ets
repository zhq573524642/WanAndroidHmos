import { FeatureUtils, PageTitleComponent } from "lib_components"
import { router } from "@kit.ArkUI"
import { SettingItemComponent } from "./SettingItemComponent"
import { ToolsListBean } from "../model/ToolsListBean"
import { ToolsPage } from "./ToolsPage"
import mSettingViewModel from "../viewmodel/SettingViewModel"
import { AppConstant, EmitterUtils, PreferenceManager, RouterUtil, setHeader, ToastUtil } from "utils"

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
        Blank().layoutWeight(1)
        Button('退出登录')
          .backgroundColor($r('app.color.color_login_theme'))
          .fontColor(Color.White)
          .margin({ bottom: 30 })
          .fontSize(14)
          .width('80%')
          .onClick(() => {
            AlertDialog.show({
              title: '温馨提示',
              subtitle: '确定要退出登录？',
              message: '退出登录用户信息将被清除',
              primaryButton: {
                value: '取消',
                action: () => {

                }
              },
              secondaryButton: {
                value: '确定',
                action: () => {
                  this.handleLogout()
                }
              }
            })
          })
      }.layoutWeight(1)
    }
    .width('100%')
    .backgroundColor(FeatureUtils.getGrayBgColor())
    .height('100%')
  }

  private handleLogout() {
    mSettingViewModel.handleLogout()
      .then((data: string) => {
        ToastUtil.showToast(data)
        PreferenceManager.getInstance().deleteValue(AppConstant.KEY_USER_ID)
        PreferenceManager.getInstance().deleteValue(AppConstant.KEY_NICKNAME)
        PreferenceManager.getInstance().deleteValue(AppConstant.COOKIE)
        setHeader('cookie', '')
        AppConstant.ID = ''
        router.clear()
        router.pushUrl({
          url: 'pages/Index'
        })
        EmitterUtils.getInstance().post(AppConstant.FLAG_LOGOUT_SUCCESS)
      })
      .catch((msg: string) => {
        ToastUtil.showToast(msg)
      })
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