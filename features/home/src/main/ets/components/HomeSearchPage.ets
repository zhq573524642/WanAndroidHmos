import { LengthMetrics, router } from "@kit.ArkUI"
import { BasePage } from "commons"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import {
  ArticleFromType,
  CommonArticleItem,
  CommonArticlesBean,
  CommonPagingBean,
  CommonShareArticlePage,
  FeatureUtils
} from "lib_components"
import { WebViewPage } from "lib_components/src/main/ets/components/WebViewPage"
import { ResponseResultC, RouterUtil, ToastUtil } from "utils"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { CommonWebSiteBean } from "../model/CommonWebSiteBean"
import { SearchHotWord } from "../model/SearchHotWordBean"
import mSearchViewModel from "../viewmodel/SearchViewModel"

@Entry({ routeName: 'HomeSearchPage' })
@Component
export struct HomeSearchPage {
  @State inputContent: string = ''
  @State pageState: DefaultStateEnum = DefaultStateEnum.NORMAL
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.hidden
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.hidden
  @State dataList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State pageIndex: number = 0
  @State isAllLoadOver: boolean = false
  @State isShowSearchResultLayout: boolean = false
  @State hotWordList: Array<SearchHotWord> = []
  @State webSiteList: Array<CommonWebSiteBean> = []

  static startPage() {
    RouterUtil.pushNamedRoute('HomeSearchPage')
  }

  aboutToAppear(): void {
    this.getSearchHotWord()
    this.getCommonWebSite()
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(30)
          .height(30)
          .objectFit(ImageFit.Fill)
          .onClick(() => {
            router.back()
          })
        Search({ placeholder: '请输入搜索内容', value: this.inputContent })
          .searchButton('搜索')
          .fontColor(Color.Black)
          .onChange((value: string, previewText: PreviewText) => {
            if (value.length <= 0) {
              this.isShowSearchResultLayout = false
            }
          })
          .onSubmit((value: string) => {
            if (value.length <= 0) {
              ToastUtil.showToast('请输入搜索内容')
              return
            }
            this.inputContent = value
            this.loadMoreStatus = FooterLoadMoreStatus.inactive
            this.requestSearch()
          })
          .height(50)
          .layoutWeight(1)
      }.padding({ left: 20, right: 20 })

