import { DefaultStateEnum } from "../components/defaultState/DefaultStateEnum"
import { DefaultStatePage } from "../components/defaultState/DefaultStatePage"
import { FooterLoadMoreStatus, HeaderRefreshStatus, SVRefresh } from "../components/SVRefresh/SVRefresh"

@Component
export struct BasePage {
  // 用来控制刷新状态 默认无下拉刷新
  @Link refreshStatus: HeaderRefreshStatus
  // 用来控制加载状态 默认无上拉加载
  @Link loadMoreStatus: FooterLoadMoreStatus
  @Prop pageState?: DefaultStateEnum = DefaultStateEnum.LOADING
  @Prop msgNoData?: string = '暂无数据'
  @Prop msgError?: string = '数据异常，点击重试'
  onErrorRetryCallback?: () => void
  @BuilderParam ContentViewPage: (scroller: Scroller) => void
  onRefreshing?: () => void
  onLoadingMore?: () => void

  build() {
    Column() {
      this.ParentView()
    }.width('100%')
  }

  @Builder
  ParentView() {
    SVRefresh({
      refreshStatus: this.refreshStatus,
      loadMoreStatus: this.loadMoreStatus,
      refreshOptions: {},
      childList: (scroller) => {
        this.ContentView(scroller)
      },
      onRefreshing: () => {
        if (this.onRefreshing) {
          this.onRefreshing()
        }
      },
      onLoadingMore: () => {
        if (this.onLoadingMore) {
          this.onLoadingMore()
        }
      }
    })
      .layoutWeight(1)
  }

  @Builder
  ContentView(scroller: Scroller) {
    DefaultStatePage({
      scroller: scroller,
      defaultState: this.pageState,
      noDataMsg: this.msgNoData,
      errorMsg: this.msgError,
      normalPage: () => {
        this.ContentViewPage(scroller)
      },
      onRetryCallback: () => {
        this.onErrorRetryCallback?.()
      }
    })
      .layoutWeight(1)
  }
}