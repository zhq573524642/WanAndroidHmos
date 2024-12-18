import { LengthMetrics, router } from "@kit.ArkUI"
import {
  ArticleFromType,
  CommonArticleItem,
  CommonArticlesBean,
  CommonPagingBean,
  CommonShareArticlePage,
  FeatureUtils,
  PageTitleComponent
} from "lib_components";
import mHomeViewModel from "../viewmodel/HomeViewModel";
import { BannerData } from "../model/BannerData";
import { ToastUtil } from "utils/src/main/ets/utils/ToastUtil";
import { BasePage } from "commons";
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum";
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh";
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource";
import { WebViewPage } from "lib_components/src/main/ets/components/WebViewPage";
import { HomeSearchPage } from "./HomeSearchPage";
import {
  AppConstant,
  getHeader,
  PreferenceManager,
  ResponseResultC,
  RouterNameUtils,
  RouterUtil,
  setHeader
} from "utils";


@Component
export struct HomePage {
  @Consume('homePathStack') homePathStack: NavPathStack
  @Consume('appPathStack') appPathStack: NavPathStack
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
  @State unreadMessageCount: number = 0

  aboutToAppear(): void {
    this.getHomeBannerData()
    this.getHomeArticleList()
    this.getHomeWelComeTabData()
    if (getHeader('cookie')) {
      this.getUnreadMsgCount()
    } else {
      PreferenceManager.getInstance().getValue<string[]>(AppConstant.COOKIE)
        .then((value: string[] | null) => {
          if (value !== null) {
            let s = ''
            value.forEach((cookie: string) => {
              s += cookie + ';'
            })
            setHeader('cookie', s)
            this.getUnreadMsgCount()
          }
        })
    }

  }

  @Builder
  MessageView() {
    Row() {
      Image($r('app.media.ic_search'))
        .width(25)
        .height(25)
        .objectFit(ImageFit.Cover)
        .onClick(() => {
          this.appPathStack.pushPathByName('HomeSearchPage', '', true)
        })
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_home_message'))
          .width(25)
          .height(25)
          .objectFit(ImageFit.Cover)
        if (this.unreadMessageCount > 0) {
          Stack({ alignContent: Alignment.TopEnd }) {
            Text(this.unreadMessageCount > 99 ? '99+' : this.unreadMessageCount + '')
              .fontColor(Color.White)
              .width(16)
              .height(16)
              .fontSize(9)
              .margin({ bottom: 13, left: 13 })
              .textAlign(TextAlign.Center)
              .backgroundColor(Color.Red)
              .borderRadius(20)
          }
        }
      }.margin({ left: 12 })
      .onClick(() => {
        if (AppConstant.isLogin) {
          this.appPathStack.pushPathByName("MessagesPage", '', true)
        } else {
          ToastUtil.showToast('请您先登录')
          RouterUtil.pushNamedRouteSingle(RouterNameUtils.PAGE_LOGIN)
        }
      })
    }

  }

  build() {
    Navigation(this.homePathStack) {
      Column() {
        PageTitleComponent({
          title: '首页',
          onCustomRightView: () => {
            this.MessageView()
          }
        })
        BasePage({
          pageState: this.pageState,
          isNeedRetry: true,
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
    .padding({
      top: AppStorage.get<number>('statusBarHeight'),
    })
  }

  @Builder
  HomePageView(scroller: Scroller) {
    List({ scroller: scroller }) {
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
          CommonArticleItem({
            item: item,
            onArticleAuthorClick: (isAuthor: boolean) => {
              if (isAuthor) {
                CommonShareArticlePage.startPage(this.appPathStack, ArticleFromType.ArticleByAuthor, item.userId,
                  '作者:' + item.author,
                  item.author)
              } else {
                CommonShareArticlePage.startPage(this.appPathStack, ArticleFromType.ArticleByOther, item.userId,
                  '分享人:' + item.shareUser)
              }
            },
            onArticleCollect: (isCollect: boolean) => {
              if (isCollect) {
                //取消收藏
                this.handleCollectArticle(item, index, false)
              } else {
                //收藏
                this.handleCollectArticle(item, index, true)
              }
            }
          })
            .onClick(() => {
              WebViewPage.startPage(this.appPathStack, item.link, true, item.title)
            })
        }.margin({ left: 20, right: 20 })
      }, (item: CommonArticlesBean) => item.id + '-' + item.collect)
    }.width('100%')
    .layoutWeight(1)
    .cachedCount(4)
    .margin({ top: 15, bottom: 20 })
  }

  private handleCollectArticle(item: CommonArticlesBean, index: number, isCollect: boolean) {
    mHomeViewModel.showLoading()
    FeatureUtils.getInstance().handleCollectArticle(item.id, isCollect)
      .then((data: ResponseResultC<''>) => {
        mHomeViewModel.hideLoading()
        if (data.errorCode === 0) {
          ToastUtil.showToast(isCollect ? '收藏成功' : '取消收藏成功')
          let updateItem = new CommonArticlesBean()
          updateItem = item
          updateItem.collect = isCollect
          this.homeArticleList.changeData(index, updateItem)
        } else {
          ToastUtil.showToast(isCollect ? '收藏失败' : '取消收藏失败')
        }
      })
      .catch((msg: string) => {
        mHomeViewModel.hideLoading()
        ToastUtil.showToast(msg)
      })
  }

  private getUnreadMsgCount() {
    mHomeViewModel.getUnreadMsgCount()
      .then((data: number) => {
        this.unreadMessageCount = data
      })
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
  @Consume('appPathStack') appPathStack: NavPathStack

  build() {
    Column() {
      Swiper() {
        ForEach(this.data, (item: BannerData) => {
          Image(item.imagePath)
            .width('90%')
            .borderRadius(15)
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              WebViewPage.startPage(this.appPathStack, item.url, true, item.title)
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
export struct WelcomeTabItem {
  type: number = 2 //由于接口肿分别用name和title两个字段，所以用type区分一下
  title: string = ''
  @Prop list: Array<CommonArticlesBean> = []
  @Consume('appPathStack') appPathStack: NavPathStack

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
          .onClick(() => {
            if (this.type == 1) {

            } else if (this.type == 2) {
              WebViewPage.startPage(this.appPathStack, item.link, true, item.title)
            } else {
              this.appPathStack.pushPathByName('SystemsPage', '', true)
            }
          })
      }, (item: CommonArticlesBean) => item.id + '')
    }
    .layoutWeight(1)
    .borderRadius(5)
    .padding(10)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
  }
}

