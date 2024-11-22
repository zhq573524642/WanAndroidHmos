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
import { FeatureUtils } from "../FeatureUtils"

export enum ArticleFromType {
  ArticleByOther = 1,
  ArticleByAuthor,
  ArticleBySelf,
  ArticleByOfficialAccount,
  ArticleBySearch
}

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
  @State authorName: string = ''
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
  navPathStack: NavPathStack = new NavPathStack()

  static startPage(navPathStack: NavPathStack, fromType: ArticleFromType, userId: number, title: string,
    authorName?: string) {
    navPathStack.pushPathByName('CommonShareArticlePage', new Object({
      "articleFromType": fromType,
      "userId": userId,
      "title": title,
      "authorName": authorName ? authorName : ''
    }))
  }

  private getRequestByFromType() {

    if (this.articleFromType == ArticleFromType.ArticleByOther) {
      //分享人分享的文章列表
      //页面从1开始
      //显示分享人的基本数据信息
      this.pageIndex = 1
      this.isShowUserInfo = true
      this.getShareArticleList()
    } else if (this.articleFromType == ArticleFromType.ArticleByAuthor) {
      //作者的文章列表（按作者名称搜索）
      //页面从0开始
      //不显示作者的基本信息
      this.pageIndex = 0
      this.getArticleListByAuthorName()
    } else if (this.articleFromType == ArticleFromType.ArticleBySelf) {

    } else if (this.articleFromType == ArticleFromType.ArticleByOfficialAccount) {
      //公众号对应文章列表
      //页面从1开始
      //不显示公众号的基本信息
      //显示在本公众号列表搜索
      this.pageIndex = 1
      this.isShowUserInfo = false
      this.isShowSearchIcon = true
      this.getOfficialAccountArticleList()
    } else if (this.articleFromType == ArticleFromType.ArticleBySearch) {
      this.getWxArticleSearch()
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isShowSearchLayout) {
          Row() {
            Search({ placeholder: '请输入搜索关键词' })
              .searchButton('搜索')
              .fontColor(Color.Black)
              .onChange((value: string) => {
                if (value === '') {
                  this.articleFromType = ArticleFromType.ArticleByOfficialAccount
                  this.dataList.clear()
                  this.tempDataList.dataArray.forEach((value: CommonArticlesBean) => {
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
                this.dataList.dataArray.forEach((value: CommonArticlesBean) => {
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
          isNeedRetry: true,
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
    }.mode(NavDestinationMode.STANDARD)
    .menus([
      {
        value: '搜索',
        icon: 'resources/base/media/ic_search.png',
        action: () => {
          this.isShowSearchLayout = !this.isShowSearchLayout
        }
      }
    ])
    .title(this.userTitle)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context?.pathStack
      let params = context?.pathInfo?.param as Record<string, Object>
      if (params) {
        this.userId = params.userId as number
        this.userTitle = params.title as string
        this.articleFromType = params.articleFromType as ArticleFromType
        this.authorName = params.authorName as string
        this.getRequestByFromType()
      }
    })
    .padding({
      top: AppStorage.get<number>('statusBarHeight'),
      bottom: AppStorage.get<number>('naviIndicatorHeight')
    })
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

  private getWxArticleSearch() {
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

  private getArticleListByAuthorName() {
    this.mCommonViewModel.getArticlesListByAuthorName(this.pageIndex, this.authorName)
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
          this.pageIndex = 0
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
            item: item,
            onArticleCollect: (isCollected: boolean) => {
              if (isCollected) {
                this.handleCollectArticle(item, index, false)
              } else {
                this.handleCollectArticle(item, index, true)
              }
            }
          })
            .margin({
              left: 15,
              right: 15,
              top: index == 0 ? 16 : 8,
              bottom: 8
            })
            .onClick(() => {
              WebViewPage.startPage(this.navPathStack,item.link, true, item.title)
            })
        }

      }, (item: CommonArticlesBean) => item.id + '-' + item.collect)
    }.width('100%')
    .layoutWeight(1)
    .cachedCount(4)
  }

  private handleCollectArticle(item: CommonArticlesBean, index: number, isCollect: boolean) {
    this.mCommonViewModel.showLoading()
    FeatureUtils.getInstance().handleCollectArticle(item.id, isCollect)
      .then((data: ResponseResultC<''>) => {
        this.mCommonViewModel.hideLoading()
        if (data.errorCode === 0) {
          ToastUtil.showToast(isCollect ? '收藏成功' : '取消收藏成功')
          let updateItem = new CommonArticlesBean()
          updateItem = item
          updateItem.collect = isCollect
          this.dataList.changeData(index, updateItem)
        } else {
          ToastUtil.showToast(isCollect ? '收藏失败' : '取消收藏失败')
        }
      })
      .catch((msg: string) => {
        this.mCommonViewModel.hideLoading()
        ToastUtil.showToast(msg)
      })
  }
}

@Builder
export function CommonShareArticlePageBuilder() {
  CommonShareArticlePage()
}