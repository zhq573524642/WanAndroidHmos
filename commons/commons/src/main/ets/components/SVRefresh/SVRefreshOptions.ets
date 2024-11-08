export declare interface SVRefreshOptions {
  /**
   * 决定了下拉刷新控件的展示高度，同时也是触发下拉事件的高度。默认值 64
   */
  headerHeight?: number
  /**
   * 决定了上拉加载控件的展示高度，同时也是触发上拉事件的高度。默认值 54
   */
  footerHeight?: number
  /**
   * 下拉是否支持弹性效果。默认为 true
   */
  headerBounces?: boolean
  /**
   * 上拉是否支持弹性效果。默认为 true
   */
  footerBounces?: boolean
  /**
   * 可以控制上拉加载组件的触发方式，默认为 true
   * 传 true 为自动触发方式，footer 完全展示就会触发
   * 传 false 为手动触发方式，需要手势拖拽后松手才能触发
   */
  isAutoLoadMore?: boolean
  /**
   * 当 isAutoLoadMore 为 true 时，可以控制单次拖拽期间内只能触发一次 loading。默认为 false
   * 用来避免 loadMore 回调太快且又没有足够的数据可更新，导致的频繁触发加载回调的问题
   */
  onlyAutoLoadMoreOnceOnSingleDrag?: boolean
}

export class SVRefreshDefaultOptions implements SVRefreshOptions {
  headerHeight: number = 64
  footerHeight: number = 54
  headerBounces: boolean = true
  footerBounces: boolean = true
  isAutoLoadMore: boolean = true
  onlyAutoLoadMoreOnceOnSingleDrag: boolean = false
}