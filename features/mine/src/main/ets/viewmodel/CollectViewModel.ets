import { BaseViewModel } from 'commons';
import { httpARequestGet, ResponseResultC } from 'utils';
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
}

let mCollectViewModel = new CollectViewModel()

export default mCollectViewModel as CollectViewModel