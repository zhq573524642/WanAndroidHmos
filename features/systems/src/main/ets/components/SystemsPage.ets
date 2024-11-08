import { BasePage } from 'commons'
import { DefaultStateEnum } from 'commons/src/main/ets/components/defaultState/DefaultStateEnum'
import { FooterLoadMoreStatus, HeaderRefreshStatus } from 'commons/src/main/ets/components/SVRefresh/SVRefresh'
import { ToastUtil } from 'utils/src/main/ets/utils/ToastUtil'
import { SystemChildrenList, SystemsListBean } from '../model/SystemsListBean'
import mSystemsViewModel from '../viewmodel/SystemsViewModel'
import { LengthMetrics } from '@kit.ArkUI'
import { SystemsChildPage } from './SystemsChildPage'

@Component
export struct SystemsPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.hidden
  @State systemsList: Array<SystemsListBean> = []

  aboutToAppear(): void {
    this.getSystemsListData()
  }

  build() {
    Column() {
      BasePage({
        pageState: this.pageState,
        refreshStatus: this.refreshStatus,
        loadMoreStatus: this.loadMoreStatus,
        ContentViewPage: (_scroller: Scroller) => {
          this.ListView(_scroller)
        },
        onRefreshing:()=>{
           this.getSystemsListData()
        }
      })

    }.width('100%')
    .justifyContent(FlexAlign.Start)
    .height('100%')
    .backgroundColor(Color.White)
  }

  private getSystemsListData() {
    mSystemsViewModel.getSystemsList()
      .then((data: Array<SystemsListBean>) => {
        this.refreshStatus=HeaderRefreshStatus.inactive
        if (data.length > 0) {
          this.pageState = DefaultStateEnum.NORMAL
          this.systemsList = data
        } else {
          this.pageState = DefaultStateEnum.EMPTY
        }
      })
      .catch((msg: string) => {
        this.refreshStatus=HeaderRefreshStatus.inactive
        this.pageState = DefaultStateEnum.ERROR
        ToastUtil.showToast(msg)
      })
  }

  @Builder
  ListView(scroller: Scroller) {
    Scroll(scroller) {
      Column() {
        ForEach(this.systemsList, (item: SystemsListBean, index: number) => {
          Column() {
            this.TitleHeaderView(item.name)
            WaterFlow() {
              ForEach(item.children, (itemChild: SystemChildrenList, inIndex: number) => {
                FlowItem() {
                  SystemsItemView({
                    item: itemChild
                  })
                }
                .onClick(() => {
                  SystemsChildPage.startPage(itemChild.name, itemChild.id)
                })
              }, (itemChild: SystemChildrenList) => itemChild.id + '')
            }
            .width('100%')
            .rowsGap(10)
            .columnsGap(10)
            .cachedCount(4)
            .columnsTemplate('1fr 1fr 1fr')
            .layoutDirection(FlexDirection.Column)
            .alignSelf(ItemAlign.Start)
          }
        }, (item: SystemsListBean) => (item.id + ''))
      }
      .padding({ left: 20, right: 20 })
    }.width('100%')

  }

  @Builder
  TitleHeaderView(title: string) {
    Text(title)
      .fontColor(Color.Black)
      .fontSize(18)
      .width('100%')
      .backgroundColor(Color.White)
      .textAlign(TextAlign.Center)
      .padding({ top: 15, bottom: 15 })
      .fontWeight(FontWeight.Bold)
  }
}

@Component
export struct SystemsItemView {
  item: SystemChildrenList = new SystemChildrenList()

  build() {
    Text(this.item.name)
      .fontSize(13)
      .fontColor(Color.Black)
      .padding({
        left: 10,
        right: 10,
        top: 5,
        bottom: 5
      })
      .borderWidth(1)
      .borderRadius(20)
      .borderColor(Color.Black)
      .backgroundColor(Color.White)
  }
}
