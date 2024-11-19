import { BasePage } from "commons"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { FeatureUtils } from "lib_components"
import { CourseListBean } from "../model/CourseListBean"
import mCourseViewModel from "../viewmodel/CourseViewModel"
import { BusinessError } from "@kit.BasicServicesKit"


@Component
export struct CoursePage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshState: HeaderRefreshStatus = HeaderRefreshStatus.hidden
  @State loadMoreState: FooterLoadMoreStatus = FooterLoadMoreStatus.hidden
  @State dataList: Array<CourseListBean> = []
  @State msgError: string = '数据异常'
  @State navPathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.getCourseList()
  }

  build() {
    NavDestination() {
      Column() {
        BasePage({
          pageState: this.pageState,
          refreshStatus: this.refreshState,
          loadMoreStatus: this.loadMoreState,
          msgError: this.msgError,
          ContentViewPage: (_scroller: Scroller) => {
            this.ListViewContent(_scroller)
          }
        })
      }.width('100%')
      .height('100%')
    }.mode(NavDestinationMode.STANDARD)
    .backgroundColor(FeatureUtils.getGrayBgColor())
    .title('教程')
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context?.pathStack
    })
  }

  @Builder
  ListViewContent(scroller: Scroller) {
    List({ scroller: scroller }) {
      ForEach(this.dataList, (item: CourseListBean, index: number) => {
        ListItem() {
          CourseItemView({
            item: item
          })
            .onClick(() => {
              this.navPathStack.pushPathByName('CourseDetailPage', new Object({
                title: item.name,
                cid: item.id
              }), true)
            })
        }
        .margin({
          left: 20,
          right: 20,
          top: index == 0 ? 16 : 8,
          bottom: 8
        })
      }, (item: CourseListBean) => item.courseId + '')
    }
  }

  private getCourseList() {
    mCourseViewModel.getCourseList()
      .then((data: Array<CourseListBean>) => {
        if (data.length > 0) {
          this.pageState = DefaultStateEnum.NORMAL
        } else {
          this.pageState = DefaultStateEnum.EMPTY
        }
        this.dataList = data
      })
      .catch((msg: string) => {
        this.msgError = msg
        this.pageState = DefaultStateEnum.ERROR
      })
  }
}

@Component
struct CourseItemView {
  item: CourseListBean = new CourseListBean()

  build() {
    Row() {
      Image(this.item.cover).width(90)
        .objectFit(ImageFit.Cover)
      Column() {
        Text(this.item.name).fontColor($r('app.color.app_theme_color')).fontSize(18)
        Text(`作者：${this.item.author}`).fontColor(Color.Gray).fontSize(14).margin({ top: 12 })
        Text(this.item.desc).fontColor(Color.Gray).fontSize(13).margin({ top: 20 })
      }.margin({ left: 15 }).layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .alignItems(VerticalAlign.Top)
    .width('100%')
  }
}

@Builder
export function CoursePageBuilder() {
  CoursePage()
}