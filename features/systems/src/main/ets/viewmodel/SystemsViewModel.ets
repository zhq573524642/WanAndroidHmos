import { BaseViewModel } from 'commons/src/main/ets/base/BaseViewModel';
import { SystemChildrenList, SystemsListBean } from '../model/SystemsListBean';
import { httpARequestGet, ResponseResultC } from 'utils';
import { SystemsApi } from '../api/SystemsApi';
import SystemsArticleListBean, { ArticlesData } from '../model/SystemsArticleListBean';


class SystemsViewModel extends BaseViewModel {
  getSystemsList(): Promise<Array<SystemsListBean>> {
    return new Promise<Array<SystemsListBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<Array<SystemsListBean>>>(SystemsApi.API_SYSTEMS_LIST)
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

  getSystemsChildList(pageIndex: number, id: number): Promise<SystemsArticleListBean> {
    return new Promise<SystemsArticleListBean>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<SystemsArticleListBean>>(
        'article/list/' + pageIndex + '/json?cid=' + id
      )
        .then((data: ResponseResultC<SystemsArticleListBean>) => {
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
}

let mSystemsViewModel = new SystemsViewModel()

export default mSystemsViewModel as SystemsViewModel