import { CommonArticlesBean } from "lib_components/src/main/ets/model/CommonArticlesBean"

@Component
export struct QuestionsDetailPage {
  questionsPathStack: NavPathStack = new NavPathStack()
  @State params: CommonArticlesBean = new CommonArticlesBean()
  navDestinationInfo: NavDestinationInfo | undefined

  build() {
    NavDestination() {
      Column() {

      }.width('100%')
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