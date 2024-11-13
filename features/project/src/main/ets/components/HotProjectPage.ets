import { PageTitleComponent } from "lib_components/src/main/ets/components/PageTitleComponent"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { ProjectTypeBean } from "../model/ProjectTypeBean"
import mProjectsViewModel from "../viewmodel/ProjectsViewModel"
import { HotProjectListPage } from "./HotProjectListPage"
import { SystemsPage } from "./SystemsPage"

@Component
export struct HotProjectPage {
  @State projectTypeList: Array<ProjectTypeBean> = []
  @State tabsIndex: number = 0
  @State tabItemData: ProjectTypeBean = new ProjectTypeBean()

  aboutToAppear(): void {
    this.getProjectsType()
  }

  build() {
    Column() {
      PageTitleComponent({
        title: '热门项目',
        isShowRightIcons: true,
        rightIcons: [$r('app.media.ic_systems_icon')],
        onRightIconClick: (icon: ResourceStr, index: number) => {
          SystemsPage.startPage()
        }
      })
      Tabs({ index: this.tabsIndex }) {
        ForEach(this.projectTypeList, (tabItem: ProjectTypeBean, index: number) => {
          TabContent() {
            HotProjectListPage({
              cid: tabItem.id
            })
          }.tabBar(this.TabsView(tabItem))
        }, (item: ProjectTypeBean) => item.id)
      }
      .barMode(BarMode.Scrollable)
      .layoutWeight(1)
      .width('100%')
      .scrollable(true)
      .vertical(false)
      .onChange((i: number) => {
        this.tabItemData = this.projectTypeList[i]
      })
    }.width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  private getProjectsType() {
    mProjectsViewModel.getProjectsType()
      .then((data: Array<ProjectTypeBean>) => {
        this.projectTypeList = data
        this.tabItemData = this.projectTypeList[0]
      })
  }

  @Builder
  TabsView(tabItem: ProjectTypeBean) {

    Column() {
      Text(tabItem.name).fontColor(this.tabItemData.id === tabItem.id ? $r('app.color.app_theme_color') : '#aaaaaa')
        .fontSize(this.tabItemData.id === tabItem.id ? 18 : 14)
        .fontWeight(this.tabItemData.id === tabItem.id ? FontWeight.Bold : FontWeight.Normal)
      Text()
        .backgroundColor(this.tabItemData.id === tabItem.id ? $r('app.color.app_theme_color') : Color.Transparent)
        .height(3)
        .width(40)
        .margin({ top: 5 })
        .borderRadius(10)
    }.alignItems(HorizontalAlign.Center)
    .margin({ left: 10, right: 10 })
    .padding({ top: 10, bottom: 10 })
  }
}