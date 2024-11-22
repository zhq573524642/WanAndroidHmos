import { webview } from "@kit.ArkWeb"
import { LoadingUtil, RouterUtil } from "utils"
import { router } from "@kit.ArkUI"
import { BasePage } from "commons";
import { DefaultStateEnum } from "commons/src/main/ets/components/defaultState/DefaultStateEnum";
import { FooterLoadMoreStatus, HeaderRefreshStatus } from "commons/src/main/ets/components/SVRefresh/SVRefresh";

@Component
export struct WebViewPage {
  controller: webview.WebviewController = new webview.WebviewController()
  responseWeb: WebResourceResponse = new WebResourceResponse();
  @State webUrl: string = ''
  @State title: ResourceStr = ''
  @State isShowTitle: boolean = true
  navPathStack: NavPathStack = new NavPathStack()

  static startPage(navPathStack: NavPathStack, url: string, isShowTitle: boolean = true, title: string = '') {

    navPathStack.pushPathByName('WebViewPage', new Object({
      "web_url": url,
      "isShowTitle": isShowTitle,
      "title": title
    }), true)
  }

  aboutToAppear(): void {
    //设置WebDebug调试模式
    webview.WebviewController.setWebDebuggingAccess(true)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Web({ controller: this.controller, src: this.webUrl })// .onControllerAttached(() => {
          //   //当Controller成功绑定到Web组件时触发该回调，
          //   //且禁止在该事件回调前调用Web组件相关的接口，否则会抛出js-error异常
          // })
          // .onLoadIntercept((event: OnLoadInterceptEvent) => {
          //   //当Web组件加载url之前触发该回调，用于判断是否阻止此次访问。默认允许加载
          //   return false
          // })
          // .onOverrideUrlLoading((webResourceRequest: WebResourceRequest) => {
          //   //当URL将要加载到当前Web中时，让宿主应用程序有机会获得控制权，
          //   // 回调函数返回true将导致当前Web中止加载URL，而返回false则会导致Web继续照常加载URL
          //   return false
          // })
          // .onInterceptRequest((event:OnInterceptRequestEvent) => {
          //   return this.responseWeb
          // })
          // .onPageBegin((event: OnPageBeginEvent) => {
          //
          // })
          // .onPageEnd((event: OnPageEndEvent) => {
          // })
          // .onProgressChange((event: OnProgressChangeEvent) => {
          //
          // })// .onPageVisible((event: OnPageVisibleEvent) => {
            // })// .onRenderExited((event:OnRenderExitedEvent)=>{
            //
            // })
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
    .title(this.title.toString())
    .hideTitleBar(!this.isShowTitle)
    .mode(NavDestinationMode.STANDARD)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context?.pathStack
      let params = context?.pathInfo?.param as Record<string, Object>
      if (params) {
        this.webUrl = params.web_url as string
        this.isShowTitle = params.isShowTitle as boolean
        this.title = params.title as string
      }
    })
    .padding({
      top:AppStorage.get<number>('statusBarHeight')
    })
  }
}


@Builder
export function WebViewPageBuilder() {
  WebViewPage()
}
