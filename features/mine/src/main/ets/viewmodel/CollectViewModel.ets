import { BaseViewModel } from 'commons';
import { CommonArticlesBean, CommonPagingBean } from 'lib_components';
import { httpARequestGet, httpFormRequestPost, ResponseResultC } from 'utils';
import { MineApi } from '../api/MineApi';

class CollectViewModel extends BaseViewModel {
  /**
   * 收藏文章相关
   */
  //获取文章收藏列表
  getArticleCollectionsList(pageIndex: number): Promise<CommonPagingBean<CommonArticlesBean>> {
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve, reject) => {

      httpARequestGet<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(MineApi.API_COLLECTIONS + pageIndex +
        '/json')
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

  //取消收藏文章
  handleCancelCollect(id: string, originId: string): Promise<ResponseResultC<''>> {
    this.showLoading()
    return new Promise<ResponseResultC<''>>(async (resolve, reject) => {
      let param: Record<string, Object> = {
        "originId": originId !== '' ? originId : '-1'
      }
      httpFormRequestPost<ResponseResultC<''>>(MineApi.API_CANCEL_COLLECT_FOR_COLLECTION + id + '/json', param)
        .then((data: ResponseResultC<''>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            resolve(data)
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

  //收藏站外文章
  collectOuterArticle(title: string, author: string, link: string): Promise<string> {
    this.showLoading()
    return new Promise<string>(async (resolve, reject) => {
      let param: Record<string, Object> = {
        "title": title,
        "author": author,
        "link": link
      }
      httpFormRequestPost<ResponseResultC<string>>(MineApi.API_COLLECT_OUTER_ARTICLE, param)
        .then((data: ResponseResultC<string>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            resolve('收藏成功')
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

  //编辑收藏的文章
  updateCollectArticle(id: string, title: string, author: string, link: string): Promise<string> {
    this.showLoading()
    return new Promise<string>(async (resolve, reject) => {
      let param: Record<string, Object> = {
        "title": title,
        "author": author,
        "link": link
      }
      httpFormRequestPost<ResponseResultC<string>>(MineApi.API_EDIT_COLLECT_ARTICLE + id + '/json', param)
        .then((data: ResponseResultC<string>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            resolve('修改成功')
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

  /**
   * 收藏网站相关
   */
  //获取收藏网页的列表
  getWebCollectionsList(): Promise<Array<CommonArticlesBean>> {
    return new Promise<Array<CommonArticlesBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<Array<CommonArticlesBean>>>(MineApi.API_COLLECTION_WEB_LIST)
        .then((data: ResponseResultC<Array<CommonArticlesBean>>) => {
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

  handleCollectWeb( name: string, link: string): Promise<string> {
    this.showLoading()
    return new Promise<string>(async (resolve, reject) => {
      let param: Record<string, Object> = {
        "name": name,
        "link": link
      }
      httpFormRequestPost<ResponseResultC<string>>(MineApi.API_COLLECTION_WEB, param)
        .then((data: ResponseResultC<string>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            resolve('收藏成功')
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
 //删除网页收藏
  handleCancelCollectWeb(id: string): Promise<ResponseResultC<''>> {
    this.showLoading()
    return new Promise<ResponseResultC<''>>(async (resolve, reject) => {
      let param: Record<string, Object> = {
        "id": id
      }
      httpFormRequestPost<ResponseResultC<''>>(MineApi.API_DELETE_COLLECTION_WEB, param)
        .then((data: ResponseResultC<''>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            resolve(data)
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

  //编辑收藏的网站
  updateCollectWeb(id: string, name: string, link: string): Promise<string> {
    this.showLoading()
    return new Promise<string>(async (resolve, reject) => {
      let param: Record<string, Object> = {
        "id": id,
        "name": name,
        "link": link
      }
      httpFormRequestPost<ResponseResultC<string>>(MineApi.API_UPDATE_COLLECTION_WEB, param)
        .then((data: ResponseResultC<string>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            resolve('修改成功')
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

let mCollectViewModel = new CollectViewModel()

export default mCollectViewModel as CollectViewModel