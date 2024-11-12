import { BaseViewModel } from 'commons';
import { CommonPagingBean } from 'lib_components';
import { httpARequestGet, ResponseResultC } from 'utils';
import { MineApi } from '../api/MineApi';
import { IntegralBean } from '../model/IntegralBean';

class IntegralViewModel extends BaseViewModel {

  getIntegralRankList(pageIndex: number): Promise<CommonPagingBean<IntegralBean>> {
    return new Promise<CommonPagingBean<IntegralBean>>(async (resolve, reject) => {

      httpARequestGet<ResponseResultC<CommonPagingBean<IntegralBean>>>(
        MineApi.API_INTEGRAL_RANK_LIST + pageIndex + '/json'
      )
        .then((data: ResponseResultC<CommonPagingBean<IntegralBean>>) => {
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

let mIntegralViewModel = new IntegralViewModel()

export default mIntegralViewModel as IntegralViewModel