import {
  ArticleFromType,
  CommonArticleItem,
  CommonArticlesBean,
  CommonPagingBean,
  CommonShareArticlePage,
  FeatureUtils,
  PageTitleComponent
} from 'lib_components'
import { RouterUtil } from 'utils/src/main/ets/utils/RouterUtil'
import { LengthMetrics, router } from '@kit.ArkUI'
import { BasePage } from 'commons/src/main/ets/base/BasePage'
import { DefaultStateEnum } from 'commons/src/main/ets/components/defaultState/DefaultStateEnum'
import { FooterLoadMoreStatus, HeaderRefreshStatus } from 'commons/src/main/ets/components/SVRefresh/SVRefresh'
import mSystemsViewModel from '../viewmodel/SystemsViewModel'
import LazyDataSource from 'utils/src/main/ets/utils/LazyDataSource'
import { ResponseResultC, ToastUtil } from 'utils'
import { WebViewPage } from 'lib_components/src/main/ets/components/WebViewPage'


@Component
struct SystemsChildPage {
  @State title: string = ''
  @State itemId: number = 0
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State dataList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State pageIndex: number = 0
  @State isAllLoadOver: boolean = false
  navPathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
        BasePage({
          pageState: this.pageState,
          isNeedRetry: true,
          refreshStatus: this.refreshStatus,
          loadMoreStatus: this.loadMoreStatus,
          ContentViewPage: (_scroller: Scroller) => {
            this.ListView(_scroller)
          },
          onRefreshing: () => {
            this.pageIndex = 0
            this.getSystemsChildList()
          },
          onLoadingMore: () => {
            if (this.isAllLoadOver) {
              this.loadMoreStatus = FooterLoadMoreStatus.inactive
              ToastUtil.showToast('暂无更多数据')
              return
            }
            this.getSystemsChildList()
          },
          onErrorRetryCallback: () => {
            this.getSystemsChildList()
          }
        })
          .width('100%')
          .layoutWeight(1)
      }.width('100%')
      .backgroundColor('#f5f5f5')
    }.title(this.title)
    .menus([
      {
        value: '搜索',
        icon: 'resources/base/media/ic_search.png',
        action: () => {
          this.navPathStack.pushPathByName('SystemsSearchPage','',true)
        }
      }
    ])
    .mode(NavDestinationMode.STANDARD)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context?.pathStack
      let params = context?.pathInfo?.param as Record<string, Object>
      if (params) {
        this.title = params['title'] as string
        this.itemId = params['itemId'] as number
      }
      this.getSystemsChildList()
    })
    .padding({
      top: AppStorage.get<number>('statusBarHeight'),
      bottom: AppStorage.get<number>('naviIndicatorHeight')
    })

  }

  private getSystemsChildList() {
    mSystemsViewModel.getSystemsChildList(this.pageIndex, this.itemId)
      .then((data: CommonPagingBean<CommonArticlesBean>) => {
        if (data.total === 0) {
          this.pageState = DefaultStateEnum.EMPTY
        } else {
          this.pageState = DefaultStateEnum.NORMAL
        }
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        this.isAllLoadOver = data.over
        if (this.pageIndex == 0) {
          this.dataList.clear()
        }
        this.pageIndex++
        this.dataList.appendArrayData(data.datas)
      })
      .catch((msg: string) => {
        ToastUtil.showToast(msg)
        this.pageState = DefaultStateEnum.ERROR
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
      })
  }

  @Builder
  ListView(scroller: Scroller) {
    List({ scroller: scroller }) {
      LazyForEach(this.dataList, (item: CommonArticlesBean, index: number) => {
        ListItem() {
          CommonArticleItem({
            item: item,
            isShowChapterName: false,
            onArticleAuthorClick: (isAuthor: boolean) => {
              if (isAuthor) {
                CommonShareArticlePage.startPage(this.navPathStack, ArticleFromType.ArticleByAuthor, item.userId,
                  item.title, item.author)
              } else {
                CommonShareArticlePage.startPage(this.navPathStack, ArticleFromType.ArticleByOther, item.userId,
                  item.title)
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
            .onClick(() => {
              WebViewPage.startPage(this.navPathStack,item.link, true, item.title)
            })
        }
        .margin({
          left: 20,
          right: 20,
          top: index == 0 ? 16 : 8,
          bottom: 8
        })

      }, (item: CommonArticlesBean) => item.id + '-' + item.collect)
    }.width('100%')
    .layoutWeight(1)
    .cachedCount(4)
  }

  private handleCollectArticle(item: CommonArticlesBean, index: number, isCollect: boolean) {
    mSystemsViewModel.showLoading()
    FeatureUtils.getInstance().handleCollectArticle(item.id, isCollect)
      .then((data: ResponseResultC<''>) => {
        mSystemsViewModel.hideLoading()
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
        mSystemsViewModel.hideLoading()
        ToastUtil.showToast(msg)
      })
  }
}

@Builder
export function SystemsChildPageBuilder() {
  SystemsChildPage()
}