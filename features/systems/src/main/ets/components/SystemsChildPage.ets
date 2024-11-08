import { PageTitleComponent } from 'lib_components'
import { RouterUtil } from 'utils/src/main/ets/utils/RouterUtil'
import { LengthMetrics, router } from '@kit.ArkUI'
import { BasePage } from 'commons/src/main/ets/base/BasePage'
import { DefaultStateEnum } from 'commons/src/main/ets/components/defaultState/DefaultStateEnum'
import { FooterLoadMoreStatus, HeaderRefreshStatus } from 'commons/src/main/ets/components/SVRefresh/SVRefresh'
import SystemsArticleListBean, { ArticlesData } from '../model/SystemsArticleListBean'
import mSystemsViewModel from '../viewmodel/SystemsViewModel'
import { SystemChildrenList } from '../model/SystemsListBean'
import LazyDataSource from 'utils/src/main/ets/utils/LazyDataSource'
import { ToastUtil } from 'utils'
import { SystemsSearchPage } from './SystemsSearchPage'

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
  @State dataList: LazyDataSource<ArticlesData> = new LazyDataSource()
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
        isShowRightIcon: true,
        rightIcon: $r('app.media.ic_search'),
        onRightIconClick: () => {
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
      .then((data: SystemsArticleListBean) => {
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
      LazyForEach(this.dataList, (item: ArticlesData, index: number) => {
        ListItem() {
          SystemsChildItemView({
            item: item
          })
        }.margin({ left: 20, right: 20 })
      }, (item: ArticlesData) => item.id + '')
    }.width('100%')
    .margin({ bottom: 20 })
    .layoutWeight(1)
    .cachedCount(4)
  }
}

@Component
export struct SystemsChildItemView {
  item: ArticlesData = new ArticlesData()

  build() {
    Column() {
      Row() {
        if (this.item.fresh) {
          Text('新')
            .fontColor(Color.Red)
            .fontSize(11)
            .padding({
              left: 6,
              right: 6,
              top: 4,
              bottom: 4
            })
            .borderRadius(3)
            .borderColor(Color.Red)
            .borderWidth(1)
            .margin({ right: 6 })
        }
        // Text(`${this.item.superChapterName}/${this.item.chapterName}`)
        //   .fontColor(Color.Blue).fontSize(13)
        Blank().layoutWeight(1)
        Text(this.item.niceDate).fontColor(Color.Gray).fontSize(12)
      }.alignItems(VerticalAlign.Center)

      Text(this.item.title)
        .fontColor(Color.Black)
        .fontSize(15)
        .width('100%')
        .maxLines(2)
        .lineSpacing(LengthMetrics.vp(2))
        .textAlign(TextAlign.Start)
        .ellipsisMode(EllipsisMode.END)
        .margin({ top: 10, bottom: 10 })
      Row() {
        Text(this.item.shareUser !== '' ? '分享者：' + this.item.shareUser : '作者：' + this.item.author)
          .fontColor(Color.Grey).fontSize(13)
        Blank().layoutWeight(1)
        Image(this.item.collect ? $r('app.media.ic_collect_select') : $r('app.media.ic_collect_unselect'))
          .objectFit(ImageFit.Cover)
          .width(25)
          .height(25)
      }.alignItems(VerticalAlign.Center)

    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .borderRadius(10)
    .backgroundColor(Color.White)
    .padding(15)
  }
}