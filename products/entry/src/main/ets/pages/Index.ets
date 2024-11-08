import { BreakpointSystem, BreakpointTypeEnum } from 'utils/src/main/ets/utils/BreakpointSystem';
import { CustomTabBar } from '../components/CustomTabBar';
import { AppConstants } from '../constants/AppConstants';
import { TabBarType } from '../model/TabBarModel';
import { HomePage } from 'home/src/main/ets/components/HomePage'
import { HarmonyPage } from 'hmos/src/main/ets/components/HarmonyPage';
import { SystemsPage } from 'systems';
import { MinePage } from 'mine';
import { QuestionsPage } from 'questions'

@Entry
@Component
struct Index {
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @Provide('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Provide('homePathStack') homePathStack: NavPathStack = new NavPathStack()
  @Provide('minePathStack') minePathStack: NavPathStack = new NavPathStack()
  @Provide('questionsPathStack') questionsPathStack: NavPathStack = new NavPathStack()
  @State currentIndex: TabBarType = TabBarType.HOME

  aboutToAppear(): void {
    this.breakpointSystem.register()
  }

  aboutToDisappear(): void {
    this.breakpointSystem.unregister()
  }

  build() {
    Navigation(this.appPathStack) {
      Stack() {
        Flex({
          direction: this.currentBreakpoint === BreakpointTypeEnum.LG ? FlexDirection.RowReverse : FlexDirection.Column,
        }) {
          Tabs({ index: this.currentIndex }) {
            TabContent() {
              // HomePage()
            }

            TabContent() {
              HarmonyPage()
            }


            TabContent() {
              SystemsPage()
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