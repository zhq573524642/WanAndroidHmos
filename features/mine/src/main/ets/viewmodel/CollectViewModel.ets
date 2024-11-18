import { BaseViewModel } from 'commons';
import { CommonArticlesBean, CommonPagingBean } from 'lib_components';
import { httpARequestGet, httpFormRequestPost, ResponseResultC } from 'utils';
import { MineApi } from '../api/MineApi';

class CollectViewModel extends BaseViewModel {
  //获取收藏列表
  getCollectionsList(pageIndex: number): Promise<CommonPagingBean<CommonArticlesBean>> {
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve, reject) => {

      httpARequestGet<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(MineApi.API_COLLECTIONS + pageIndex + '/json')
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
}

let mCollectViewModel = new CollectViewModel()

export default mCollectViewModel as CollectViewModel