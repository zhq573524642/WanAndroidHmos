import { RouterUtil } from "utils";
import { router } from "@kit.ArkUI";

@Entry({ routeName: 'SystemsSearchPage' })
@Component
export struct SystemsSearchPage {
  static startPage() {
    RouterUtil.pushNamedRoute('SystemsSearchPage')
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(30)
          .height(30)
          .objectFit(ImageFit.Fill)
          .onClick(()=>{
             router.back()
          })
        Search({ placeholder: '请输入作者昵称' })
          .searchButton('搜索')
          .fontColor(Color.Black)
          .onSubmit((value: string) => {

          })
          .height(50)
          .layoutWeight(1)
      }.padding({ left: 20, right: 20 })
    }.width('100%')
    .height('100%')
  }
}