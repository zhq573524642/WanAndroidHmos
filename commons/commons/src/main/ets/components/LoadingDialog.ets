@Preview
@Component
struct LoadingDialogPrevie {
  build() {
    LoadingDialog()
  }
}

let controller: CustomDialogController | null

@Component
export struct LoadingDialog {
  build() {
  }

  showLoading() {
    if (controller) {
      controller.open()
    } else {
      controller = new CustomDialogController({
        builder: LoadingDialogView(),
        alignment: DialogAlignment.Center,
        offset: {
          dx: 0,
          dy: 1
        },
        customStyle: true,
        autoCancel: false
      });
      controller.open()
    }
  }

  showMsgLoading(msg: string) {
    if (controller) {
      controller.open()
    } else {
      controller = new CustomDialogController({
        builder: LoadingDialogView({
          msg: msg
        }),
        alignment: DialogAlignment.Center,
        offset: {
          dx: 0,
          dy: 1
        },
        customStyle: true,
        autoCancel: false
      });
      controller.open()
    }
  }

  hide() {
    if (controller) {
      controller.close()
      controller = null
    }
  }
}

@CustomDialog
struct LoadingDialogView {
  controller: CustomDialogController
  msg: string = ''

  build() {
    Column() {
      LoadingProgress()
        .color($r('app.color.app_theme_color'))
        .height(50)
        .width(50)
        .backgroundColor(Color.Transparent)
      Text(this.msg).fontColor(Color.Black).fontSize(14).margin({ top: 13 })
    }
    .padding(20)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.Transparent)
    .id(Date().toString())
  }
}
