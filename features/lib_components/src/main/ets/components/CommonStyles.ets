@Builder
export function CommonPageTitle(title: string, fontSize?: ResourceStr) {
  Text(title)
    .fontSize(fontSize ? fontSize : 30)
    .fontColor(Color.Black)
    .minFontSize(15)
    .maxFontSize(30)
    .maxLines(2)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .ellipsisMode(EllipsisMode.END)
    .fontWeight(FontWeight.Bold)
    .margin(15)
}