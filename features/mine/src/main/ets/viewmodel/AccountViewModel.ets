import { BaseViewModel } from 'commons';
import { httpARequestGet, ResponseResultC } from 'utils';
import { MineApi } from '../api/MineApi';
import { CollectionsBean } from '../model/CollectionsBean';
import { OfficialAccountBean } from '../model/OfficialAccountBean';

class AccountViewModel extends BaseViewModel {


  //获取公众号列表
  getOfficialAccountsList(): Promise<Array<OfficialAccountBean>> {
    return new Promise<Array<OfficialAccountBean>>(async (resolve, reject) => {

      httpARequestGet<ResponseResultC<Array<OfficialAccountBean>>>(MineApi.API_WXARTICLE_LIST)
        .then((data: ResponseResultC<Array<OfficialAccountBean>>) => {
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

let mAccountViewModel = new AccountViewModel()

export default mAccountViewModel as AccountViewModel