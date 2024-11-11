import { BasePage } from "commons";
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum";
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh";
import mHMVewModel from "../viewmodel/HMViewModel";
import { data } from "@kit.TelephonyKit";
import HarmonyListBean from "../model/HarmonyListBean";
import { LengthMetrics } from "@kit.ArkUI";
import { ToastUtil } from "utils/src/main/ets/utils/ToastUtil";
import { CommonArticlesBean } from "lib_components";
import { WebViewPage } from "lib_web";

@Component
export struct HarmonyPage {
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.hidden
  @State linksList: Array<CommonArticlesBean> = []
  @State toolsList: Array<CommonArticlesBean> = []
  @State openSourcesList: Array<CommonArticlesBean> = []
  @State linksTitle: string = ''
  @State toolsTitle: string = ''
  @State openSourcesTitle: string = ''
  @State msgError: string = '数据异常，重试'
  @State searchContent: string = ''
  hotSearchArr: string[] = ['ohos', 'axios', 'http']

  aboutToAppear(): void {
    this.getHarmonyListData()
  }

  build() {
    Column() {
      BasePage({
        pageState: this.pageState,
        msgError: this.msgError,
        refreshStatus: this.refreshStatus,
        loadMoreStatus: this.loadMoreStatus,
        ContentViewPage: (_scroller: Scroller) => {
          this.ContentView(_scroller)
        },
        onRefreshing: () => {
          this.getHarmonyListData()
        },
        onErrorRetryCallback: () => {
          this.getHarmonyListData()
        }
      })
    }.width('100%')
  }

  private getHarmonyListData() {
    mHMVewModel.getHarmonyListData()
      .then((data: HarmonyListBean) => {
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.pageState = DefaultStateEnum.NORMAL
        this.linksTitle = data?.links?.name
        this.toolsTitle = data?.tools?.name
        this.openSourcesTitle = data?.open_sources?.name
        this.linksList = data?.links?.articleList
        this.toolsList = data?.tools?.articleList
        this.openSourcesList = data?.open_sources?.articleList
      })
      .catch((msg: string) => {
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.pageState = DefaultStateEnum.ERROR
        this.msgError = msg
      })
  }

  @Builder
  ContentView(scroller: Scroller) {
    Column() {
      this.SearchView()
      this.ListView(scroller)
    }.width('100%')
  }

  @Builder
  SearchView() {
    Column() {
      Text('OpenHarmony三方库')
        .fontSize(25)
        .margin({ top: 30 })
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bolder)
      Search({ placeholder: '输入关键词', })
        .searchButton('搜索', { fontColor: Color.Black })
        .placeholderColor(Color.Gray)
        .placeholderFont({ style: FontStyle.Normal, size: 14, weight: 500, })
        .textAlign(TextAlign.Start)
        .textFont({ size: 14, style: FontStyle.Italic, weight: 500 })
        .width('80%')
        .height(46)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .margin({ top: 25 })
        .onSubmit((content: string) => {
          if (content.length <= 0) {
            ToastUtil.showToast('请输入搜索关键词')
            return
          }
          let url = 'https://ohpm.openharmony.cn/#/cn/result?q=' + content
          WebViewPage.startPage(url, true, '标题')
        })

      Row({ space: 10 }) {
        ForEach(this.hotSearchArr, (item: string) => {
          Text(item)
            .fontSize(13)
            .fontColor(Color.White)
            .borderRadius(5)
            .borderWidth(1)
            .padding({
              left: 5,
              right: 5,
              top: 3,
              bottom: 3
            })
            .borderColor(Color.White)
        }, (item: string) => item)
      }
      .margin({ top: 15 })

    }.width('100%')
    .height(200)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#262626')
  }

  @Builder
  ListView(scroller: Scroller) {
    List({ scroller: scroller }) {
      ListItemGroup({ header: this.HeaderBuilder(this.toolsTitle), space: 12 }) {
        ForEach(this.toolsList, (item: CommonArticlesBean, index: number) => {
          ListItem() {
            HMItemView({
              item: item
            })

          }
          .margin({ left: index % 2 == 0 ? 0 : 6, right: index % 2 == 0 ? 6 : 0 })
          .onClick(() => {
            WebViewPage.startPage(item.link, true, item.title)
          })
        }, (item: CommonArticlesBean) => item.id + '')
      }.margin({ left: 20, right: 20 })

      ListItemGroup({ header: this.HeaderBuilder(this.linksTitle), space: 12 }) {
        ForEach(this.linksList, (item: CommonArticlesBean, index: number) => {
          ListItem() {
            HMItemView({
              item: item
            })
          }.margin({ left: index % 2 == 0 ? 0 : 6, right: index % 2 == 0 ? 6 : 0 })
          .onClick(() => {
            WebViewPage.startPage(item.link, true, item.title)
          })
        }, (item: CommonArticlesBean) => item.id + '')
      }.margin({ left: 20, right: 20 })

      ListItemGroup({ header: this.HeaderBuilder(this.openSourcesTitle), space: 12 }) {
        ForEach(this.openSourcesList, (item: CommonArticlesBean, index: number) => {
          ListItem() {
            HMItemView({
              item: item
            })
          }.margin({ left: index % 2 == 0 ? 0 : 6, right: index % 2 == 0 ? 6 : 0 })
          .onClick(() => {
            WebViewPage.startPage(item.link, true, item.title)
          })
        }, (item: CommonArticlesBean) => item.id + '')
      }.margin({ left: 20, right: 20 })
    }
    .width('100%')
    //添加粘性标题 搭配ListItemGroup使用
    .sticky(StickyStyle.Header)
    .lanes(2)
    .layoutWeight(1)
    .margin({ bottom: 20 })
  }

  @Builder
  HeaderBuilder(name: string) {
    Text(name)
      .fontSize(20)
      .padding({ top: 20, bottom: 20 })
      .fontColor(Color.Black)
      .width('100%')
      .textAlign(TextAlign.Start)
      .fontWeight(FontWeight.Bold)
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}

@Component
export struct HMItemView {
  item: CommonArticlesBean = new CommonArticlesBean()

  build() {
    Column({ space: 12 }) {
      Text(this.item.title)
        .fontColor(Color.Black)
        .fontSize(16)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(this.item.desc)
        .fontSize(14)
        .fontColor(Color.Gray)
        .maxLines(2)
        .lineSpacing(LengthMetrics.vp(2))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .borderRadius(10)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
    .padding(13)
  }
}
