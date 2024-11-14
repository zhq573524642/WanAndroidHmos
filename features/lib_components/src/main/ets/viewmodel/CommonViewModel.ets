import { BaseViewModel } from "commons"
import { httpARequestGet, ResponseResultC } from "utils"
import { CommonArticlesBean } from "../model/CommonArticlesBean"
import { CommonPagingBean } from "../model/CommonPagingBean"
import { CommonUserArticlesBean } from "../model/CommonUserArticlesBean"

export class CommonViewModel extends BaseViewModel{
  static instance: CommonViewModel

  public static getInstance(): CommonViewModel {
    if (CommonViewModel.instance == null) {
      CommonViewModel.instance = new CommonViewModel()
    }
    return CommonViewModel.instance
  }

  //获取分享者的分享的文章列表
  getShareArticlesList(userId: number, pageIndex: number): Promise<CommonUserArticlesBean> {

    return new Promise<CommonUserArticlesBean>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<CommonUserArticlesBean>>(
        'user/' + userId + '/share_articles/' + pageIndex + '/json'
      )
        .then((data: ResponseResultC<CommonUserArticlesBean>) => {
          if (data.errorCode === 0) {
            resolve(data.data)
          } else {
            reject(data.errorMsg)
          }
        })
        .catch((error: string) => {
          reject(error)
        })
    })
  }

  //搜索公众号文章列表
  getWxArticlesList(userId: number, pageIndex: number): Promise<CommonPagingBean<CommonArticlesBean>> {
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(
        'wxarticle/list/' + userId + '/' + pageIndex + '/json'
      )
        .then((data: ResponseResultC<CommonPagingBean<CommonArticlesBean>>) => {
          if (data.errorCode === 0) {
            resolve(data.data)
          } else {
            reject(data.errorMsg)
          }
        })
        .catch((error: string) => {
          reject(error)
        })
    })
  }

  //公众号搜索某个作者的某个关键字的文章
  getSearchWxArticlesList(userId: number, pageIndex: number,key:string): Promise<CommonPagingBean<CommonArticlesBean>> {
     this.showMsgLoading('搜索中..')
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(
        'wxarticle/list/'+userId+'/'+pageIndex+'/json?k='+key
      )
        .then((data: ResponseResultC<CommonPagingBean<CommonArticlesBean>>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            resolve(data.data)
          } else {
            reject(data.errorMsg)
          }
        })
        .catch((error: string) => {
          this.hideLoading()
          reject(error)
        })
    })
  }

}
