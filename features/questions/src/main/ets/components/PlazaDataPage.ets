import { BasePage } from "commons/src/main/ets/base/BasePage"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import {
  ArticleFromType,
  CommonArticleItem,
  CommonArticlesBean,
  CommonPagingBean,
  CommonShareArticlePage,
  FeatureUtils,
  PageTitleComponent
} from "lib_components"
import { ResponseResultC, RouterUtil } from "utils"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { ToastUtil } from "utils/src/main/ets/utils/ToastUtil"
import mPlazaViewModel from "../viewmodel/PlazaViewModel"
import { router } from "@kit.ArkUI"
import { WebViewPage } from "lib_components/src/main/ets/components/WebViewPage"

@Component
struct PlazaDataPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State pageIndex: number = 1
  @State isAllLoadOver: boolean = false
  @State dataList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State cid: string = ''
  @State msgError: string = '数据异常'
  navPathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.getPlazaList()
  }

  build() {
    NavDestination() {
      Column() {
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
            this.getPlazaList()
          },
          onLoadingMore: () => {
            if (this.isAllLoadOver) {
              ToastUtil.showToast('暂无更多数据')
              this.loadMoreStatus = FooterLoadMoreStatus.hidden
              return
            }
            this.getPlazaList()
          },
          onErrorRetryCallback: () => {
            this.getPlazaList()
          }
        })
      }.width('100%')
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .height('100%')
    }.mode(NavDestinationMode.STANDARD)
    .title('广场')
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context?.pathStack
    })
    .padding({
      top: AppStorage.get<number>('statusBarHeight'),
      bottom: AppStorage.get<number>('naviIndicatorHeight')
    })
  }

  @Builder
  ContentListView(scroller: Scroller) {
    List({ scroller: scroller }) {
      LazyForEach(this.dataList, (item: CommonArticlesBean, index: number) => {
        ListItem() {
          CommonArticleItem({
            item: item,
            onArticleAuthorClick: (isAuthor: boolean) => {
              if (isAuthor) {
                CommonShareArticlePage.startPage(this.navPathStack, ArticleFromType.ArticleByAuthor, item.userId,
                  '作者:' + item.author, item.author)
              } else {
                CommonShareArticlePage.startPage(this.navPathStack, ArticleFromType.ArticleByOther, item.userId,
                  '分享人:' + item.shareUser)
              }
            },
            onArticleCollect: (isCollected: boolean) => {
              this.handleCollectArticle(item, index, !isCollected)
            }
          })
            .onClick(() => {
              WebViewPage.startPage(this.navPathStack,item.link, true, item.title)
            })
            .margin({
              left: 15,
              right: 15,
              top: index == 0 ? 16 : 8,
              bottom: 8
            })
        }

      }, (item: CommonArticlesBean) => item.id + '-' + item.collect)
    }.width('100%')
    .layoutWeight(1)
    .cachedCount(3)
  }

  private getPlazaList() {
    mPlazaViewModel.getPlazaDataList(this.pageIndex)
      .then((data: CommonPagingBean<CommonArticlesBean>) => {
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        this.isAllLoadOver = data.over
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

  private handleCollectArticle(item: CommonArticlesBean, index: number, isCollect: boolean) {
    mPlazaViewModel.showLoading()
    FeatureUtils.getInstance().handleCollectArticle(item.id, isCollect)
      .then((data: ResponseResultC<''>) => {
        mPlazaViewModel.hideLoading()
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
        mPlazaViewModel.hideLoading()
        ToastUtil.showToast(msg)
      })
  }
}

@Builder
export function PlazaDataPageBuilder() {
  PlazaDataPage()
}