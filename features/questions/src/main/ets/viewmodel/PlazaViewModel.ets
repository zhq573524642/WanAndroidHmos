import { BaseViewModel } from 'commons';
import { CommonArticlesBean, CommonPagingBean } from 'lib_components';
import { httpARequestGet, ResponseResultC } from 'utils';
import { QuestionsApi } from '../api/QuestionsApi';

class PlazaViewModel extends BaseViewModel {
  getPlazaDataList(pageIndex: number): Promise<CommonPagingBean<CommonArticlesBean>> {
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(
        QuestionsApi.API_PLAZA_LISTs + pageIndex + '/json'
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
}

let mPlazaViewModel = new PlazaViewModel()

export default mPlazaViewModel as PlazaViewModel