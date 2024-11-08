import { SVRefreshHeader, SVRefreshFooter, SVRefreshComponentOptions } from './SVRefreshComponent'
import { SVRefreshDefaultOptions, SVRefreshOptions } from './SVRefreshOptions'

/**
 * 刷新组件的状态
 */
export enum RefreshState {
  /**
   * 隐藏禁用状态
   */
  hidden = 0,
  /**
   * 普通闲置状态
   */
  inactive = 1,
  /**
   * 下拉中但未达到刷新距离
   */
  drag = 2,
  /**
   * 松开就可以进行刷新的状态
   */
  overDrag = 3,
  /**
   * 正在刷新中的状态
   */
  refreshing = 4,
  /**
   * 所有数据加载完毕，没有更多的数据了。用在上拉加载中
   */
  noMoreData = 5,

}

/**
 * 头部刷新组件状态
 */
export enum HeaderRefreshStatus {
  /**
   * 隐藏状态，禁用下拉刷新
   */
  hidden = 0,
  /**
   * 普通闲置状态，可触发刷新
   */
  inactive = 1,
  /**
   * 正在刷新中的状态
   */
  refreshing = 2,
}

export enum FooterLoadMoreStatus {
  /**
   * 隐藏状态，禁用上拉加载
   */
  hidden = 0,
  /**
   * 普通闲置状态，可触发加载
   */
  inactive = 1,
  /**
   * 正在加载中的状态
   */
  loading = 2,
  /**
   * 无更多数据状态，展示但是不可触发刷新
   */
  noMoreData = 3
}

@Component
export struct SVRefresh {
  /**
   * 自行初始化 Scroller，可以不传，由 SVRefresh 内部自行初始化 Scroller
   */
  scroller?: Scroller
  /**
   * 内部绑定的 list 或者 grid 等可滚动组件：Scroller 或者 ListScroller
   * @param $$: scroller 滚动控制器，必须和内部的 list 或 grid 绑定起来，不然无法使用
   */
  @Require @BuilderParam childList: ($$: Scroller) => void
  /**
   * 头部刷新组件状态
   * 设置为 hidden 可隐藏；
   * 设置为 inactive 可结束刷新；
   * 设置为 refreshing 可主动刷新；
   */
  @Link @Watch('refreshStatusUpdate') refreshStatus: HeaderRefreshStatus
  /**
   * 尾部刷新组件状态
   * 设置为 hidden 可隐藏；
   * 设置为 inactive 可结束刷新；
   * 设置为 refreshing 可主动刷新；
   * 设置为 noMoreData 展示尾部组件，但不可触发刷新
   */
  @Link @Watch('loadMoreStatusUpdate') loadMoreStatus: FooterLoadMoreStatus
  /**
   * 刷新组件相关配置：如 header、footer 的高度，是否开启弹性效果，是否自动触发底部加载
   */
  refreshOptions?: SVRefreshOptions = {}
  /**
   * 默认刷新组件的 UI 配置，都是默认刷新控件的样式，使用自定义控件不需要赋值
   */
  componentOptions?: SVRefreshComponentOptions
  /**
   * 下拉刷新事件
   */
  onRefreshing?: () => void
  /**
   * 上拉加载事件
   */
  onLoadingMore?: () => void
  /**
   * 自定义下拉刷新组件，不传为默认样式
   */
  @BuilderParam headerUI?: ($$: RefreshStateImp) => void
  /**
   * 自定义上拉加载组件，不传为默认样式
   */
  @BuilderParam footerUI?: ($$: RefreshStateImp) => void
  /**
   * header 刷新状态改变回调
   */
  onHeaderStateChange?: (state: RefreshState) => void
  /**
   * footer 刷新状态改变回调
   */
  onFooterStateChange?: (state: RefreshState) => void
  /// 下面为私有属性
  private _scroller: Scroller = new Scroller()
  private defaultOptions: SVRefreshDefaultOptions = new SVRefreshDefaultOptions()
  @State private mHeightNumber: number = 0
  @State @Watch('headerStateChanged') private headerState: RefreshState = RefreshState.inactive
  @State @Watch('footerStateChanged') private footerState: RefreshState = RefreshState.inactive
  @State private headerOffset: number = 0 /* header 的当前偏移量*/
  @State private footerOffset: number = 0 /* footer 的当前偏移量*/
  private isDragging = false
  private headerWillHidden = false /* overDrag 的拖动过程中进行 hidden 操作 */
  private footerWillHidden = false /* overDrag 的拖动过程中进行 hidden 操作 */
  private footerWillEndLoading = false /* 列表更新可能存在延迟，即数据和 footer 状态更新后页面还未完成更新，此时手势未中断可能再次触发上拉加载事件，这里加个延时等待页面加载完成 */
  private previousFrameOffsetY = 0 /*上一帧的手势移动距离*/
  private syncStatus = false
  private lockedWithAutoLoadingMore = false /* 针对自动触发上拉的模式，单次手势只能触发单次刷新回调 */

