import { BaseViewModel } from "commons";
import { httpARequestGet, ResponseResultC } from 'utils';
import { HomeApi } from '../api/HomeApi';
import { BannerData } from '../model/BannerData';
import { CommonArticlesBean, CommonPagingBean } from 'lib_components';

class HomeViewModel extends BaseViewModel {
  //获取首页Banner
  getHomeBannerData(): Promise<Array<BannerData>> {
    return new Promise<Array<BannerData>>(async (resolve: Function, reject: Function) => {
      httpARequestGet<ResponseResultC<Array<BannerData>>>(HomeApi.API_BANNER)
        .then((data: ResponseResultC<Array<BannerData>>) => {
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

  //获取首页文章列表
  getHomeArticleList(pageIndex: number): Promise<CommonPagingBean<CommonArticlesBean>> {
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve: Function, reject: Function) => {
      httpARequestGet<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(
        HomeApi.API_HOME_ARTICLE_LIST + '/' + pageIndex + '/json'
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

  //获取首页最受欢迎模块 1 学习，2 问答，3 专栏
  getHomeWelcomeTabData(type: number): Promise<Array<CommonArticlesBean>> {
    return new Promise<Array<CommonArticlesBean>>(async (resolve, reject) => {
      let url: string = ''
      switch (type) {
        case 1:
          url = HomeApi.API_WELCOME_LEARN
          break
        case 2:
          url = HomeApi.API_WELCOME_QUESTION
          break
        case 3:
          url = HomeApi.API_WELCOME_COLUMN
          break
      }
      httpARequestGet<ResponseResultC<Array<CommonArticlesBean>>>(url)
        .then((data: ResponseResultC<Array<CommonArticlesBean>>) => {
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

let mHomeViewModel = new HomeViewModel()

export default mHomeViewModel as HomeViewModel

