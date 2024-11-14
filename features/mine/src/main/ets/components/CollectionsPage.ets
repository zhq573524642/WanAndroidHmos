import { BasePage } from "commons"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { LengthMetrics } from "@kit.ArkUI"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import mCollectViewModel from "../viewmodel/CollectViewModel"
import { AppConstant, EmitterUtils, ResponseResultC, ToastUtil } from "utils"
import { emitter } from "@kit.BasicServicesKit"
import { data } from "@kit.TelephonyKit"
import { WebViewPage } from "lib_components/src/main/ets/components/WebViewPage"
import { CommonArticlesBean, CommonPagingBean } from "lib_components"

@Component
export struct CollectionsPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State collectionsList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State pageIndex: number = 0
  @State msgError: string = '数据异常'
  @State msgNoData: string = '暂无收藏'
  @State isAllLoadOver: boolean = false

  aboutToAppear(): void {
    EmitterUtils.getInstance().on(AppConstant.FLAG_LOGIN_SUCCESS, (eventData: emitter.EventData) => {
      this.requestCollectionsList()
    })
    this.requestCollectionsList()
  }

  aboutToDisappear(): void {
    EmitterUtils.getInstance().unregister(AppConstant.FLAG_LOGIN_SUCCESS)
  }

  build() {
    Column() {

      BasePage({
        pageState: this.pageState,
        refreshStatus: this.refreshStatus,
        loadMoreStatus: this.loadMoreStatus,
        msgError: this.msgError,
        msgNoData: this.msgNoData,
        ContentViewPage: (_scroller: Scroller) => {
          this.ContentListView(_scroller)
        },
        onRefreshing: () => {
          this.pageIndex = 0
          this.requestCollectionsList()
        },
        onLoadingMore: () => {
          if (this.isAllLoadOver) {
            ToastUtil.showToast('暂无更多数据')
            this.loadMoreStatus = FooterLoadMoreStatus.inactive
            return
          }
          this.requestCollectionsList()
        },
        onErrorRetryCallback: () => {
          this.requestCollectionsList()
        }
      })
        .layoutWeight(1)
        .width('100%')

    }.width('100%')
    .height('100%')
  }

  private requestCollectionsList() {
    mCollectViewModel.getCollectionsList(this.pageIndex)
      .then((data: CommonPagingBean<CommonArticlesBean>) => {
        this.isAllLoadOver = data.over
        if (data.total == 0) {
          this.pageState = DefaultStateEnum.EMPTY
        } else {
          this.pageState = DefaultStateEnum.NORMAL
        }
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        if (this.pageIndex == 0) {
          this.collectionsList.clear()
        }
        this.pageIndex++
        this.collectionsList.appendArrayData(data.datas)

      })
      .catch((msg: string) => {
        this.msgError = msg
        this.pageState = DefaultStateEnum.ERROR
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
      })
  }

  @Builder
  ContentListView(scroller: Scroller) {
    List({ scroller: scroller, space: 12 }) {
      LazyForEach(this.collectionsList, (item: CommonArticlesBean, index: number) => {
        ListItem() {
          CollectionItemView({
            item: item,
            index: index,
            onCollectRemove: (data: CommonArticlesBean, i: number) => {
              this.handleCancelCollect(item, index)
            }
          })
            .onClick(() => {
              WebViewPage.startPage(item.link, true, item.title)
            })
        }
        .padding({ left: 15, right: 15 })
      }, (item: CommonArticlesBean) => item.id)
    }.width('100%')
  }

  private handleCancelCollect(item: CommonArticlesBean, index: number) {
    mCollectViewModel.handleCollect(item.id, item.originId)
      .then((data: ResponseResultC<''>) => {
        if (data.errorCode === 0) {
          ToastUtil.showToast('已取消收藏')
          this.collectionsList.deleteData(index)
          if (this.collectionsList.isEmpty()) {
            this.pageState = DefaultStateEnum.EMPTY
          }
        }
      })
      .catch((msg: string) => {
        ToastUtil.showToast('取消收藏失败')
      })
  }
}

@Component
struct CollectionItemView {
  item: CommonArticlesBean = new CommonArticlesBean()
  index: number = 0
  onCollectRemove?: (data: CommonArticlesBean, index: number) => void

  build() {
    Row() {
      Column({ space: 10 }) {
        Row() {
          Text('分类：').fontColor(Color.Gray).fontSize(12)
          Text(this.item.chapterName).fontColor(Color.Grey).fontSize(12)
        }

        Text(this.item.title)
          .fontColor(Color.Black)
          .fontSize(13)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineSpacing(LengthMetrics.vp(3))
        Row() {
          Text('作者：').fontColor(Color.Gray).fontSize(12)
          Text(this.item.author).fontColor(Color.Grey).fontSize(12)
          Text('收藏时间：').fontColor(Color.Gray).fontSize(12).margin({ left: 8 })
          Text(this.item.niceDate).fontColor(Color.Grey).fontSize(12)
        }
      }.layoutWeight(1)
      .margin({ right: 10 })
      .alignItems(HorizontalAlign.Start)


      Image($r('app.media.ic_remove_collect'))
        .width(18)
        .height(18)
        .objectFit(ImageFit.Fill)
        .onClick(() => {
          this.onCollectRemove?.(this.item, this.index)
        })
    }
    .padding(15)
    .borderRadius(10)
    .backgroundColor(Color.White)
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}