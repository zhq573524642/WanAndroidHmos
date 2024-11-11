import { webview } from "@kit.ArkWeb"
import { RouterUtil } from "utils"
import { router } from "@kit.ArkUI"

@Entry({ routeName: 'WebViewPage' })
@Component
export struct WebViewPage {
  controller: webview.WebviewController = new webview.WebviewController()
  responseWeb: WebResourceResponse = new WebResourceResponse();
  @State webUrl: string = ''
  @State title: ResourceStr = ''
  @State isShowTitle: boolean = true

  static startPage(url: string, isShowTitle: boolean = true, title: string = '') {
    RouterUtil.pushNamedRouteSingle('WebViewPage', {
      "web_url": url,
      "isShowTitle": isShowTitle,
      "title": title
    })
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      this.webUrl = params.web_url as string
      this.isShowTitle = params.isShowTitle as boolean
      this.title = params.title as string
    }
    //设置WebDebug调试模式
    webview.WebviewController.setWebDebuggingAccess(true)
  }

  build() {
    Column() {
      if (this.isShowTitle) {
        RelativeContainer() {
          Image($r('app.media.ic_back'))
            .width(30)
            .height(30)
            .alignRules({
              left: { anchor: '__container__', align: HorizontalAlign.Start },
              center: { anchor: '__container__', align: VerticalAlign.Center }
            })
            .margin({ left: 15 })
            .id('iv_back')
            .onClick(() => {
              router.back()
            })
          Text(this.title)
            .fontColor(Color.Black)
            .fontSize(15)
            .alignRules({
              center: { anchor: '__container__', align: VerticalAlign.Center },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('60%')
            .id('tv_title')

        }.height(56)
        .backgroundColor(Color.White)

        Divider().vertical(false).color('#dbdbdb').strokeWidth(1)
      }

      Web({ controller: this.controller, src: this.webUrl })
        .onControllerAttached(() => {
          //当Controller成功绑定到Web组件时触发该回调，
          //且禁止在该事件回调前调用Web组件相关的接口，否则会抛出js-error异常
        })
        .onLoadIntercept((event: OnLoadInterceptEvent) => {
          //当Web组件加载url之前触发该回调，用于判断是否阻止此次访问。默认允许加载
          return false
        })
        .onOverrideUrlLoading((webResourceRequest: WebResourceRequest) => {
          //当URL将要加载到当前Web中时，让宿主应用程序有机会获得控制权，
          // 回调函数返回true将导致当前Web中止加载URL，而返回false则会导致Web继续照常加载URL
          return false
        })
        .onInterceptRequest((event:OnInterceptRequestEvent) => {
          return this.responseWeb
        })
        .onPageBegin((event:OnPageBeginEvent)=>{

        })
        .onPageEnd((event:OnPageEndEvent)=>{

        })
        .onPageVisible((event:OnPageVisibleEvent)=>{

        })
        .onRenderExited((event:OnRenderExitedEvent)=>{

        })
        // .onFirstContentfulPaint((event:OnFirstContentfulPaintEvent)=>{
        //    //网页首次内容绘制的回调函数
        // })
        // .onFirstMeaningfulPaint((event:FirstMeaningfulPaint)=>{
        //    //网页首次有效绘制的回调函数
        // })
        // .onLargestContentfulPaint((event:LargestContentfulPaint)=>{
        //   //网页绘制页面最大内容的回调函数
        // })
        .width('100%')
        .layoutWeight(1)
    }.width('100%')
    .height('100%')
  }
}
