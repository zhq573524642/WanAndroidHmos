import { RefreshState } from './SVRefresh'

/**
 * 都是默认刷新控件的样式，使用自定义控件不需要关心这些属性
 */
export declare interface SVRefreshComponentOptions {
  headerFont: Font
  footerFont: Font
  headerLoadingProgressSize: Length
  footerLoadingProgressSize: Length
  headerText: (state: RefreshState) => string
  footerText: (state: RefreshState) => string
}

class DefaultComponentOptions implements SVRefreshComponentOptions {
  isAutoLoadMore: boolean = true
  headerFont: Font = { size: 16 }
  footerFont: Font = { size: 16 }
  headerLoadingProgressSize: Length = 36
  footerLoadingProgressSize: Length = 36
  headerText: (state: RefreshState) => string = (state) => {
    if (state == RefreshState.overDrag) {
      return "松手刷新"
    } else if (state == RefreshState.refreshing) {
      return "正在刷新..."
    } else {
      return "下拉刷新"
    }
  }
  footerText: (state: RefreshState) => string = (state) => {
    if (state == RefreshState.noMoreData) {
      return "没有更多数据"
    } else if (state == RefreshState.overDrag && !this.isAutoLoadMore) {
      return "松手加载更多"
    } else if (state == RefreshState.refreshing) {
      return ""
    } else {
      return "上拉加载更多"
    }
  }
}


@Component
export struct SVRefreshHeader {
  @Prop state: RefreshState
  @Prop componentOptions: SVRefreshComponentOptions

  aboutToAppear(): void {
    if (this.componentOptions == undefined) {
      this.componentOptions = new DefaultComponentOptions()
    }
  }

  build() {
    Row({ space: 8 }) {
      if (this.shouldShowLoading()) {
        LoadingProgress()
          .width(this.componentOptions.headerLoadingProgressSize)
      }
      Text(this.componentOptions.headerText(this.state))
        .font(this.componentOptions.headerFont)
        .width(this.componentOptions.headerText(this.state)
          .length == 0 ? 0 : (this.shouldShowLoading() ? "55%" : "100%"))
        .textAlign(this.shouldShowLoading() ? TextAlign.Start : TextAlign.Center)
    }
    .justifyContent(this.componentOptions.headerText(this.state).length == 0 ? FlexAlign.Center : FlexAlign.End)
    .width("100%")
  }

  private shouldShowLoading(): boolean {
    return this.state == RefreshState.refreshing || this.componentOptions.headerText(this.state).length == 0
  }
}

@Component
export struct SVRefreshFooter {
  @Prop state: RefreshState
  @Prop isAutoLoadMore: boolean = true
  @Prop componentOptions: SVRefreshComponentOptions

  aboutToAppear(): void {
    if (this.componentOptions == undefined) {
      this.componentOptions = new DefaultComponentOptions()
    }
  }

  build() {
    Row({ space: 8 }) {
      if (this.shouldShowLoading()) {
        LoadingProgress()
          .width(this.componentOptions.footerLoadingProgressSize)
      }
      Text(this.componentOptions.footerText(this.state))
        .font(this.componentOptions.footerFont)
        .width(this.componentOptions.footerText(this.state)
          .length == 0 ? 0 : (this.shouldShowLoading() ? "55%" : "100%"))
        .textAlign(this.shouldShowLoading() ? TextAlign.Start : TextAlign.Center)
    }
    .justifyContent(this.componentOptions.footerText(this.state).length == 0 ? FlexAlign.Center : FlexAlign.End)
    .width("100%")
  }

  private shouldShowLoading(): boolean {
    return this.state == RefreshState.refreshing || this.componentOptions.footerText(this.state).length == 0
  }
}