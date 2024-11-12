import { BasePage } from "commons"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { CommonPagingBean, PageTitleComponent } from "lib_components"
import { RouterUtil } from "utils"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { IntegralBean } from "../model/IntegralBean"
import mIntegralViewModel from "../viewmodel/IntegralViewModel"

@Entry({ routeName: 'IntegralPage' })
@Component
export struct IntegralPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.hidden
  @State dataList: LazyDataSource<IntegralBean> = new LazyDataSource()
  @State pageIndex: number = 1
  @State isAllLoadOver: boolean = false

  static startPage() {
    RouterUtil.pushNamedRoute('IntegralPage')
  }

  aboutToAppear(): void {
    this.getIntegralRankList()
  }

  build() {
    Column() {
      PageTitleComponent({
        title: '积分',
        isShowRightText: true,
        rightText: '记录',
        onRightTextClick: () => {

        }
      })
      BasePage({
        pageState: this.pageState,
        refreshStatus: this.refreshStatus,
        loadMoreStatus: this.loadMoreStatus,
        ContentViewPage: (_scroller: Scroller) => {
          this.ContentView(_scroller)
        },
        onRefreshing: () => {
          this.pageIndex = 1
          this.getIntegralRankList()
        }
      })
        .layoutWeight(1)

    }.width('100%')
    .justifyContent(FlexAlign.Start)
    .height('100%')
    .backgroundColor(Color.White)
  }

  private getIntegralRankList() {
    mIntegralViewModel.getIntegralRankList(this.pageIndex)
      .then((data: CommonPagingBean<IntegralBean>) => {
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
        this.pageState = DefaultStateEnum.ERROR
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
      })
  }

  @Builder
  ContentView(scroller: Scroller) {
    Column() {
      List({ scroller: scroller }) {
        LazyForEach(this.dataList, (item: IntegralBean) => {
          ListItem() {
            RankItemView({
              item: item
            })
          }
        }, (item: IntegralBean) => item.userId)
      }.divider({ strokeWidth: 1, startMargin: 20, endMargin: 20,color:'#F5F5F5' })
    }
  }
}

@Component
struct RankItemView {
  item: IntegralBean = new IntegralBean()

  build() {
    Row() {
      Text(this.item.rank + '')
        .fontColor(Color.Black)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
      Text(this.item.nickname !== '' ? this.item.nickname : this.item.username)
        .fontColor(Color.Black)
        .fontSize(15)
        .margin({ left: 12 })
      Text('lv:' + this.item.level).fontColor(Color.Green).fontSize(13).margin({ left: 8 })
      Blank().layoutWeight(1)
      Image($r('app.media.ic_integral_coin')).width(20).height(20)
      Text(this.item.coinCount + '').fontColor('#f4ea2a').fontSize(13).margin({ left: 4 })
    }.width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({
      left: 20,
      right: 20,
      top: 15,
      bottom: 15
    })
  }
}