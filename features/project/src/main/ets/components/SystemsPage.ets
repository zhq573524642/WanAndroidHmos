import { BasePage } from 'commons'
import { DefaultStateEnum } from 'commons/src/main/ets/components/defaultState/DefaultStateEnum'
import { FooterLoadMoreStatus, HeaderRefreshStatus } from 'commons/src/main/ets/components/SVRefresh/SVRefresh'
import { ToastUtil } from 'utils/src/main/ets/utils/ToastUtil'
import { SystemChildrenList, SystemsListBean } from '../model/SystemsListBean'
import mSystemsViewModel from '../viewmodel/SystemsViewModel'
import { CommonPageTitle, FeatureUtils } from 'lib_components'
import { PreferenceManager, RouterUtil } from 'utils'
import { data } from '@kit.TelephonyKit'
import { BusinessError } from '@kit.BasicServicesKit'

@Component
export struct SystemsPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.hidden
  @State systemsList: Array<SystemsListBean> = []
  navPathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      Column() {
        BasePage({
          pageState: this.pageState,
          refreshStatus: this.refreshStatus,
          loadMoreStatus: this.loadMoreStatus,
          ContentViewPage: (_scroller: Scroller) => {
            this.ListView(_scroller)
          },
          onRefreshing: () => {
            this.getSystemsListData()
          }
        })
          .layoutWeight(1)

      }.width('100%')
      .height('100%')
      .backgroundColor(Color.White)
    }.mode(NavDestinationMode.STANDARD)
    .title(CommonPageTitle('体系'))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context?.pathStack
      PreferenceManager.getInstance().getValue<Array<SystemsListBean>>('systems_list')
        .then((data: Array<SystemsListBean> | null) => {
          if (data != null && data.length > 0) {
            this.systemsList = data
            this.pageState = DefaultStateEnum.NORMAL
          } else {
            this.getSystemsListData()
          }
        })
        .catch((error: BusinessError) => {
          this.getSystemsListData()
        })
    })
    .padding({
      top: AppStorage.get<number>('statusBarHeight')
    })
  }

  private getSystemsListData() {
    mSystemsViewModel.getSystemsList()
      .then((data: Array<SystemsListBean>) => {
        this.refreshStatus = HeaderRefreshStatus.inactive
        if (data.length > 0) {
          this.pageState = DefaultStateEnum.NORMAL
        } else {
          this.pageState = DefaultStateEnum.EMPTY
        }
        this.systemsList = data
        PreferenceManager.getInstance().setValue<Array<SystemsListBean>>('systems_list', data)
      })
      .catch((msg: string) => {
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.pageState = DefaultStateEnum.ERROR
        ToastUtil.showToast(msg)
      })
  }

  @Builder
  ListView(scroller: Scroller) {
    Scroll(scroller) {
      Column() {
        ForEach(this.systemsList, (item: SystemsListBean, index: number) => {
          Column() {
            this.TitleHeaderView(item.name)
            WaterFlow() {
              ForEach(item.children, (itemChild: SystemChildrenList, inIndex: number) => {
                FlowItem() {
                  SystemsItemView({
                    item: itemChild
                  })
                }
                .onClick(() => {
                  this.navPathStack.pushPathByName('SystemsChildPage', new Object({
                    'title': itemChild.name,
                    'itemId': itemChild.id
                  }))
                })
              }, (itemChild: SystemChildrenList) => itemChild.id + '')
            }
            .width('100%')
            .rowsGap(10)
            .columnsGap(10)
            .cachedCount(4)
            .columnsTemplate('1fr 1fr 1fr')
            .layoutDirection(FlexDirection.Column)
            .alignSelf(ItemAlign.Start)
          }
        }, (item: SystemsListBean) => (item.id + ''))
      }
      .padding({ left: 20, right: 20 })
    }.width('100%')
    .layoutWeight(1)

  }

  @Builder
  TitleHeaderView(title: string) {
    Text(title)
      .fontColor(Color.Black)
      .fontSize(18)
      .width('100%')
      .backgroundColor(Color.White)
      .textAlign(TextAlign.Center)
      .padding({ top: 15, bottom: 15 })
      .fontWeight(FontWeight.Bold)
  }
}

@Component
export struct SystemsItemView {
  item: SystemChildrenList = new SystemChildrenList()

  build() {
    Text(this.item.name)
      .fontSize(13)
      .fontColor(FeatureUtils.getRandomColor())
      .padding({
        left: 10,
        right: 10,
        top: 5,
        bottom: 5
      })
      .borderWidth(1)
      .borderRadius(20)
      .borderColor(FeatureUtils.getRandomColor())
      .backgroundColor(Color.White)
  }
}

@Builder
export function SystemsPageBuilder() {
  SystemsPage()
}