  aboutToAppear(): void {
    if (this.scroller) {
      this._scroller = this.scroller
    }
    this.refreshStatusUpdate()
    this.loadMoreStatusUpdate()
  }

  build() {
    Column() {
      if (this.headerState != RefreshState.hidden) {
        Stack({ alignContent: Alignment.Bottom }) {
          Stack() {
            if (this.headerUI != undefined) {
              this.headerUI({ state: this.headerState })
            } else {
              SVRefreshHeader({
                state: this.headerState,
                componentOptions: this.componentOptions
              })
            }
          }
          .height(this.refreshOptions?.headerHeight ?? this.defaultOptions.headerHeight)
          .width("100%")
        }
        .width("100%")
        .height(this.headerOffset)
        .clip(true)
      }

      Column() {
        this.childList(this._scroller)
      }
      .width("100%")
      .height(this.mHeightNumber - this.headerOffset - this.footerOffset)

      if (this.footerState != RefreshState.hidden) {
        Stack({ alignContent: Alignment.Top }) {
          Stack() {
            if (this.footerUI != undefined) {
              this.footerUI({ state: this.footerState })
            } else {
              SVRefreshFooter({
                state: this.footerState,
                componentOptions: this.componentOptions,
                isAutoLoadMore: (this.refreshOptions?.isAutoLoadMore ?? this.defaultOptions.isAutoLoadMore)
              })
            }
          }
          .height(this.refreshOptions?.footerHeight ?? this.defaultOptions.footerHeight)
          .width("100%")
        }
        .width("100%")
        .height(this.footerOffset)
        .clip(true)
      }
    }
    .width("100%")
    .height("100%")
    .onAreaChange((_oldValue, newValue) => {
      this.mHeightNumber = Math.round(newValue.height as number);
    })
    .parallelGesture(
      PanGesture(new PanGestureOptions({ direction: PanDirection.Up | PanDirection.Down }))
        .onActionStart((event?: GestureEvent) => {
          if (event == undefined) {
            return
          }
          this.isDragging = true
          this.previousFrameOffsetY = 0
          this.onActionUpdate(event);
        })
        .onActionUpdate((event?: GestureEvent) => {
          if (event == undefined) {
            return
          }
          this.onActionUpdate(event);
        })
        .onActionEnd(() => {
          this.onActionEnd();
          this.isDragging = false
        })
    )
  }

