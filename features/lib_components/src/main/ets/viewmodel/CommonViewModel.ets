import { httpARequestGet, ResponseResultC } from "utils"
import { CommonUserArticlesBean } from "../model/CommonUserArticlesBean"

export class CommonViewModel {
  static instance: CommonViewModel

  public static getInstance(): CommonViewModel {
    if (CommonViewModel.instance == null) {
      CommonViewModel.instance = new CommonViewModel()
    }
    return CommonViewModel.instance
  }

  getArticlesList(userId: number, pageIndex: number): Promise<CommonUserArticlesBean> {

    return new Promise<CommonUserArticlesBean>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<CommonUserArticlesBean>>(
        'user/' + userId + '/share_articles/' + pageIndex + '/json'
      )
        .then((data: ResponseResultC<CommonUserArticlesBean>) => {
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