import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { CommonPagingBean, PageTitleComponent } from "lib_components"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { IntegralRecordBean } from "../model/IntegralRecordBean"
import { router } from "@kit.ArkUI"
import { BasePage } from "commons"
import { RouterNameUtils, RouterUtil, ToastUtil } from "utils"
import mMineViewModel from "../viewmodel/MineViewModel"
import mIntegralViewModel from "../viewmodel/IntegralViewModel"

@Component
export struct IntegralRecordPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.hidden
  @State dataList: LazyDataSource<IntegralRecordBean> = new LazyDataSource()
  @State pageIndex: number = 1
  @State isAllLoadOver: boolean = false
  navPathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.getIntegralRecordList()
  }

  build() {
    NavDestination() {
      Column() {
        PageTitleComponent({
          title: '积分获取记录',
          isShowLeftIcon: true,
          onLeftIconClick: () => {
            router.back()
          }
        })
        BasePage({
          pageState: this.pageState,
          isNeedRetry: true,
          refreshStatus: this.refreshStatus,
          loadMoreStatus: this.loadMoreStatus,
          ContentViewPage: (_scroller: Scroller) => {
            this.ContentView(_scroller)
          },
          onRefreshing: () => {
            this.pageIndex = 1
            this.getIntegralRecordList()
          },
          onLoadingMore: () => {
            if (this.isAllLoadOver) {
              ToastUtil.showToast('暂无更多数据')
              this.loadMoreStatus = FooterLoadMoreStatus.inactive
              return
            }
            this.getIntegralRecordList()
          },
          onErrorRetryCallback: () => {
            this.pageIndex = 1
            this.getIntegralRecordList()
          }
        })
          .layoutWeight(1)

      }.width('100%')
      .justifyContent(FlexAlign.Start)
      .height('100%')
    }
    .title('积分获取记录')
    .padding({
      top: AppStorage.get<number>('statusBarHeight'),
      bottom: AppStorage.get<number>('naviIndicatorHeight')
    })
    .backgroundColor(Color.White)
    .mode(NavDestinationMode.STANDARD)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context?.pathStack
    })

  }

  private getIntegralRecordList() {
    mIntegralViewModel.getIntegralRecordList(this.pageIndex)
      .then((data: CommonPagingBean<IntegralRecordBean>) => {
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        this.isAllLoadOver = data.over
        if (data.total > 0) {
          this.pageState = DefaultStateEnum.NORMAL
        } else {
          this.pageState = DefaultStateEnum.EMPTY
        }
        if (data.curPage == 1) {
          this.pageIndex = 1
          this.dataList.clear()
        }
        this.pageIndex++
        this.dataList.appendArrayData(data.datas)
      })
      .catch((msg: string) => {
        this.pageState = DefaultStateEnum.ERROR
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
      })
  }

  @Builder
  ContentView(scroller: Scroller) {
    Column() {
      List({ scroller: scroller }) {
        LazyForEach(this.dataList, (item: IntegralRecordBean) => {
          ListItem() {
            IntegralRecordView({
              item: item
            })
          }
        }, (item: IntegralRecordBean) => item.id)
      }
      .divider({
        strokeWidth: 1,
        startMargin: 20,
        endMargin: 20,
        color: '#F5F5F5'
      })
    }
  }
}

@Component
struct IntegralRecordView {
  item: IntegralRecordBean = new IntegralRecordBean()

  build() {
    Row() {
      Text(this.item.desc).fontColor(Color.Black).fontSize(14)
    }.width('100%')
    .padding({
      left: 20,
      right: 20,
      top: 12,
      bottom: 12
    })
  }
}

@Builder
export function IntegralRecordPageBuilder(){
  IntegralRecordPage()
}