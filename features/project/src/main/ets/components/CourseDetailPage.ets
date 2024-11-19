import { BasePage } from "commons"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { CommonArticlesBean, CommonPagingBean, FeatureUtils } from "lib_components"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { ComposeListItem } from "@ohos.arkui.advanced.ComposeListItem"
import mCourseViewModel from "../viewmodel/CourseViewModel"
import { ToastUtil } from "utils"
import { WebViewPage } from "lib_components/src/main/ets/components/WebViewPage"

@Component
export struct CourseDetailPage {
  @State navPathStack: NavPathStack = new NavPathStack()
  @State title: string = ''
  @State cid: number = 0
  @State pageState: DefaultStateEnum = DefaultStateEnum.NORMAL
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State pageIndex: number = 0
  @State dataList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State isAllLoadOver: boolean = false

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      Column() {
        Text('目录')
          .fontColor(Color.Black)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 20, top: 20, bottom: 20 })
        Divider().strokeWidth(1).color($r('app.color.app_theme_color'))
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 10 })
        BasePage({
          pageState: this.pageState,
          refreshStatus: this.refreshStatus,
          loadMoreStatus: this.loadMoreStatus,
          ContentViewPage: (_scroller: Scroller) => {
            this.ListViewContent(_scroller)
          },
          onRefreshing: () => {
            this.pageIndex = 0
            this.getCourseDetailCatalogList()
          },
          onLoadingMore: () => {
            if (this.isAllLoadOver) {
              this.loadMoreStatus = FooterLoadMoreStatus.inactive
              ToastUtil.showToast('暂无更多数据')
              return
            }
            this.getCourseDetailCatalogList()
          }
        })
      }
      .width('100%')
      .height('100%')
    }
    .mode(NavDestinationMode.STANDARD)
    .title(this.title)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context?.pathStack
      let params = context?.pathInfo?.param as Record<string, Object>
      if (params) {
        this.title = params.title as string
        this.cid = params.cid as number
      }
      this.getCourseDetailCatalogList()
    })
  }

  @Builder
  ListViewContent(scroller: Scroller) {
    List({ scroller: scroller }) {
      LazyForEach(this.dataList, (item: CommonArticlesBean, index: number) => {
        ListItem() {
          CatalogItemView({
            item: item
          })
            .onClick(()=>{
              WebViewPage.startPage(item.link,true,item.title)
            })

        }
        .margin({
          left: 20,
          right: 20,
          top: index == 0 ? 16 : 8,
          bottom: 8
        })
      }, (item: CommonArticlesBean) => item.id)
    }.divider({
      strokeWidth:1,
      startMargin:20,
      endMargin:20,
      color:FeatureUtils.getGrayBgColor()
    })
  }

  private getCourseDetailCatalogList() {
    mCourseViewModel.getCourseDetailList(this.pageIndex, this.cid)
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
          this.pageIndex = 0
          this.dataList.clear()
        }
        this.pageIndex++
        this.dataList.appendArrayData(data.datas)
      })
      .catch((msg: string) => {
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        this.pageState = DefaultStateEnum.ERROR
      })
  }
}

@Component
struct CatalogItemView {
  item: CommonArticlesBean = new CommonArticlesBean()

  build() {
    ComposeListItem({
      contentItem: {
        primaryText: this.item.title
      },
      operateItem: {
        arrow: {
          value: $r('app.media.ic_into_black')
        }
      }
    })
  }
}

@Builder
export function CourseDetailPageBuilder() {
  CourseDetailPage()
}