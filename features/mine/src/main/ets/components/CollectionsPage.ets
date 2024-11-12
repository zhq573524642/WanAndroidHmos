import { BasePage } from "commons"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { CollectionsBean, CollectionsList } from "../model/CollectionsBean"
import { LengthMetrics } from "@kit.ArkUI"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import mCollectViewModel from "../viewmodel/CollectViewModel"
import { AppConstant, EmitterUtils, ToastUtil } from "utils"
import { emitter } from "@kit.BasicServicesKit"

@Component
export struct CollectionsPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State collectionsList: LazyDataSource<CollectionsList> = new LazyDataSource()
  @State pageIndex: number = 0
  @State msgError: string = '数据异常'
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
      .then((data: CollectionsBean) => {
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
    List({ scroller: scroller }) {
      LazyForEach(this.collectionsList, (item: CollectionsList, index: number) => {
        ListItem() {
          CollectionItemView({
            item: item,
            onCollectRemove: () => {

            }
          })
            .onClick(() => {

            })
        }
      }, (item: CollectionsList) => item.id)
    }.width('100%')
  }
}

@Component
struct CollectionItemView {
  item: CollectionsList = new CollectionsList()
  onCollectRemove?: () => void

  build() {
    Row() {
      Column() {
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
          Text('作者').fontColor(Color.Gray).fontSize(12)
          Text(this.item.author).fontColor(Color.Grey).fontSize(12)
          Text('收藏时间：').fontColor(Color.Gray).fontSize(12).margin({ left: 8 })
          Text(this.item.niceDate).fontColor(Color.Grey).fontSize(12)
        }
      }.layoutWeight(1)

      Image($r('app.media.ic_remove_collect'))
        .width(28)
        .height(28)
        .onClick(() => {
          this.onCollectRemove?.()
        })
    }.padding(15)
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}