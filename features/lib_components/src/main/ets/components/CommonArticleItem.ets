import { CommonArticlesBean } from "../model/CommonArticlesBean"
import { LengthMetrics } from "@kit.ArkUI"

@Component
export struct CommonArticleItem {
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
