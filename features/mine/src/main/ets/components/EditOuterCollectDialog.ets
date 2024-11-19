import { FeatureUtils } from "lib_components"
import { ToastUtil } from "utils"
import { DateUtil } from "utils/src/main/ets/utils/DateUtil"

@CustomDialog
export struct EditOuterCollectDialog {
  controller: CustomDialogController
  @Link title: string
  @Link link: string
  @Link author: string
  onSaveCollectCallback?: () => void

  build() {
    Column() {
      Text('收藏文章').fontColor(Color.Black).fontSize(18).fontWeight(FontWeight.Bold)
        .margin({ top: 15, bottom: 15 })
      Row() {
        Text('标题：').fontColor(Color.Black).fontSize(13)
        TextInput({ placeholder: '请输入标题（必填）', text: $$this.title })
          .height(45)
          .layoutWeight(1)
      }.padding({ left: 25, right: 25 })
      .width('100%')
      .margin({ top: 15 })

      Row() {
        Text('作者：').fontColor(Color.Black).fontSize(13)
        TextInput({ placeholder: '请输入作者（必填）', text: $$this.author })
          .height(45)
          .layoutWeight(1)
      }.padding({ left: 25, right: 25 })
      .width('100%')
      .margin({ top: 13 })

      Row() {
        Text('链接：').fontColor(Color.Black).fontSize(13)
        TextInput({ placeholder: '请输入链接（必填）', text: $$this.link })
          .height(45)
          .layoutWeight(1)
      }.padding({ left: 25, right: 25 })
      .width('100%')
      .margin({ top: 13 })

      Row() {
        Button('取消')
          .backgroundColor(FeatureUtils.getGrayBgColor())
          .fontSize(14)
          .fontColor($r('app.color.color_999999'))
          .width(100)
          .onClick(() => {
            this.controller.close()
          })
        Button('保存')
          .backgroundColor($r('app.color.app_theme_color'))
          .fontSize(14)
          .fontColor(Color.White)
          .width(100)
          .onClick(() => {
            if (this.title == '') {
              ToastUtil.showCenterToast('请输入标题')
              return
            }
            if (this.author == '') {
              ToastUtil.showCenterToast('请输入作者')
              return
            }
            if (this.link == '') {
              ToastUtil.showCenterToast('请输入链接')
              return
            }
            this.onSaveCollectCallback?.()
          })
      }.width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 20, top: 20 })
    }.width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}