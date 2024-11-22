import { BasePage } from "commons/src/main/ets/base/BasePage"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { CommonPagingBean, FeatureUtils } from "lib_components"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { ToastUtil } from "utils/src/main/ets/utils/ToastUtil"
import { MessageBean } from "../model/MessageBean"
import mMessageViewModel from "../viewmodel/MessageViewModel"
import { LengthMetrics } from "@kit.ArkUI"
import { WebViewPage } from "lib_components/src/main/ets/components/WebViewPage"

@Component
export struct MessageListPage {
  isRead: boolean = false
  @Consume('appPathStack') appPathStack: NavPathStack
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State pageIndex: number = 1
  @State isAllLoadOver: boolean = false
  @State dataList: LazyDataSource<MessageBean> = new LazyDataSource()
  @State msgError: string = '数据异常'

  aboutToAppear(): void {
    this.getMsgList()
  }

  build() {
    Column() {
      BasePage({
        pageState: this.pageState,
        refreshStatus: this.refreshStatus,
        loadMoreStatus: this.loadMoreStatus,
        msgError: this.msgError,
        ContentViewPage: (_scroller: Scroller) => {
          this.ItemListView(_scroller)
        },
        onRefreshing: () => {
          this.pageIndex = 1
          this.getMsgList()
        },
        onLoadingMore: () => {
          if (this.isAllLoadOver) {
            this.loadMoreStatus = FooterLoadMoreStatus.inactive
            ToastUtil.showToast('暂无更多数据')
            return
          }
          this.getMsgList()
        }
      })
    }.width('100%')
    .backgroundColor(FeatureUtils.getGrayBgColor())
    .layoutWeight(1)
  }

  private getMsgList() {
    mMessageViewModel.getMsgList(this.isRead, this.pageIndex)
      .then((data: CommonPagingBean<MessageBean>) => {
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        this.isAllLoadOver = data.over
        if (data.total > 0) {
          this.pageState = DefaultStateEnum.NORMAL
        } else {
          this.pageState = DefaultStateEnum.EMPTY
        }
        if (data.curPage == 1) {
          this.pageIndex
          this.dataList.clear()
        }
        this.pageIndex++
        this.dataList.appendArrayData(data.datas)

      })
      .catch((msg: string) => {
        this.msgError = msg
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        this.pageState = DefaultStateEnum.ERROR
      })
  }

  @Builder
  ItemListView(scroller: Scroller) {
    List({ scroller: scroller }) {
      LazyForEach(this.dataList, (item: MessageBean, index: number) => {
        ListItem() {
          MessageItem({
            item: item
          })
            .onClick(()=>{
              WebViewPage.startPage(this.appPathStack,item.fullLink,true,item.title)
            })
        }
        .margin({
          left: 20,
          right: 20,
          top: index == 0 ? 16 : 8,
          bottom: 16
        })
      }, (item: MessageBean) => item.id)
    }
  }
}

@Component
struct MessageItem {
  item: MessageBean = new MessageBean()

  build() {
    Column() {
      Row() {
        if (this.item.tag.length > 0) {
          Text(this.item.tag)
            .fontColor(Color.Green)
            .fontSize(11)
            .padding({
              left: 6,
              right: 6,
              top: 4,
              bottom: 4
            })
            .borderRadius(3)
            .borderColor(Color.Green)
            .borderWidth(1)
            .margin({ right: 6 })

        }
        Blank().layoutWeight(1)
        Text(this.item.niceDate).fontColor(Color.Gray).fontSize(12)
      }.alignItems(VerticalAlign.Center)

      Text() {
        Span(`@${this.item.fromUser}`).fontColor($r('app.color.app_theme_color'))
          .fontSize(15)
        Span(this.item.title)
          .fontColor(Color.Black)
          .fontSize(15)
      }
      .maxLines(2)
      .lineSpacing(LengthMetrics.vp(2))
      .width('100%')
      .textAlign(TextAlign.Start)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .margin({ top: 10, bottom: 10 })

      Text(this.item.message)
      .fontColor($r('app.color.app_theme_color'))
      .fontSize(13)
      .width('100%')
      .maxLines(2)
      .lineSpacing(LengthMetrics.vp(2))
      .textAlign(TextAlign.Start)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .margin({ top: 10, bottom: 10 })

    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .borderRadius(10)
    .backgroundColor(Color.White)
    .padding(15)
  }
}