      BasePage({
        pageState: this.pageState,
        refreshStatus: this.refreshStatus,
        loadMoreStatus: this.loadMoreStatus,
        ContentViewPage: (_scroller: Scroller) => {
          this.ContentView(_scroller)
        },
        onRefreshing: () => {
        },
        onLoadingMore: () => {
          if (this.isAllLoadOver) {
            this.loadMoreStatus = FooterLoadMoreStatus.inactive
            ToastUtil.showToast('暂无更多数据')
            return
          }
          this.requestSearch()
        },
        onErrorRetryCallback: () => {
          if (this.isShowSearchResultLayout) {
            this.requestSearch()
          }
        }
      })
        .width('100%')
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')

  }

  private requestSearch() {
    mSearchViewModel.getHomeArticleQuery(this.pageIndex, this.inputContent)
      .then((data: CommonPagingBean<CommonArticlesBean>) => {
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        this.isAllLoadOver = data.over
        this.isShowSearchResultLayout = data.total > 0
        if (this.pageIndex == 0) {
          this.pageIndex = 0
          this.dataList.clear()
        }
        this.pageIndex++
        this.dataList.appendArrayData(data.datas)
      })
      .catch((msg: string) => {
        ToastUtil.showToast(msg)
      })
  }

  private getSearchHotWord() {
    mSearchViewModel.getSearchHotWord()
      .then((data: Array<SearchHotWord>) => {
        this.hotWordList = data
      })
  }

  private getCommonWebSite() {
    mSearchViewModel.getCommonWebSite()
      .then((data: Array<CommonWebSiteBean>) => {
        this.webSiteList = data
      })
  }

  @Builder
  ContentView(_scroller: Scroller) {
    if (this.isShowSearchResultLayout) {
      this.ListView(_scroller)
    } else {
      this.ToolsView(_scroller)
    }
  }

  @Builder
  ListView(_scroller: Scroller) {
    List({ scroller: _scroller }) {
      LazyForEach(this.dataList, (item: CommonArticlesBean, index: number) => {
        ListItem() {
          CommonArticleItem({
            item: item,
            onArticleAuthorClick: (isAuthor: boolean) => {
              if (isAuthor) {
                CommonShareArticlePage.startPage(ArticleFromType.ArticleByAuthor, item.userId, item.title,item.author)
              } else {
                CommonShareArticlePage.startPage(ArticleFromType.ArticleByOther, item.userId, item.title)
              }
            },
            onArticleCollect: (isCollected: boolean) => {
              if (isCollected) {
                this.handleCollectArticle(item, index, false)
              } else {
                this.handleCollectArticle(item, index, true)
              }
            }
          })
            .margin({ top: index == 0 ? 16 : 8, bottom: 8 })
        }.margin({ left: 20, right: 20 })
        .onClick(() => {
          WebViewPage.startPage(item.link, true, item.title)
        })
      }, (item: CommonArticlesBean) => item.id + '-'+item.collect)
    }
    .width('100%')
    .margin({ bottom: 20, top: 15 })
    .backgroundColor('#f5f5f5')
    .layoutWeight(1)
    .cachedCount(4)
  }

  private handleCollectArticle(item: CommonArticlesBean, index: number, isCollect: boolean) {
    mSearchViewModel.showLoading()
    FeatureUtils.getInstance().handleCollectArticle(item.id, isCollect)
      .then((data: ResponseResultC<''>) => {
        mSearchViewModel.hideLoading()
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
        mSearchViewModel.hideLoading()
        ToastUtil.showToast(msg)
      })
  }

  @Builder
  ToolsView(_scroller: Scroller) {
    Scroll(_scroller) {
      Column({ space: 20 }) {
        //搜索热词
        Text('搜索热词').fontColor(Color.Black).fontSize(20)
          .margin({ left: 20, top: 30 })
        Flex({
          wrap: FlexWrap.Wrap,
          direction: FlexDirection.Row,
          space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) }
        }) {
          ForEach(this.hotWordList, (item: SearchHotWord) => {
            Text(item.name)
              .fontColor(FeatureUtils.getRandomColor())
              .fontSize(13)
              .padding({
                left: 10,
                right: 10,
                top: 5,
                bottom: 5
              })
              .borderWidth(1)
              .borderRadius(10)
              .borderColor(FeatureUtils.getRandomColor())
              .backgroundColor(Color.White)
              .onClick(() => {
                this.inputContent = item.name
              })
          }, (item: SearchHotWord) => item.id + '')
        }
        .margin({ left: 20, right: 20 })

        Text('常用网站').fontColor(Color.Black).fontSize(20)
          .margin({ left: 20, top: 30 })
        Flex({
          wrap: FlexWrap.Wrap,
          direction: FlexDirection.Row,
          space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) }
        }) {
          ForEach(this.webSiteList, (item: CommonWebSiteBean) => {
            Text(item.name)
              .fontColor(FeatureUtils.getRandomColor())
              .fontSize(13)
              .padding({
                left: 10,
                right: 10,
                top: 5,
                bottom: 5
              })
              .borderWidth(1)
              .borderRadius(10)
              .borderColor(FeatureUtils.getRandomColor())
              .backgroundColor(Color.White)
              .onClick(() => {
                WebViewPage.startPage(item.link, false, '')
              })
          }, (item: CommonWebSiteBean) => item.id + '')
        }
        .margin({ left: 20, right: 20 })
      }.width('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .height('100%')
    }.width('100%')
    .layoutWeight(1)
  }
}
