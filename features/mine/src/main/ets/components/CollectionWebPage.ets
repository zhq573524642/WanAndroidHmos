import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { CommonArticlesBean } from "lib_components"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { ToastUtil } from "utils/src/main/ets/utils/ToastUtil"
import { LengthMetrics } from "@kit.ArkUI"
import { WebViewPage } from "lib_components/src/main/ets/components/WebViewPage"
import { BasePage } from "commons"
import mCollectViewModel from "../viewmodel/CollectViewModel"
import { HandleCollectWebsDialog } from "./HandleCollectWebsDialog"
import { AppConstant, EmitterUtils, ResponseResultC } from "utils"
import emitter from "@ohos.events.emitter"

@Component
export struct CollectionWebPage {
  @Consume('appPathStack') appPathStack: NavPathStack
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.hidden
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.hidden
  @State collectionsList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State msgError: string = '数据异常'
  @State msgNoData: string = '暂无收藏'
  @State isShowCollectButton: boolean = true
  @State collectTitle: string = ''
  @State collectLink: string = ''
  @State isUpdateHandle: boolean = false
  @State currentEditCollectItem: CommonArticlesBean = new CommonArticlesBean()
  editCollectDialogController: CustomDialogController = new CustomDialogController({

    builder: HandleCollectWebsDialog({
      name: this.collectTitle,
      link: this.collectLink,
      onSaveCollectCallback: () => {
        if (this.isUpdateHandle) {
          //编辑收藏的文章
          this.requestUpdateCollectWebs()
        } else {
          //新增收藏站外文章
          this.requestCollectWebs()
        }
      }
    }),
    backgroundColor: Color.White,
    autoCancel: true,
    alignment: DialogAlignment.Center,
    cornerRadius: 10
  })

  private requestUpdateCollectWebs() {
    mCollectViewModel.updateCollectWeb(this.currentEditCollectItem.id, this.collectTitle,
      this.collectLink)
      .then((data: string) => {
        ToastUtil.showToast(data)
        this.editCollectDialogController.close()
        this.requestCollectionsList()
      })
      .catch((msg: string) => {
        ToastUtil.showToast(msg)
      })
  }

  private requestCollectWebs() {
    mCollectViewModel.handleCollectWeb(this.collectTitle, this.collectLink)
      .then((data: string) => {
        ToastUtil.showToast(data)
        this.editCollectDialogController.close()
        this.requestCollectionsList()
      })
      .catch((msg: string) => {
        ToastUtil.showToast(msg)
      })
  }

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

    Stack({ alignContent: Alignment.BottomEnd }) {
      BasePage({
        pageState: this.pageState,
        isNeedRetry: true,
        refreshStatus: this.refreshStatus,
        loadMoreStatus: this.loadMoreStatus,
        msgError: this.msgError,
        msgNoData: this.msgNoData,
        ContentViewPage: (_scroller: Scroller) => {
          this.ContentListView(_scroller)
        },
        onErrorRetryCallback: () => {
          this.requestCollectionsList()
        }
      })
        .layoutWeight(1)
        .width('100%')
      if (this.isShowCollectButton) {

        Image($r('app.media.ic_collect_float_btn'))
          .width(50)
          .height(50)
          .objectFit(ImageFit.Cover)
          .shadow({
            radius: 10,
            color: $r('app.color.app_theme_color'),
            type: ShadowType.BLUR
          })
          .backgroundColor(Color.Transparent)
          .margin(15)
          .onClick(() => {
            this.isUpdateHandle = false
            this.collectTitle = ''
            this.collectLink = ''
            this.editCollectDialogController.open()
          })
      }
    }.width('100%')
    .height('100%')
  }

  private requestCollectionsList() {
    mCollectViewModel.getWebCollectionsList()
      .then((data: Array<CommonArticlesBean>) => {
        if (data.length > 0) {
          this.pageState = DefaultStateEnum.NORMAL
        } else {
          this.pageState = DefaultStateEnum.EMPTY
        }
        this.collectionsList.pushArrayData(data)

      })
      .catch((msg: string) => {
        this.msgError = msg
        this.pageState = DefaultStateEnum.ERROR
      })
  }

  private handleCancelCollect(item: CommonArticlesBean, index: number) {
    mCollectViewModel.handleCancelCollectWeb(item.id)
      .then((data: ResponseResultC<''>) => {
        if (data.errorCode === 0) {
          ToastUtil.showToast('已取消收藏')
          this.collectionsList.deleteData(index)
          this.collectionsList.reloadData()
          if (this.collectionsList.isEmpty()) {
            this.pageState = DefaultStateEnum.EMPTY
          }
        } else {
          ToastUtil.showToast('取消收藏失败')
        }
      })
      .catch((msg: string) => {
        ToastUtil.showToast(msg)
      })
  }

  @Builder
  ContentListView(scroller: Scroller) {

    List({ scroller: scroller }) {
      LazyForEach(this.collectionsList, (item: CommonArticlesBean, index: number) => {
        ListItem() {
          CollectionWebItemView({
            item: item,
            index: index,
            onCollectRemove: (data: CommonArticlesBean, i: number) => {
              this.handleCancelCollect(data, i)
            },
            onCollectEdit: (data: CommonArticlesBean, i: number) => {
              this.isUpdateHandle = true
              this.collectTitle = data.name
              this.collectLink = data.link
              this.editCollectDialogController.open()
            }
          })
            .onClick(() => {
              WebViewPage.startPage(this.appPathStack,item.link, true, item.name)
            })
        }
        .margin({ top: index == 0 ? 16 : 8, bottom: 8 })
        .padding({ left: 15, right: 15 })
      }, (item: CommonArticlesBean) => JSON.stringify(item))
    }.width('100%')
    .cachedCount(4)
    .onScrollStart(() => {
      this.isShowCollectButton = false
    })
    .onScrollStop(() => {
      this.isShowCollectButton = true
    })
  }
}

@Component
struct CollectionWebItemView {
  @ObjectLink
  item: CommonArticlesBean
  index: number = 0
  onCollectRemove?: (data: CommonArticlesBean, index: number) => void
  onCollectEdit?: (data: CommonArticlesBean, index: number) => void

  build() {
    Row() {
      Column({ space: 15 }) {
        Text(this.item.name)
          .fontColor(Color.Black)
          .fontSize(13)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineSpacing(LengthMetrics.vp(3))
        Text(this.item.link)
          .fontColor($r('app.color.app_theme_color'))
          .fontSize(13)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }.layoutWeight(1)
      .margin({ right: 10 })
      .alignItems(HorizontalAlign.Start)

      Image($r('app.media.ic_edit_collect'))
        .width(18)
        .height(18)
        .objectFit(ImageFit.Fill)
        .onClick(() => {
          this.onCollectEdit?.(this.item, this.index)
        })
      Image($r('app.media.ic_remove_collect'))
        .width(18)
        .margin({ left: 10 })
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