import { BaseViewModel } from 'commons/src/main/ets/base/BaseViewModel';
import { SystemChildrenList, SystemsListBean } from '../model/SystemsListBean';
import { httpARequestGet, ResponseResultC } from 'utils';
import { ProjectsApi } from '../api/ProjectsApi';
import { CommonArticlesBean, CommonPagingBean } from 'lib_components';


class SystemsViewModel extends BaseViewModel {
  getSystemsList(): Promise<Array<SystemsListBean>> {
    return new Promise<Array<SystemsListBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<Array<SystemsListBean>>>(ProjectsApi.API_SYSTEMS_LIST)
        .then((data: ResponseResultC<Array<SystemsListBean>>) => {
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

  getSystemsChildList(pageIndex: number, id: number): Promise<CommonPagingBean<CommonArticlesBean>> {
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(
        'article/list/' + pageIndex + '/json?cid=' + id
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

  getSearchAuthorData(pageIndex: number, author: string): Promise<CommonPagingBean<CommonArticlesBean>> {
    this.showMsgLoading('搜索中..')
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(
        'article/list/' + pageIndex + '/json?author=' + author
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

let mSystemsViewModel = new SystemsViewModel()

export default mSystemsViewModel as SystemsViewModel