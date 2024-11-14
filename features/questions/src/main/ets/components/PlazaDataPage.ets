import { BasePage } from "commons/src/main/ets/base/BasePage"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import {
  ArticleFromType,
  CommonArticleItem,
  CommonArticlesBean,
  CommonPagingBean,
  CommonShareArticlePage,
  PageTitleComponent
} from "lib_components"
import { RouterUtil } from "utils"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { ToastUtil } from "utils/src/main/ets/utils/ToastUtil"
import mPlazaViewModel from "../viewmodel/PlazaViewModel"
import { router } from "@kit.ArkUI"
import { WebViewPage } from "lib_components/src/main/ets/components/WebViewPage"

@Entry({ routeName: 'PlazaDataPage' })
@Component
export struct PlazaDataPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State pageIndex: number = 1
  @State isAllLoadOver: boolean = false
  @State dataList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State cid: string = ''
  @State msgError: string = '数据异常'

  static startPage() {
    RouterUtil.pushNamedRoute('PlazaDataPage')
  }

  aboutToAppear(): void {
    this.getPlazaList()
  }

  build() {
    Column() {
      PageTitleComponent({
        title: '广场',
        isShowLeftIcon: true,
        onLeftIconClick: () => {
          router.back()
        }
      })
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
  }

  @Builder
  ContentListView(scroller: Scroller) {
    List({ scroller: scroller }) {
      LazyForEach(this.dataList, (item: CommonArticlesBean, index: number) => {
        ListItem(){
          CommonArticleItem({
            item: item,
            onArticleAuthorClick: (isAuthor: boolean) => {
              if (isAuthor) {
                CommonShareArticlePage.startPage(ArticleFromType.ArticleByAuthor, item.userId, '作者:' + item.author)
              } else {
                CommonShareArticlePage.startPage(ArticleFromType.ArticleByOther, item.userId, '分享人:' + item.shareUser)
              }
            }
          })
            .onClick(()=>{
               WebViewPage.startPage(item.link,true,item.title)
            })
            .margin({
              left: 15,
              right: 15,
              top: index == 0 ? 16 : 8,
              bottom: 8
            })
        }

      }, (item: CommonArticlesBean) => item.id)
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
}