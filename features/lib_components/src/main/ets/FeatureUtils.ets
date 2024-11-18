import { ArkTSUtils, util } from "@kit.ArkTS";
import { LoadingDialog } from "commons/src/main/ets/components/LoadingDialog";
import { httpFormRequestPost } from "utils/src/main/ets/network/HttpUtil";
import { ResponseResultC } from "utils/src/main/ets/network/ResponseResult";
import { ToastUtil } from "utils/src/main/ets/utils/ToastUtil";
import { CommonArticlesBean } from "./model/CommonArticlesBean";


export class FeatureUtils {
  static instance: FeatureUtils

  static getInstance(): FeatureUtils {
    if (FeatureUtils.instance == null) {
      FeatureUtils.instance = new FeatureUtils()
    }
    return FeatureUtils.instance
  }

  private loadingDialog?: LoadingDialog

  showLoading() {
    if (!this.loadingDialog) {
      this.loadingDialog = new LoadingDialog();
    }
    this.loadingDialog.showLoading()
  }

  showMsgLoading(msg: string) {
    if (!this.loadingDialog) {
      this.loadingDialog = new LoadingDialog();
    }
    this.loadingDialog.showMsgLoading(msg)
  }


  hideLoading() {
    if (this.loadingDialog) {
      this.loadingDialog.hide()
      this.loadingDialog = undefined
    }
  }

  static getRandomColor() {
    const letters: string = '0123456789ABCDEF';
    let color: string = '#';
    for (let i = 0; i < 6; i++) {
      let Itemp: number = Math.floor(Math.random() * 16)
      color += letters[Itemp];
    }
    console.log(color)
    return color;
  }

  static getGrayBgColor(): ResourceStr {
    return $r('sys.color.ohos_id_color_sub_background')
  }


  //我的收藏收藏文章
  handleCollectArticle(id: string, isCollect: boolean): Promise<ResponseResultC<''>> {

    return new Promise<ResponseResultC<''>>(async (resolve, reject) => {
      let url: string = ''
      if (isCollect) {
        //收藏站内文章
        url = 'lg/collect/' + id + '/json'
      } else {
        //取消收藏文章（文章列表）
        url = 'lg/uncollect_originId/' + id + '/json'
      }
      httpFormRequestPost<ResponseResultC<''>>(url, {})
        .then((data: ResponseResultC<''>) => {
          if (data.errorCode === 0) {
            resolve(data)
          } else {
            reject(data.errorMsg)
          }
        })
        .catch((error: string) => {
          reject(error)
        })
    })
  }
}