  private onActionUpdate(event: GestureEvent) {
    let stepOffsetY = event.offsetY - this.previousFrameOffsetY
    this.previousFrameOffsetY = event.offsetY
    if (this._scroller.currentOffset() == undefined) {
      return
    }
    if (this.headerState != RefreshState.hidden && !this.headerWillHidden) {
      /*兼容页面滑动到顶部时，this._scroller.currentOffset().yOffset返回0.000000....的浮点数的情况*/
      let isAtTop = this._scroller.currentOffset().yOffset < 0.001
      let headerTargetOffset = Math.max(0, this.headerOffset + stepOffsetY)
      if (!(this.refreshOptions?.headerBounces ?? this.defaultOptions.headerBounces)) { /*不支持弹性效果的处理*/
        let triggerThreshold = 0.85 /* 该比例是为了控制触发阈值，在不支持弹性的情况下更好触发*/
        headerTargetOffset = Math.min(headerTargetOffset, ((this.refreshOptions?.headerHeight ?? this.defaultOptions.headerHeight) / triggerThreshold))
      }
      if (this.headerOffset > 0) { /*header 已展示，此时手势拖动应该保持 scroll 不动，header 动*/
        this._scroller.scrollEdge(Edge.Top)
        this.headerOffset = headerTargetOffset
      } else if (isAtTop && stepOffsetY > 0) { /*header 未展示，scroll 处于顶端且下拉时，scroll 不动，header 动*/
        this._scroller.scrollEdge(Edge.Top)
        this.headerOffset = headerTargetOffset
      }
      if (this.headerState != RefreshState.refreshing) {
        this.syncStatus = true
        if (this.headerOffset >= (this.refreshOptions?.headerHeight ?? this.defaultOptions.headerHeight)) {
          this.headerState = RefreshState.overDrag
        } else if (this.headerOffset <= 0) {
          this.headerState = RefreshState.inactive
        } else {
          this.headerState = RefreshState.drag
        }
        this.syncStatus = false
      }
    }
    if (this.footerState != RefreshState.hidden && !this.footerWillHidden) {
      let isAtEnd = this._scroller.isAtEnd()
      let footerTargetOffset = Math.max(0, this.footerOffset - stepOffsetY)
      if (!(this.refreshOptions?.footerBounces ?? this.defaultOptions.footerBounces)) { /*不支持弹性效果的处理*/
        let triggerThreshold = ((this.refreshOptions?.isAutoLoadMore ?? this.defaultOptions.isAutoLoadMore) || this.footerState == RefreshState.noMoreData) ? 1 : 0.85 /* 该比例是为了控制触发阈值，在不支持弹性的情况下更好触发*/
        footerTargetOffset = Math.min(footerTargetOffset, ((this.refreshOptions?.footerHeight ?? this.defaultOptions.footerHeight) / triggerThreshold))
      }
      if (this.footerOffset > 0) { /*footer 已展示，此时手势拖动应该保持 scroll 不动，footer 动*/
        this._scroller.scrollEdge(Edge.Bottom)
        this.footerOffset = footerTargetOffset
      } else if (isAtEnd && stepOffsetY < 0 && !this.footerWillEndLoading) { /*footer 未展示，scroll 处于顶端且上拉时，scroll 不动，footer 动*/
        this._scroller.scrollEdge(Edge.Bottom)
        this.footerOffset = footerTargetOffset
      }
      if (this.footerState != RefreshState.refreshing && this.footerState != RefreshState.noMoreData && !this.footerWillEndLoading) { /*这三种样式不做回弹处理，拖动时状态也不会切换*/
        this.syncStatus = true
        if (this.footerOffset >= (this.refreshOptions?.footerHeight ?? this.defaultOptions.footerHeight)) {
          if ((this.refreshOptions?.isAutoLoadMore ?? this.defaultOptions.isAutoLoadMore)) { /*自动触发模式在这里触发 onLoadingMore() */
            if ((this.refreshOptions?.onlyAutoLoadMoreOnceOnSingleDrag ?? this.defaultOptions.onlyAutoLoadMoreOnceOnSingleDrag)) {
              /// 自动触发模式单次手势只触发一次刷新
              if (!this.lockedWithAutoLoadingMore) {
                this.footerState = RefreshState.refreshing
                if (this.onLoadingMore) {
                  this.onLoadingMore()
                }
                this.lockedWithAutoLoadingMore = true
              }
            } else {
              this.footerState = RefreshState.refreshing
              if (this.onLoadingMore) {
                this.onLoadingMore()
              }
            }
          } else { /*非自动触发模式，等手势结束 onActionEnd 事件中处理是否调用 onLoadingMore() */
            this.footerState = RefreshState.overDrag
          }
        } else if (this.footerOffset <= 0) {
          this.footerState = RefreshState.inactive
        } else {
          this.footerState = RefreshState.drag
        }
        this.syncStatus = false
      }
    }
  }

