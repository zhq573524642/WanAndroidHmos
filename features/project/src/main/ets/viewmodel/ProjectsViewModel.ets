import { BaseViewModel } from 'commons';
import { CommonArticlesBean, CommonPagingBean } from 'lib_components';
import { httpARequestGet, ResponseResultC } from 'utils';
import { ProjectsApi } from '../api/ProjectsApi';
import { ProjectTypeBean } from '../model/ProjectTypeBean';

class ProjectsViewModel extends BaseViewModel {
  getProjectsType(): Promise<Array<ProjectTypeBean>> {
    this.showLoading()
    return new Promise<Array<ProjectTypeBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<Array<ProjectTypeBean>>>(
        ProjectsApi.API_PROJECTS_TYPE
      )
        .then((data: ResponseResultC<Array<ProjectTypeBean>>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            resolve(data.data)
          } else {
            reject(data.errorMsg)
          }
        })
        .catch((error: string) => {
          this.hideLoading()
          reject(error)
        })
    })
  }

  getProjectsList(pageIndex: number, cid: string): Promise<CommonPagingBean<CommonArticlesBean>> {
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve, reject) => {

      httpARequestGet<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(
        ProjectsApi.API_PROJECT_LIST + pageIndex + '/json?cid=' + cid
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

let mProjectsViewModel = new ProjectsViewModel()

export default mProjectsViewModel as ProjectsViewModel