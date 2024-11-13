import { BasePage } from "commons"
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum"
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh"
import { LengthMetrics } from "@kit.ArkUI"
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource"
import { ToastUtil } from "utils"
import { CommonArticlesBean, CommonPagingBean, CommonTagsBean, PageTitleComponent } from "lib_components"
import mQuestionsViewModel from "../viewmodel/QuestionsViewModel"
import { PlazaDataPage } from "./PlazaDataPage"

@Component
export struct QuestionsPage {
  @Consume('questionsPathStack') questionsPathStack: NavPathStack
  @State pageState: DefaultStateEnum = DefaultStateEnum.LOADING
  @State refreshStatus: HeaderRefreshStatus = HeaderRefreshStatus.inactive
  @State loadMoreStatus: FooterLoadMoreStatus = FooterLoadMoreStatus.inactive
  @State questionsList: LazyDataSource<CommonArticlesBean> = new LazyDataSource()
  @State pageIndex: number = 0
  @State msgError: string = '数据异常'
  @State isAllLoadOver: boolean = false

  aboutToAppear(): void {
    this.requestQuestionsList()
  }

  build() {
    Navigation(this.questionsPathStack) {
      Column() {
        PageTitleComponent({
          title: '问答',
          isShowRightTexts: true,
          rightTexts: ['广场'],
          onRightTextClick: (title: ResourceStr, index: number) => {
            PlazaDataPage.startPage()
          }
        })
        BasePage({
          pageState: this.pageState,
          refreshStatus: this.refreshStatus,
          loadMoreStatus: this.loadMoreStatus,
          msgError: this.msgError,
          ContentViewPage: (_scroller: Scroller) => {
            this.ContentListView(_scroller)
          },
          onRefreshing: () => {
            this.pageIndex = 0
            this.requestQuestionsList()
          },
          onLoadingMore: () => {
            if (this.isAllLoadOver) {
              ToastUtil.showToast('暂无更多数据')
              this.loadMoreStatus = FooterLoadMoreStatus.inactive
              return
            }
            this.requestQuestionsList()
          },
          onErrorRetryCallback: () => {
            this.requestQuestionsList()
          }
        })
          .layoutWeight(1)
          .width('100%')

      }.width('100%')
      .height('100%')
    }.hideTitleBar(true)
    .hideToolBar(true)
  }

  private requestQuestionsList() {
    mQuestionsViewModel.getQuestionsList(this.pageIndex)
      .then((data: CommonPagingBean<CommonArticlesBean>) => {
        this.isAllLoadOver = data.over
        if (data.total == 0) {
          this.pageState = DefaultStateEnum.EMPTY
        } else {
          this.pageState = DefaultStateEnum.NORMAL
        }
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
        if (this.pageIndex == 0) {
          this.questionsList.clear()
        }
        this.pageIndex++
        this.questionsList.appendArrayData(data.datas)

      })
      .catch((msg: string) => {
        this.msgError = msg
        this.pageState = DefaultStateEnum.ERROR
        this.refreshStatus = HeaderRefreshStatus.inactive
        this.loadMoreStatus = FooterLoadMoreStatus.inactive
      })
  }

  @Builder
  ContentListView(scroller: Scroller) {
    List({ space: 12, scroller: scroller }) {
      LazyForEach(this.questionsList, (item: CommonArticlesBean, index: number) => {
        ListItem() {
          QuestionsItemView({
            item: item
          })
            .onClick(() => {
              this.questionsPathStack.pushPathByName('QuestionsDetailPage',
                new Object({
                  articleDetail: item
                }), true);
            })
        }.margin({ left: 12, right: 12 })
      }, (item: CommonArticlesBean) => item.id)
    }.width('100%')
  }
}

@Component
struct QuestionsItemView {
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
        if (this.item.tags.length > 0) {
          ForEach(this.item.tags, (tag: CommonTagsBean) => {
            Text(tag.name)
              .fontColor(Color.Green)
              .fontSize(11)
              .padding({
                left: 6,
                right: 6,
                top: 4,
                bottom: 4
              })
              .borderRadius(3)
              .borderColor(Color.Green)
              .borderWidth(1)
              .margin({ right: 6 })
          })
        }
        Text('分类:').fontColor(Color.Gray).fontSize(12)
        Text(`${this.item.superChapterName}/${this.item.chapterName}`)
          .fontColor(Color.Blue).fontSize(12)
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
        Image($r('app.media.ic_dian_zan')).width(15)
          .height(15)
        Text(this.item.zan + '').fontColor(Color.Red).fontSize(11)
          .margin({ left: 3, right: 5 })
        Text(this.item.shareUser !== '' ? '分享者:' + this.item.shareUser : '作者:' + this.item.author)
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