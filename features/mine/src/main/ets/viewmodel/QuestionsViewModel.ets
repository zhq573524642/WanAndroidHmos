import { BaseViewModel } from 'commons';
import { CommonArticlesBean, CommonPagingBean } from 'lib_components';
import { httpARequestGet, ResponseResultC } from 'utils';
import { MineApi } from '../api/MineApi';

class QuestionsViewModel extends BaseViewModel {
  //获取问答数据
  getQuestionsList(pageIndex: number): Promise<CommonPagingBean<CommonArticlesBean>> {
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(
        MineApi.API_WENDA_LIST + pageIndex + '/json'
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

let mQuestionsViewModel = new QuestionsViewModel()

export default mQuestionsViewModel as QuestionsViewModel