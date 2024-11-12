import { BaseViewModel } from 'commons';
import { httpARequestGet, ResponseResultC } from 'utils';
import { MineApi } from '../api/MineApi';
import { UserInfoBean } from '../model/UserInfoBean';

class MineViewModel extends BaseViewModel {
  getUserInfo(): Promise<UserInfoBean> {
    return new Promise<UserInfoBean>(async (resolve, reject) => {

      httpARequestGet<ResponseResultC<UserInfoBean>>(
        MineApi.API_GET_USER_INFO
      )
        .then((data: ResponseResultC<UserInfoBean>) => {
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

let mMineViewModel = new MineViewModel()

export default mMineViewModel as MineViewModel