import { BreakpointSystem, BreakpointTypeEnum } from 'utils/src/main/ets/utils/BreakpointSystem';
import { CustomTabBar } from '../components/CustomTabBar';
import { AppConstants } from '../constants/AppConstants';
import { TabBarType } from '../model/TabBarModel';
import { HomePage } from 'home/src/main/ets/components/HomePage'
import { HarmonyPage } from 'hmos/src/main/ets/components/HarmonyPage';
import { MinePage } from 'mine';
import { QuestionsPage } from 'questions'
import { AppConstant, EmitterUtils, PreferenceManager, RouterNameUtils, RouterUtil, setHeader, ToastUtil } from 'utils';
import { emitter } from '@kit.BasicServicesKit';
import { LoginPage } from 'login';
import { HotProjectPage } from 'project/src/main/ets/components/HotProjectPage';

@Entry
@Component
struct Index {
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @Provide('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Provide('homePathStack') homePathStack: NavPathStack = new NavPathStack()
  @Provide('ProjectPathStack') projectPathStack: NavPathStack = new NavPathStack()
  @Provide('minePathStack') minePathStack: NavPathStack = new NavPathStack()
  @Provide('questionsPathStack') questionsPathStack: NavPathStack = new NavPathStack()
  @State currentIndex: TabBarType = TabBarType.HOME
  tabsController: TabsController = new TabsController()

  aboutToAppear(): void {
    this.initUserInfo()
    this.breakpointSystem.register()
    EmitterUtils.getInstance().on(AppConstant.FLAG_NO_LOGIN, (eventData: emitter.EventData) => {
      ToastUtil.showCenterToast('请您先登录')
      RouterUtil.pushNamedRouteSingle(RouterNameUtils.PAGE_LOGIN)
    })

    EmitterUtils.getInstance().on(AppConstant.FLAG_LOGOUT_SUCCESS, (eventData: emitter.EventData) => {
      this.currentIndex = TabBarType.HOME
      this.tabsController.changeIndex(TabBarType.HOME)
    })
  }

  aboutToDisappear(): void {
    EmitterUtils.getInstance().unregister(AppConstant.FLAG_NO_LOGIN)
    EmitterUtils.getInstance().unregister(AppConstant.FLAG_LOGOUT_SUCCESS)
    this.breakpointSystem.unregister()
  }

  private initUserInfo() {
    PreferenceManager.getInstance().getValue<string[]>(AppConstant.COOKIE)
      .then((value: string[] | null) => {
        if (value !== null) {
          let s = ''
          value.forEach((cookie: string) => {
            s += cookie + ';'
          })
          setHeader('cookie', s)
        }
      })
    PreferenceManager.getInstance().getValue<string>(AppConstant.KEY_USERNAME)
      .then((value: string | null) => {
        if (value !== null && value.length > 0) {
          AppConstant.USERNAME = value
        }
      })
    PreferenceManager.getInstance().getValue<string>(AppConstant.KEY_USER_ID)
      .then((value: string | null) => {
        if (value !== null && value.length > 0) {
          AppConstant.ID = value
        }
      })
    PreferenceManager.getInstance().getValue<string>(AppConstant.KEY_NICKNAME)
      .then((value: string | null) => {
        if (value !== null && value.length > 0) {
          AppConstant.NICKNAME = value
        }
      })
  }

  build() {
    Navigation(this.appPathStack) {
      Stack() {
        Flex({
          direction: this.currentBreakpoint === BreakpointTypeEnum.LG ? FlexDirection.RowReverse : FlexDirection.Column,
        }) {
          Tabs({ index: this.currentIndex, controller: this.tabsController }) {
            TabContent() {
              HomePage()
            }

            TabContent() {
              HarmonyPage()
            }


            TabContent() {
              HotProjectPage()
            }

            TabContent() {
              QuestionsPage()
            }

            TabContent() {
              MinePage()
            }

          }
          .layoutWeight(1)
          .barHeight(0)
          .scrollable(false)
          .onChange((index) => {
            this.currentIndex = index;
          })

          CustomTabBar({ currentIndex: $currentIndex })
        }
        .width(AppConstants.FULL_PERCENT)
        .height(AppConstants.FULL_PERCENT)
        .backgroundColor((this.currentBreakpoint === BreakpointTypeEnum.LG && this.currentIndex === TabBarType.MINE) ?
        $r('app.color.clear_color') : $r('sys.color.ohos_id_color_sub_background'))
      }
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
  }
}