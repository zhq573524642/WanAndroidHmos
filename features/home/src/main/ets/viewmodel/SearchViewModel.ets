import { BaseViewModel } from 'commons';
import { httpARequestGet, httpFormRequestPost, ResponseResultC } from 'utils';
import { HomeApi } from '../api/HomeApi';
import { CommonWebSiteBean } from '../model/CommonWebSiteBean';
import { SearchHotWord } from '../model/SearchHotWordBean';
import { resourceManager } from '@kit.LocalizationKit';
import { CommonArticlesBean, CommonPagingBean } from 'lib_components';

class SearchViewModel extends BaseViewModel {
  getSearchHotWord(): Promise<Array<SearchHotWord>> {
    return new Promise<Array<SearchHotWord>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<Array<SearchHotWord>>>(HomeApi.API_SEARCH_HOT_WORD)
        .then((data: ResponseResultC<Array<SearchHotWord>>) => {
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

  getCommonWebSite(): Promise<Array<CommonWebSiteBean>> {
    return new Promise<Array<CommonWebSiteBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<Array<CommonWebSiteBean>>>(HomeApi.API_WEB_SITE)
        .then((data: ResponseResultC<Array<CommonWebSiteBean>>) => {
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

  getHomeArticleQuery(pageIndex: number, key: string): Promise<CommonPagingBean<CommonArticlesBean>> {
    this.showLoading()
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve, reject) => {
      let url = HomeApi.API_HOME_SEARCH + pageIndex + '/json'
      let param: Record<string, Object> = {
        "k": key
      }
      httpFormRequestPost<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(url, param)
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

let mSearchViewModel = new SearchViewModel()

export default mSearchViewModel as SearchViewModel