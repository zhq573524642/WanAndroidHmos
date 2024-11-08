import { BaseViewModel } from 'commons/src/main/ets/base/BaseViewModel';
import HarmonyListBean from '../model/HarmonyListBean';
import { httpARequestGet, ResponseResultC } from 'utils';
import { HMApi } from '../api/HMApi';


class HMViewModel extends BaseViewModel {
  getHarmonyListData(): Promise<HarmonyListBean> {
    return new Promise<HarmonyListBean>(async (resolve: Function, reject: Function) => {
      httpARequestGet<ResponseResultC<HarmonyListBean>>(HMApi.API_HM_LIST)
        .then((data: ResponseResultC<HarmonyListBean>) => {
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

let mHMVewModel = new HMViewModel()

export default mHMVewModel as HMViewModel