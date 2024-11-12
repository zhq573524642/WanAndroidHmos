import { LengthMetrics, router } from "@kit.ArkUI"
import { CommonArticlesBean, CommonPagingBean, PageTitleComponent } from "lib_components";
import mHomeViewModel from "../viewmodel/HomeViewModel";
import { BannerData } from "../model/BannerData";
import { ToastUtil } from "utils/src/main/ets/utils/ToastUtil";
import { BasePage } from "commons";
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum";
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh";
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource";
import { WebViewPage } from "lib_web/src/main/ets/components/WebViewPage";
import { HomeSearchPage } from "./HomeSearchPage";


@Component
export struct HomePage {
  @Consume('homePathStack') homePathStack: NavPathStack
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State bannerList: Array<BannerData> = []
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  scroller: Scroller = new Scroller()
  @State pageIndex: number = 0
  @State isLoadAllOver: boolean = false
  @State homeArticleList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State tabLearnList: Array<CommonArticlesBean> = []
  @State tabQuestionList: Array<CommonArticlesBean> = []
  @State tabColumnList: Array<CommonArticlesBean> = []

  aboutToAppear(): void {
    this.getHomeBannerData()
    this.getHomeArticleList()
    this.getHomeWelComeTabData()
  }

  build() {
    Navigation(this.homePathStack) {
      Column() {
        PageTitleComponent({
          title: '首页',
          isShowRightIcon: true,
          rightIcon: $r('app.media.ic_search'),
          onRightIconClick: () => {
            HomeSearchPage.startPage()
          }
        })
        BasePage({
          pageState: this.pageState,
          refreshStatus: this.refreshStatus,
          loadMoreStatus: this.loadMoreStatus,
          ContentViewPage: (_scroller: Scroller) => {
            this.HomePageView(_scroller)
          },
          onRefreshing: () => {
            this.pageIndex = 0
            this.getHomeArticleList()
          },
          onLoadingMore: () => {
            if (this.isLoadAllOver) {
              this.loadMoreStatus = FooterLoadMoreStatus.inactive
              ToastUtil.showToast('暂无更多数据')
              return
            }
            this.getHomeArticleList()
          },
          onErrorRetryCallback: () => {
            this.pageIndex = 0
            this.getHomeBannerData()
            this.getHomeArticleList()
          }
        })
          .layoutWeight(1)

      }.width('100%')
      .height('100%')
    }
    .hideToolBar(true)
  }

  @Builder
  HomePageView(scroller: Scroller) {
    List({scroller:scroller}) {
      ListItem() {
        //Banner
        BannerView({
          data: this.bannerList
        })
      }

      ListItem() {
        this.HomeWelcomeView()
      }

      ListItem() {
        this.HomeArticleListView()
      }
    }.width('100%')
    .layoutWeight(1)
    .cachedCount(4)
  }

  @Builder
  HomeWelcomeView() {
    Row({ space: 12 }) {
      WelcomeTabItem({
        type: 1,
        title: '学习',
        list: this.tabLearnList
      })
        .layoutWeight(1)
      WelcomeTabItem({
        type: 2,
        title: '问答',
        list: this.tabQuestionList
      })
        .layoutWeight(1)
      WelcomeTabItem({
        type: 3,
        title: '专栏',
        list: this.tabColumnList
      })
        .layoutWeight(1)
    }.width('100%')
    .alignItems(VerticalAlign.Top)
    .padding({ left: 20, right: 20 })
    .margin({ top: 15 })
  }

  @Builder
  HomeArticleListView() {
    List({ space: 12 }) {
      LazyForEach(this.homeArticleList, (item: CommonArticlesBean, index: number) => {
        ListItem() {
          HomeArticleItem({
            item: item
          })
            .onClick(() => {
              WebViewPage.startPage(item.link, true, item.title)
            })
        }.margin({ left: 20, right: 20 })
      })
    }.width('100%')
    .layoutWeight(1)
    .cachedCount(4)
    .margin({ top: 15, bottom: 20 })
  }

  //获取banner数据
  private getHomeBannerData() {
    mHomeViewModel.getHomeBannerData()
      .then((data: Array<BannerData>) => {
        this.pageState = DefaultStateEnum.NORMAL
        this.bannerList = data
      })
      .catch((msg: string) => {
        ToastUtil.showToast(msg)
      })
  }

  //获取首页列表
  private getHomeArticleList() {
    mHomeViewModel.getHomeArticleList(this.pageIndex)
      .then((data: CommonPagingBean<CommonArticlesBean>) => {
        this.pageState = DefaultStateEnum.NORMAL
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        this.isLoadAllOver = data.over
        if (this.pageIndex === 0) {
          this.homeArticleList.clear()
        }
        this.pageIndex++
        this.homeArticleList.appendArrayData(data.datas)
      })
      .catch((msg: string) => {
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        ToastUtil.showToast(msg)
      })
  }

  //获取首页最受欢迎模块
  private getHomeWelComeTabData() {
    mHomeViewModel.getHomeWelcomeTabData(1)
      .then((data: Array<CommonArticlesBean>) => {
        this.tabLearnList = data
      })
    mHomeViewModel.getHomeWelcomeTabData(2)
      .then((data: Array<CommonArticlesBean>) => {
        this.tabQuestionList = data
      })
    mHomeViewModel.getHomeWelcomeTabData(3)
      .then((data: Array<CommonArticlesBean>) => {
        this.tabColumnList = data
      })
  }
}

@Component
export struct BannerView {
  @Prop data: Array<BannerData>

  build() {
    Column() {
      Swiper() {
        ForEach(this.data, (item: BannerData) => {
          Image(item.imagePath)
            .width('90%')
            .borderRadius(15)
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              WebViewPage.startPage(item.url, true, item.title)
            })
        }, (item: BannerData) => item.id + '')
      }
      .autoPlay(true)
      .interval(2000)
      .duration(500)
      .loop(true)
      .itemSpace(20)
      .clip(false)
      .displayCount(1)
      .displayMode(SwiperDisplayMode.STRETCH)
      .indicator(DotIndicator.dot()
        .itemWidth(6)
        .itemHeight(6)
        .selectedItemWidth(10)
        .selectedItemHeight(10)
        .color(Color.Gray)
        .selectedColor($r('app.color.app_theme_color')))

    }.width('100%')
    .margin({ top: 10 })
    .alignItems(HorizontalAlign.Center)

  }
}

@Component
export struct HomeArticleItem {
  item: CommonArticlesBean = new CommonArticlesBean()

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
        Text(`${this.item.superChapterName}/${this.item.chapterName}`)
          .fontColor(Color.Blue).fontSize(13)


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

@Component
export struct WelcomeTabItem {
  type: number = 2 //由于接口肿分别用name和title两个字段，所以用type区分一下
  title: string = ''
  @Prop list: Array<CommonArticlesBean> = []

  build() {
    Column() {
      Text(this.title).fontSize(15).fontColor(Color.Black)
      Divider().width('100%').strokeWidth(1).color(Color.Black)
        .margin({ top: 3 })
      ForEach(this.list, (item: CommonArticlesBean, index: number) => {
        Text('· ' + (this.type == 2 ? item.title : item.name))
          .fontSize(12)
          .fontColor(Color.Gray)
          .margin({ top: 4 })
          .maxLines(2)
          .textAlign(TextAlign.Start)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }, (item: CommonArticlesBean) => item.id + '')
    }
    .layoutWeight(1)
    .borderRadius(5)
    .padding(10)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
  }
}

