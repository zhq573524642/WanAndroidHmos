import { RouterUtil, ToastUtil } from "utils";
import { router } from "@kit.ArkUI";
import { BasePage } from "commons";
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum";
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh";
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource";
import { CommonArticlesBean, CommonPagingBean } from "lib_components";
import mSystemsViewModel from "../viewmodel/SystemsViewModel";
import { WebViewPage } from "lib_web";
import { SystemsChildItemView } from "./SystemsChildPage";

@Entry({ routeName: 'SystemsSearchPage' })
@Component
export struct SystemsSearchPage {
  static startPage() {
    RouterUtil.pushNamedRoute('SystemsSearchPage')
  }

  @State pageState: DefaultStateEnum = DefaultStateEnum.NORMAL
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State dataList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State pageIndex: number = 0
  @State isAllLoadOver: boolean = false
  @State inputContent: string = ''

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
        Search({ placeholder: '请输入作者昵称' })
          .searchButton('搜索')
          .fontColor(Color.Black)
          .onSubmit((value: string) => {
            if (value.length <= 0) {
              ToastUtil.showToast('请输入作者昵称')
              return
            }
            this.inputContent=value
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
          this.ListView(_scroller)
        },
        onRefreshing: () => {
          this.pageIndex = 0
          this.requestSearch()
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
          this.requestSearch()
        }
      })
        .width('100%')
        .layoutWeight(1)
    }.width('100%')
    .height('100%')
  }

  private requestSearch() {
    mSystemsViewModel.getSearchAuthorData(this.pageIndex,this.inputContent)
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
  ListView(_scroller: Scroller) {
    List({ scroller: _scroller, space: 12 }) {
      LazyForEach(this.dataList, (item: CommonArticlesBean, index: number) => {
        ListItem() {
          SystemsChildItemView({
            item: item
          })
        }.margin({ left: 20, right: 20 })
        .onClick(() => {
          WebViewPage.startPage(item.link, true, item.title)
        })
      }, (item: CommonArticlesBean) => item.id + '')
    }.width('100%')
    .margin({ bottom: 20 })
    .layoutWeight(1)
    .cachedCount(4)
  }
}