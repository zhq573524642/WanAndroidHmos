import { BasePage } from "commons"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { LengthMetrics } from "@kit.ArkUI"
import { OfficialAccountBean } from "../model/OfficialAccountBean"
import mAccountViewModel from "../viewmodel/AccountViewModel"

@Component
export struct OfficialAccountsPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.hidden
  @State msgError: string = '数据异常'
  @State accountList: Array<OfficialAccountBean> = []

  aboutToAppear(): void {
    this.getOfficialAccountList()
  }

  build() {
    Column() {
      BasePage({
        pageState: this.pageState,
        refreshStatus: this.refreshStatus,
        loadMoreStatus: this.loadMoreStatus,
        msgError: this.msgError,
        ContentViewPage: (_scroller: Scroller) => {
          this.ContentListView(_scroller)
        },
        onRefreshing: () => {
          this.getOfficialAccountList()
        },
        onErrorRetryCallback: () => {
          this.getOfficialAccountList()
        }
      })
        .layoutWeight(1)
        .width('100%')

    }.width('100%')
    .height('100%')
  }

  private getOfficialAccountList() {
    mAccountViewModel.getOfficialAccountsList()
      .then((data: Array<OfficialAccountBean>) => {
        this.refreshStatus = HeaderRefreshStatus.inactive
        if (data.length > 0) {
          this.pageState = DefaultStateEnum.NORMAL
        } else {
          this.pageState = DefaultStateEnum.EMPTY
        }
        this.accountList = data
      })
      .catch((msg: string) => {
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.msgError = msg
        this.pageState = DefaultStateEnum.ERROR
      })
  }

  @Builder
  ContentListView(scroller: Scroller) {
    Scroll(scroller) {
        Flex({
          justifyContent: FlexAlign.Start,
          wrap: FlexWrap.Wrap,
          direction: FlexDirection.Row,
          space: { main: LengthMetrics.vp(12), cross: LengthMetrics.vp(12) }
        }) {
          ForEach(this.accountList, (item: OfficialAccountBean) => {
            AccountView({
              item: item
            })
          }, (item: OfficialAccountBean) => item.id + '')
        }
        .padding(12)
        .width('100%')


    }.width('100%')

  }
}

@Component
struct AccountView {
  item: OfficialAccountBean = new OfficialAccountBean()

  build() {
    Text(this.item.name)
      .padding({
        left: 10,
        right: 10,
        top: 6,
        bottom: 6
      })
      .fontColor(Color.Black)
      .fontSize(14)
      .borderRadius(5)
      .borderColor(Color.Black)
      .borderWidth(1)
      .backgroundColor(Color.White)
  }
}