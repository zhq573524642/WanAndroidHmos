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
import { SystemsSearchPage } from './SystemsSearchPage'
import { WebViewPage } from 'lib_components/src/main/ets/components/WebViewPage'

@Entry({ routeName: 'SystemsChildPage' })
@Component
export struct SystemsChildPage {
  static startPage(title: string, id: number) {
    RouterUtil.pushNamedRoute('SystemsChildPage', {
      'title': title,
      'itemId': id
    })
  }

  @State title: string = ''
  @State itemId: number = 0
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State dataList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State pageIndex: number = 0
  @State isAllLoadOver: boolean = false

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      this.title = params['title'] as string
      this.itemId = params['itemId'] as number
    }
    this.getSystemsChildList()
  }

  build() {
    Column() {
      PageTitleComponent({
        title: this.title,
        isShowLeftIcon: true,
        onLeftIconClick: () => {
          router.back()
        },
        isShowRightIcons: true,
        rightIcons: [$r('app.media.ic_search')],
        onRightIconClick: (icon: ResourceStr, index: number) => {
          SystemsSearchPage.startPage()
        }
      })
      BasePage({
        pageState: this.pageState,
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
    List({ scroller: scroller, space: 12 }) {
      LazyForEach(this.dataList, (item: CommonArticlesBean, index: number) => {
        ListItem() {
          CommonArticleItem({
            item: item,
            isShowChapterName: false,
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
            .onClick(() => {
              WebViewPage.startPage(item.link, true, item.title)
            })
        }.margin({ left: 20, right: 20 })

      }, (item: CommonArticlesBean) => item.id + '-' + item.collect)
    }.width('100%')
    .margin({ bottom: 20 })
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