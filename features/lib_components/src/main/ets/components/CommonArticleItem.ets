import { CommonArticlesBean } from "../model/CommonArticlesBean"
import { LengthMetrics } from "@kit.ArkUI"
import { CommonTagsBean } from "../model/CommonTagsBean"

@Component
export struct CommonArticleItem {
  @ObjectLink
  item: CommonArticlesBean
  isShowChapterName?: boolean = true
  onArticleAuthorClick?: (isAuthor: boolean) => void
  onArticleCollect?: (isCollected: boolean) => void

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
        if (this.isShowChapterName) {
          Text(`${this.item.superChapterName}/${this.item.chapterName}`)
            .fontColor($r('app.color.app_theme_color')).fontSize(13)
        }
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
          .decoration({ type: TextDecorationType.Underline, color: $r('app.color.app_theme_color') })
          .onClick(() => {
            this.onArticleAuthorClick?.(this.item.shareUser == '' )
          })
        Blank().layoutWeight(1)
        Image(this.item.collect ? $r('app.media.ic_collect_select') : $r('app.media.ic_collect_unselect'))
          .objectFit(ImageFit.Cover)
          .width(25)
          .height(25)
          .onClick(() => {
            this.onArticleCollect?.(this.item.collect)
          })
      }.alignItems(VerticalAlign.Center)

    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .borderRadius(10)
    .backgroundColor(Color.White)
    .padding(15)
  }
}
