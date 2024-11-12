import { DefaultStateEnum } from './DefaultStateEnum';

@Component
export struct DefaultStatePage {
  //如果可以下拉刷新,则scroller要外部传入
  scroller?: Scroller = new Scroller()
  @BuilderParam normalPage: () => void;
  @Prop defaultState: number = DefaultStateEnum.LOADING
  @Prop noDataMsg: string
  @Prop errorMsg: string
  icon?: ResourceStr = $r('app.media.ic_common_no_data')
  errorIcon?: ResourceStr = $r('app.media.ic_common_error')
  onRetryCallback?: () => void

  build() {
    Column() {
      if (this.defaultState === DefaultStateEnum.LOADING) {
        this.loading()
      } else if (this.defaultState === DefaultStateEnum.EMPTY) {
        this.empty()
      } else if (this.defaultState === DefaultStateEnum.ERROR) {
        this.error()
      } else {
        this.normalPage()
      }
    }
    .width('100%')
    .height('100%')
    .layoutWeight(1)
  }

  @Builder
  loading() {
    Column() {
      LoadingProgress()
        .color($r('app.color.app_theme_color'))
        .height(100)
        .width(100)
        .backgroundColor(Color.Transparent)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }

  @Builder
  empty() {
    Column() {
      Image(this.icon)
        .width(80)
        .height(80)
      Text(this.noDataMsg ? this.noDataMsg : '没有数据').margin({ top: 15 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }

  @Builder
  error() {
    Column() {
      Image(this.errorIcon)
        .width(80)
        .height(80)
        .onClick(() => {
          this.onRetryCallback?.()
        })
      Text(this.errorMsg ? this.errorMsg : '数据错误').margin({ top: 15 })
        .onClick(() => {
          this.onRetryCallback?.()
        })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }
}