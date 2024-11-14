import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { CommonArticlesBean } from "../model/CommonArticlesBean"
import { PageTitleComponent } from "./PageTitleComponent"
import { router } from "@kit.ArkUI"
import { BasePage } from "commons"
import { httpARequestGet, ResponseResultC, RouterUtil, ToastUtil } from "utils"
import { CommonArticleItem } from "./CommonArticleItem"
import { CoinInfo, CommonUserArticlesBean } from "../model/CommonUserArticlesBean"
import { CommonViewModel } from "../viewmodel/CommonViewModel"
import { WebViewPage } from "./WebViewPage"

export enum ArticleFromType {
  ArticleByOther = 1,
  ArticleByAuthor,
  ArticleBySelf
}

@Entry({ routeName: 'CommonShareArticlePage' })
@Component
export struct CommonShareArticlePage {
  @State mCommonViewModel: CommonViewModel = CommonViewModel.getInstance()
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State pageIndex: number = 1
  @State isAllLoadOver: boolean = false
  @State dataList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State cid: string = ''
  @State msgError: string = '数据异常'
  @State userId: number = 0
  @State userTitle: string = ''
  @State userCoinInfo: CoinInfo = new CoinInfo()
  @State totalArticles: number = 0

  static startPage(fromType: ArticleFromType, userId: number, title: string) {
    RouterUtil.pushNamedRoute('CommonShareArticlePage', {
      "articleFromType": fromType,
      "userId": userId,
      "title": title
    })
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      this.userId = params.userId as number
      this.userTitle = params.title as string
    }
    this.getShareArticleList()
  }

  build() {
    Column() {
      PageTitleComponent({
        title: this.userTitle,
        isShowLeftIcon: true,
        onLeftIconClick: () => {
          router.back()
        }
      })
      Column({ space: 12 }) {
        Row() {
          Text('本站积分：').fontColor(Color.Black).fontSize(15)
          Text(`${this.userCoinInfo.coinCount}`).fontColor(Color.Red).fontSize(16)
          Text(`lv ${this.userCoinInfo.level}`)
            .fontSize(15)
            .fontColor(Color.White)
            .backgroundColor(Color.Green)
            .padding({
              top: 4,
              bottom: 4,
              left: 7,
              right: 7
            })
            .margin({ left: 12 })
            .borderRadius(5)
          Text(`排名 ${this.userCoinInfo.rank}`)
            .fontSize(15)
            .fontColor(Color.White)
            .backgroundColor(Color.Pink)
            .padding({
              top: 4,
              bottom: 4,
              left: 7,
              right: 7
            })
            .margin({ left: 12 })
            .borderRadius(5)
        }

        Text(`分享了${this.totalArticles}篇文章`).fontColor(Color.Gray).fontSize(15)

      }.padding(20)
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      BasePage({
        pageState: this.pageState,
        refreshStatus: this.refreshStatus,
        loadMoreStatus: this.loadMoreStatus,
        msgError: this.msgError,
        ContentViewPage: (_scroller: Scroller) => {
          this.ContentListView(_scroller)
        },
        onRefreshing: () => {
          this.pageIndex = 1
          this.getShareArticleList()
        },
        onLoadingMore: () => {
          if (this.isAllLoadOver) {
            ToastUtil.showToast('暂无更多数据')
            this.loadMoreStatus = FooterLoadMoreStatus.inactive
            return
          }
          this.getShareArticleList()
        },
        onErrorRetryCallback: () => {
          this.getShareArticleList()
        }
      })
    }.width('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .height('100%')
  }

  private getShareArticleList() {
    this.mCommonViewModel.getArticlesList(this.userId, this.pageIndex)
      .then((data: CommonUserArticlesBean) => {
        this.userCoinInfo = data.coinInfo
        let bean = data.shareArticles
        this.isAllLoadOver = bean.over
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        this.totalArticles = bean.total
        if (bean.total > 0) {
          this.pageState = DefaultStateEnum.NORMAL
        } else {
          this.pageState = DefaultStateEnum.EMPTY
        }
        if (bean.curPage == 1) {
          this.pageIndex = 0
          this.dataList.clear()
        }
        this.pageIndex++
        this.dataList.appendArrayData(bean.datas)
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
      LazyForEach(this.dataList, (item: CommonArticlesBean, index: number) => {
        ListItem() {
          CommonArticleItem({
            item: item
          })
            .margin({
              left: 15,
              right: 15,
              top: index == 0 ? 16 : 8,
              bottom: 8
            })
            .onClick(() => {
              WebViewPage.startPage(item.link, true, item.title)
            })
        }

      }, (item: CommonArticlesBean) => item.id)
    }.width('100%')
    .layoutWeight(1)
    .cachedCount(3)
  }
}