  private onActionEnd() {
    if (this.headerState != RefreshState.hidden && !this.headerWillHidden) {
      let headerTargetOffset: number
      if (this.headerState == RefreshState.overDrag) { /*正常触发下拉刷新事件*/
        this.syncStatus = true
        this.headerState = RefreshState.refreshing
        this.syncStatus = false
        if (this.onRefreshing != undefined) {
          this.onRefreshing()
        }
        headerTargetOffset = (this.refreshOptions?.headerHeight ?? this.defaultOptions.headerHeight)
      } else if (this.headerState == RefreshState.refreshing) { /*已经正在刷新，不做改变*/
        headerTargetOffset = Math.min(this.headerOffset, (this.refreshOptions?.headerHeight ?? this.defaultOptions.headerHeight))
      } else { /*未达到下拉刷新条件，需要隐藏刷新组件*/
        headerTargetOffset = 0
        if (this.headerState != RefreshState.inactive) {
          this.syncStatus = true
          this.headerState = RefreshState.inactive
          this.syncStatus = false
        }
      }
      if (this.headerOffset != headerTargetOffset) {
        this._scroller.scrollEdge(Edge.Top)
        animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
          this.headerOffset = headerTargetOffset
        })
      } else if (headerTargetOffset > 0) {
        this._scroller.scrollEdge(Edge.Top)
      }
    }
    if (this.footerState != RefreshState.hidden && !this.footerWillHidden) {
      let footerTargetOffset: number
      if (this.footerState == RefreshState.overDrag) { /*只有非自动触发模式，才能进入 overDrag 状态*/
        this.syncStatus = true
        this.footerState = RefreshState.refreshing
        this.syncStatus = false
        if (this.onLoadingMore != undefined) {
          this.onLoadingMore()
        }
        footerTargetOffset = (this.refreshOptions?.footerHeight ?? this.defaultOptions.footerHeight)
      } else if (this.footerState == RefreshState.refreshing || this.footerState == RefreshState.noMoreData || (this.refreshOptions?.isAutoLoadMore ?? this.defaultOptions.isAutoLoadMore)) {
        /*这三种模式不需要处理相应事件*/
        if (this.lockedWithAutoLoadingMore && this.footerState != RefreshState.refreshing && this.footerState != RefreshState.noMoreData) {
          footerTargetOffset = 0
        } else {
          footerTargetOffset = Math.min(this.footerOffset, (this.refreshOptions?.footerHeight ?? this.defaultOptions.footerHeight))
        }
      } else {
        /*非自动触发模式，未达到加载条件，隐藏组件*/
        footerTargetOffset = 0
        if (this.footerState != RefreshState.inactive) {
          this.syncStatus = true
          this.footerState = RefreshState.inactive
          this.syncStatus = false
        }
      }
      if (this.footerOffset != footerTargetOffset) {
        this._scroller.scrollEdge(Edge.Bottom)
        animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
          this.footerOffset = footerTargetOffset
        })
      } else if (footerTargetOffset > 0) {
        this._scroller.scrollEdge(Edge.Bottom)
      }
    }
    this.lockedWithAutoLoadingMore = false
  }

  headerStateChanged() {
    if (this.onHeaderStateChange != undefined) {
      this.onHeaderStateChange(this.headerState)
    }
    if (this.syncStatus) {
      if (this.headerState == RefreshState.hidden) {
        this.refreshStatus = HeaderRefreshStatus.hidden
      } else if (this.headerState == RefreshState.refreshing) {
        this.refreshStatus = HeaderRefreshStatus.refreshing
      } else {
        this.refreshStatus = HeaderRefreshStatus.inactive
      }
    }
  }

  footerStateChanged() {
    if (this.onFooterStateChange != undefined) {
      this.onFooterStateChange(this.footerState)
    }
    if (this.syncStatus) {
      if (this.footerState == RefreshState.hidden) {
        this.loadMoreStatus = FooterLoadMoreStatus.hidden
      } else if (this.footerState == RefreshState.refreshing) {
        this.loadMoreStatus = FooterLoadMoreStatus.loading
      } else if (this.footerState == RefreshState.noMoreData) {
        this.loadMoreStatus = FooterLoadMoreStatus.noMoreData
      } else {
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
      }
    }
  }

  refreshStatusUpdate() {
    switch (this.refreshStatus) {
      case HeaderRefreshStatus.hidden:
        this.setHeaderHidden(true)
        break
      case HeaderRefreshStatus.inactive:
        if (this.headerState == RefreshState.hidden) {
          this.setHeaderHidden(false)
        } else if (this.headerState == RefreshState.refreshing) {
          this.endRefresh()
        }
        break
      case HeaderRefreshStatus.refreshing:
        if (this.headerState == RefreshState.hidden) {
          this.setHeaderHidden(false)
        }
        if (this.headerState != RefreshState.refreshing) {
          this.beginRefresh()
        }
        break
    }
  }

  loadMoreStatusUpdate() {
    switch (this.loadMoreStatus) {
      case FooterLoadMoreStatus.hidden:
        this.setFooterHidden(true)
        break
      case FooterLoadMoreStatus.inactive:
        if (this.footerState == RefreshState.hidden) {
          this.setFooterHidden(false)
        } else if (this.footerState == RefreshState.refreshing || this.footerState == RefreshState.noMoreData) {
          this.endLoadMore(true)
        }
        break
      case FooterLoadMoreStatus.loading:
        if (this.footerState == RefreshState.hidden) {
          this.setFooterHidden(false)
        }
        if (this.footerState == RefreshState.noMoreData) {
          this.endLoadMore(true)
        }
        if (this.footerState != RefreshState.refreshing) {
          this.beginLoadingMore()
        }
        break
      case FooterLoadMoreStatus.noMoreData:
        if (this.footerState == RefreshState.hidden) {
          this.setFooterHidden(false)
        }
        if (this.footerState != RefreshState.noMoreData) {
          this.endLoadMore(false)
        }
        break
    }
  }

  private beginRefresh() {
    if (this.headerState == RefreshState.hidden) {
      return
    }
    if (this.headerState == RefreshState.refreshing) {
      return
    }
    this.headerState = RefreshState.refreshing
    if (this.onRefreshing != undefined) {
      this.onRefreshing()
    }
    if (this._scroller.currentOffset() != undefined && this._scroller.currentOffset().yOffset > 0) {
      /*
       优化动画效果，列表不在顶部时触发刷新，需要先滚动到顶部，再触发 header 出现的动画
       offset 距离不同，滚动需要的时间不同
       */
      let scale = this._scroller.currentOffset().yOffset / (this.mHeightNumber / 2)
      scale = Math.min(scale, 1)
      let scrollDuration = (90 * scale) + 60
      this._scroller.scrollTo({ xOffset: 0, yOffset: 0, animation: { duration: scrollDuration } })
      setTimeout(() => {
        animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
          this.headerOffset = (this.refreshOptions?.headerHeight ?? this.defaultOptions.headerHeight)
        })
      }, scrollDuration)
    } else {
      /*列表已经在顶部，直接展示 header 动画效果*/
      animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
        this.headerOffset = (this.refreshOptions?.headerHeight ?? this.defaultOptions.headerHeight)
      })
    }
  }

  private endRefresh() {
    if (this.headerState == RefreshState.hidden) {
      return
    }
    if (this.headerState != RefreshState.refreshing) {
      return
    }
    this.headerState = RefreshState.inactive
    if (this.headerOffset != 0) {
      animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
        this.headerOffset = 0
      })
    }
  }

  private beginLoadingMore() {
    if (this.footerState == RefreshState.hidden) {
      return
    }
    if (this.footerState == RefreshState.refreshing) {
      return
    }
    if (this.footerState == RefreshState.noMoreData) {
      return
    }
    this.footerState = RefreshState.refreshing
    if (this.onLoadingMore) {
      this.onLoadingMore()
    }
  }

  private endLoadMore(hasMoreData: boolean) {
    if (this.footerState == RefreshState.hidden) {
      return
    }
    if (hasMoreData && (this.footerState == RefreshState.refreshing || this.footerState == RefreshState.noMoreData)) {
      /*结束加载后恢复为可用状态*/
      this.footerWillEndLoading = true
      setTimeout(() => {
        this.footerWillEndLoading = false
      }, 100)
      this.footerState = RefreshState.inactive
      /* 由于 loadMore 完成一般伴随着 List 尾部新数据的添加，footer 应该在数据更新后第一时间消失。不应该加动画*/
      if (this.footerOffset != 0) {
        this.footerOffset = 0
      }
    } else if (!hasMoreData && (this.footerState != RefreshState.noMoreData)) {
      /*结束加载后为不响应状态*/
      this.footerWillEndLoading = true
      setTimeout(() => {
        this.footerWillEndLoading = false
      }, 100)
      this.footerState = RefreshState.noMoreData
      /* 由于 loadMore 完成一般伴随着 List 尾部新数据的添加，footer 应该在数据更新后第一时间消失。不应该加动画*/
      if (this.footerOffset != 0) {
        this.footerOffset = 0
      }
    }
  }

  private setHeaderHidden(isHidden: boolean) {
    if (isHidden && this.headerState != RefreshState.hidden) {
      if (this.headerOffset != 0) {
        this.headerWillHidden = true
        animateTo({
          duration: 250, curve: Curve.EaseOut, onFinish: () => {
            this.headerState = RefreshState.hidden
            this.headerWillHidden = false
          }
        }, () => {
          this.headerOffset = 0
        })
      } else {
        this.headerState = RefreshState.hidden
      }
    } else if (!isHidden && this.headerState == RefreshState.hidden) {
      this.headerState = RefreshState.inactive
    }
  }

  private setFooterHidden(isHidden: boolean) {
    if (isHidden && this.footerState != RefreshState.hidden) {
      if (this.footerOffset != 0) {
        this.footerWillHidden = true
        animateTo({
          duration: 250, curve: Curve.EaseOut, onFinish: () => {
            this.footerState = RefreshState.hidden
            this.footerWillHidden = false
          }
        }, () => {
          this.footerOffset = 0
        })
      } else {
        this.footerState = RefreshState.hidden
      }
    } else if (!isHidden && this.footerState == RefreshState.hidden) {
      this.footerState = RefreshState.inactive
    }
  }
}

export interface RefreshStateImp {
  state: RefreshState
}