import { BaseViewModel } from 'commons';
import { CommonPagingBean } from 'lib_components';
import { httpARequestGet, ResponseResultC } from 'utils';
import { MineApi } from '../api/MineApi';
import { IntegralBean } from '../model/IntegralBean';
import { IntegralRecordBean } from '../model/IntegralRecordBean';

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

  getIntegralRecordList(pageIndex: number): Promise<CommonPagingBean<IntegralRecordBean>> {
    return new Promise<CommonPagingBean<IntegralRecordBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<CommonPagingBean<IntegralRecordBean>>>(
        MineApi.API_GET_INTEGRAL_RECORD_LIST + pageIndex + '/json'
      )
        .then((data: ResponseResultC<CommonPagingBean<IntegralRecordBean>>) => {
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