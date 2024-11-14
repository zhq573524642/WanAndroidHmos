import { BasePage } from "commons"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { NavigationData } from "../model/NavigationData"
import mNavigationViewModel from "../viewmodel/NavigationViewModel"
import { LengthMetrics } from "@kit.ArkUI"
import { CommonArticlesBean, FeatureUtils } from "lib_components"
import { WebViewPage } from "lib_components/src/main/ets/components/WebViewPage"

@Component
export struct NavigationPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.hidden
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.hidden
  @State dataList: LazyDataSource<NavigationData> = new LazyDataSource()

  aboutToAppear(): void {
    this.requestNavigationData()
  }

  build() {
    Column() {
      BasePage({
        pageState: this.pageState,
        refreshStatus: this.refreshStatus,
        loadMoreStatus: this.loadMoreStatus,
        ContentViewPage: (_scroller: Scroller) => {
          this.ContentListView(_scroller)
        },
        onErrorRetryCallback: () => {

        }
      })
        .layoutWeight(1)
        .width('100%')

    }.width('100%')
    .height('100%')
  }

  private requestNavigationData() {
    mNavigationViewModel.getNavigationData()
      .then((data: Array<NavigationData>) => {
        this.pageState = DefaultStateEnum.NORMAL
        this.dataList.pushArrayData(data)
      })
      .catch((msg: string) => {
        this.pageState = DefaultStateEnum.ERROR
      })
  }

  @Builder
  ContentListView(_scroller: Scroller) {
    Scroll(_scroller) {
      Column() {
        LazyForEach(this.dataList, (item: NavigationData) => {
          Column({ space: 15 }) {
            Text(item.name).fontColor(Color.Black).fontSize(16).fontWeight(FontWeight.Bold)
            Flex({
              wrap: FlexWrap.Wrap,
              direction: FlexDirection.Row,
              space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) }
            }) {
              ForEach(item.articles, (article: CommonArticlesBean) => {
                Text(article.title).fontColor(FeatureUtils.getRandomColor())
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .onClick(() => {
                    WebViewPage.startPage(article.link,true,article.title)
                  })
              }, (article: CommonArticlesBean) => article.id + '')
            }.width('100%')
          }
          .padding({ left: 20, right: 20, top: 20 })
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }, (item: NavigationData) => item.cid + '')
      }.width('100%')
    }.width('100%')
    .layoutWeight(1)
  }
}