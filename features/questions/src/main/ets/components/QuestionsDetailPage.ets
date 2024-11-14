import { FeatureUtils } from "lib_components"
import { CommonArticlesBean } from "lib_components/src/main/ets/model/CommonArticlesBean"

@Component
export struct QuestionsDetailPage {
  questionsPathStack: NavPathStack = new NavPathStack()
  @State params: CommonArticlesBean = new CommonArticlesBean()
  navDestinationInfo: NavDestinationInfo | undefined

  build() {
    NavDestination() {
      Column() {
        Row({ space: 20 }) {
          Text(this.params.author).fontColor(Color.Blue).fontSize(16)
          Blank().layoutWeight(1)
          Text(this.params.niceDate).fontSize(13).fontColor(Color.Gray)
        }.padding(15)
        .alignItems(VerticalAlign.Center)

        Divider().vertical(false)
          .color(Color.Gray)
          .strokeWidth(1)
          .width('90%')
        Text('↓ 滚动查看问题详情')
          .fontColor(Color.Grey)
          .fontSize(13)
          .margin({ top: 15, left: 15 })
          .width('100%')
          .textAlign(TextAlign.Start)
        Row() {
          RichText('<font size="16">' + this.params.desc + '</font>')
            .width('100%')
            .height(250)

        }
        .padding(14)
        .margin(15)
        .borderColor(FeatureUtils.getRandomColor())
        .borderRadius(10)
        .borderStyle(BorderStyle.Dotted)
        .borderWidth(5)

        Text("aaaaaaaaaaaaaaaaaaa").fontSize(19)
      }.width('100%')
      .alignItems(HorizontalAlign.Center)
      .height('100%')
    }.mode(NavDestinationMode.STANDARD)
    .title(this.params.title)
    .backButtonIcon($r('app.media.ic_back'))
    .onReady((context: NavDestinationContext) => {
      this.questionsPathStack = context.pathStack
      let p = context.pathInfo.param as Record<string, object>;
      if (p) {
        this.params = p.articleDetail as CommonArticlesBean
      }
    })
  }
}

@Builder
export function QuestionsDetailPageBuilder() {
  QuestionsDetailPage()
}