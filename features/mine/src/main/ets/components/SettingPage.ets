import { CommonPageTitle, FeatureUtils, PageTitleComponent } from "lib_components"
import { router } from "@kit.ArkUI"
import { SettingItemComponent } from "./SettingItemComponent"
import { ToolsListBean } from "../model/ToolsListBean"
import { ToolsPage } from "./ToolsPage"
import mSettingViewModel from "../viewmodel/SettingViewModel"
import { AppConstant, EmitterUtils, PreferenceManager, RouterUtil, setHeader, ToastUtil } from "utils"

@Component
struct SettingPage {
  @State toolsList: Array<ToolsListBean> = []
  navPathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
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
        .margin({ top: 15 })
      }
      .width('100%')
      .backgroundColor(FeatureUtils.getGrayBgColor())
      .height('100%')
    }
    .mode(NavDestinationMode.STANDARD)
    .title(CommonPageTitle('设置'))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context?.pathStack
    })
    .padding({
      top: AppStorage.get<number>('statusBarHeight'),
      bottom: AppStorage.get<number>('naviIndicatorHeight')
    })
  }

  private handleLogout() {
    mSettingViewModel.handleLogout()
      .then((data: string) => {
        ToastUtil.showToast(data)
        PreferenceManager.getInstance().deleteValue(AppConstant.KEY_USER_ID)
        PreferenceManager.getInstance().deleteValue(AppConstant.KEY_NICKNAME)
        PreferenceManager.getInstance().deleteValue(AppConstant.COOKIE)
        PreferenceManager.getInstance().setValue(AppConstant.KEY_IS_LOGIN, false)
        setHeader('cookie', '')
        AppConstant.ID = ''
        AppConstant.isLogin = false
        this.navPathStack.clear()
        EmitterUtils.getInstance().post(AppConstant.FLAG_LOGOUT_SUCCESS)
      })
      .catch((msg: string) => {
        ToastUtil.showToast(msg)
      })
  }

  private startToolsPage() {
    if (this.toolsList.length > 0) {
      this.navPathStack.pushPathByName('ToolsPage', new Object({
        "toolsList": this.toolsList
      }))
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

@Builder
export function SettingPageBuilder() {
  SettingPage()
}