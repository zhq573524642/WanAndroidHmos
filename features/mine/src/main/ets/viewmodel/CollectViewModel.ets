import { BaseViewModel } from 'commons';
import { httpARequestGet, httpFormRequestPost, ResponseResultC } from 'utils';
import { MineApi } from '../api/MineApi';
import { CollectionsBean } from '../model/CollectionsBean';
import { OfficialAccountBean } from '../model/OfficialAccountBean';

class CollectViewModel extends BaseViewModel {
  //获取收藏列表
  getCollectionsList(pageIndex: number): Promise<CollectionsBean> {
    return new Promise<CollectionsBean>(async (resolve, reject) => {

      httpARequestGet<ResponseResultC<CollectionsBean>>(MineApi.API_COLLECTIONS + pageIndex + '/json')
        .then((data: ResponseResultC<CollectionsBean>) => {
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

  handleCollect(id: string, originId: string): Promise<ResponseResultC<''>> {
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