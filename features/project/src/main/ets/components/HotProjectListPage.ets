import { BasePage } from "commons"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { CommonArticlesBean, CommonPagingBean, FeatureUtils, PageTitleComponent } from "lib_components"
import { ObservedArray, ResponseResultC, RouterUtil, ToastUtil } from "utils"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { LengthMetrics, router } from "@kit.ArkUI"
import mProjectsViewModel from "../viewmodel/ProjectsViewModel"
import { WebViewPage } from "lib_web"

@Component
export struct HotProjectListPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State pageIndex: number = 1
  @State isAllLoadOver: boolean = false
  @State dataList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State cid: string = ''
  @State msgError: string = '数据异常'
  @State itemDataBean: CommonArticlesBean = new CommonArticlesBean()

  aboutToAppear(): void {
    this.getProjectList()
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
          this.pageIndex = 1
          this.getProjectList()
        },
        onLoadingMore: () => {
          if (this.isAllLoadOver) {
            ToastUtil.showToast('暂无更多数据')
            this.loadMoreStatus = FooterLoadMoreStatus.hidden
            return
          }
          this.getProjectList()
        },
        onErrorRetryCallback: () => {
          this.getProjectList()
        }
      })
    }.width('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .height('100%')
  }

  private getProjectList() {
    mProjectsViewModel.getProjectsList(this.pageIndex, this.cid)
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

  private handleCollectArticle(item: CommonArticlesBean, index: number) {
    mProjectsViewModel.showLoading()
    FeatureUtils.getInstance().handleCollectArticle(item.id)
      .then((data: ResponseResultC<''>) => {
        mProjectsViewModel.hideLoading()
        if (data.errorCode === 0) {
          ToastUtil.showToast('收藏成功')
          let temp: ObservedArray<CommonArticlesBean> =[]

          this.dataList.dataArray.forEach((value: CommonArticlesBean) => {
            if (value.id === item.id) {
              value.collect = true
            }
            temp.push(value)
          })

          this.dataList.pushArrayData(temp)
        } else {
          ToastUtil.showToast('收藏失败')
        }
      })
      .catch((msg: string) => {
        mProjectsViewModel.hideLoading()
        ToastUtil.showToast(msg)
      })
  }

  @Builder
  ContentListView(scroller: Scroller) {
    List({ scroller: scroller }) {
      LazyForEach(this.dataList, (item: CommonArticlesBean, index: number) => {
        ProjectItemView({
          item: item,
          onCollectClick: () => {
            if (!item.collect) {
              this.itemDataBean = item
              this.handleCollectArticle(item, index)
            }
          }
        })
          .margin({
            left: 15,
            right: 15,
            top: index == 0 ? 16 : 8,
            bottom: 8
          })
          .bindMenu([
            {
              value: '详情',
              action: () => {
                WebViewPage.startPage(item.link, true, item.title)
              }
            },
            {
              value: '源数据详情',
              action: () => {
                WebViewPage.startPage(item.projectLink, true, item.title)
              }
            }
          ])
      }, (item: CommonArticlesBean) => item.id)
    }.width('100%')
    .layoutWeight(1)
    .cachedCount(3)
  }
}

@Component
struct ProjectItemView {
  @State item: CommonArticlesBean = new CommonArticlesBean()
  onCollectClick?: () => void

  build() {
    Row() {
      Image(this.item.envelopePic).width(90)
        .objectFit(ImageFit.Fill)
        .height(160)

      Column() {
        Text(this.item.title).fontColor(Color.Black).fontSize(17)
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.item.desc)
          .fontSize(13)
          .fontColor(Color.Gray)
          .maxLines(4)
          .lineSpacing(LengthMetrics.vp(2))
          .margin({ top: 10 })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank().layoutWeight(1)
        Row() {
          Column({ space: 8 }) {
            Text(this.item.author).fontColor(Color.Black).fontSize(13)
            Text(this.item.niceDate).fontColor(Color.Gray).fontSize(12)
          }.alignItems(HorizontalAlign.Start)

          Blank().layoutWeight(1)
          Image(this.item.collect ? $r('app.media.ic_collect_select') : $r('app.media.ic_collect_unselect'))
            .objectFit(ImageFit.Cover)
            .width(25)
            .height(25)
            .onClick(() => {
              this.onCollectClick?.()
            })
        }.width('100%')
        .alignItems(VerticalAlign.Center)
      }.alignItems(HorizontalAlign.Start)
      .margin({ left: 10 })
      .layoutWeight(1)
    }
    .padding(15)
    .width('100%')
    .height(200)
    .alignItems(VerticalAlign.Top)
    .borderRadius(10)
    .backgroundColor(Color.White)
  }
}