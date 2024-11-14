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
import { CommonPagingBean } from "../model/CommonPagingBean"

export enum ArticleFromType {
  ArticleByOther = 1,
  ArticleByAuthor,
  ArticleBySelf,
  ArticleByOfficialAccount,
  ArticleBySearch
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
  @State articleFromType: ArticleFromType = ArticleFromType.ArticleByOther
  @State userCoinInfo: CoinInfo = new CoinInfo()
  @State totalArticles: number = 0
  @State isShowUserInfo: boolean = false
  @State isShowSearchIcon: boolean = false
  @State isShowSearchLayout: boolean = false
  //临时保存一下数据
  @State tempDataList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State tempPageIndex: number = 1
  @State tempIsAllLoadOver: boolean = false
  @State inputContent: string = ''

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
      this.articleFromType = params.articleFromType as ArticleFromType
    }
    this.getRequestByFromType()
  }

  private getRequestByFromType() {
    if (this.articleFromType == ArticleFromType.ArticleByOther) {
      this.isShowUserInfo = true
      this.getShareArticleList()
    } else if (this.articleFromType == ArticleFromType.ArticleByAuthor) {

    } else if (this.articleFromType == ArticleFromType.ArticleBySelf) {

    } else if (this.articleFromType == ArticleFromType.ArticleByOfficialAccount) {
      this.isShowUserInfo = false
      this.isShowSearchIcon = true
      this.getOfficialAccountArticleList()
    } else if (this.articleFromType == ArticleFromType.ArticleBySearch) {
      this.getArticleSearch()
    }
  }

  build() {
    Column() {
      PageTitleComponent({
        title: this.userTitle,
        isShowLeftIcon: true,
        onLeftIconClick: () => {
          router.back()
        },
        isShowRightIcons: this.isShowSearchIcon,
        rightIcons: [$r('app.media.ic_search')],
        onRightIconClick: (icon: ResourceStr, index: number) => {
          this.isShowSearchLayout = !this.isShowSearchLayout
        }
      })

      if (this.isShowSearchLayout) {
        Row() {
          Search({ placeholder: '请输入搜索关键词' })
            .searchButton('搜索')
            .fontColor(Color.Black)
            .onChange((value: string) => {
              if (value === '') {
                this.articleFromType = ArticleFromType.ArticleByOfficialAccount
                this.dataList.clear()
                this.tempDataList.dataArray.forEach((value:CommonArticlesBean)=>{
                  this.dataList.pushData(value)
                })
                this.pageIndex = this.tempPageIndex
                this.isAllLoadOver = this.tempIsAllLoadOver
                this.dataList.notifyDataReload()
              }
            })
            .onSubmit((value: string) => {
              if (value.length <= 0) {
                ToastUtil.showToast('请输入搜索关键词')
                return
              }
              this.articleFromType = ArticleFromType.ArticleBySearch
              this.dataList.dataArray.forEach((value:CommonArticlesBean)=>{
                this.tempDataList.pushData(value)
              })
              this.tempPageIndex = this.pageIndex
              this.tempIsAllLoadOver = this.isAllLoadOver

              this.pageIndex = 1
              this.inputContent = value
              this.getRequestByFromType()
            })
            .height(50)
            .layoutWeight(1)
        }.padding({ left: 20, right: 20 })
        .width('100%')
      }
      if (this.isShowUserInfo) {
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
      }

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
          this.getRequestByFromType()
        },
        onLoadingMore: () => {
          if (this.isAllLoadOver) {
            ToastUtil.showToast('暂无更多数据')
            this.loadMoreStatus = FooterLoadMoreStatus.inactive
            return
          }
          this.getRequestByFromType()
        },
        onErrorRetryCallback: () => {
          this.getRequestByFromType()
        }
      })
    }.width('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .height('100%')
  }

  private getShareArticleList() {
    this.mCommonViewModel.getShareArticlesList(this.userId, this.pageIndex)
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
          this.pageIndex = 1
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

  private getOfficialAccountArticleList() {
    this.mCommonViewModel.getWxArticlesList(this.userId, this.pageIndex)
      .then((data: CommonPagingBean<CommonArticlesBean>) => {
        this.isAllLoadOver = data.over
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
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
        this.msgError = msg
        this.pageState = DefaultStateEnum.ERROR
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
      })
  }

  private getArticleSearch() {
    this.mCommonViewModel.getSearchWxArticlesList(this.userId, this.pageIndex, this.inputContent)
      .then((data: CommonPagingBean<CommonArticlesBean>) => {
        this.isAllLoadOver = data.over
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
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