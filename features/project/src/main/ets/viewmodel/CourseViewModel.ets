import { BaseViewModel } from 'commons';
import { CommonArticlesBean, CommonPagingBean } from 'lib_components';
import { httpARequestGet, ResponseResultC } from 'utils';
import { ProjectsApi } from '../api/ProjectsApi';
import { CourseListBean } from '../model/CourseListBean';

class CourseViewModel extends BaseViewModel {
  getCourseList(): Promise<Array<CourseListBean>> {
    return new Promise<Array<CourseListBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<Array<CourseListBean>>>(ProjectsApi.API_COURSE_LIST)
        .then((data: ResponseResultC<Array<CourseListBean>>) => {
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

  getCourseDetailList(pageIndex:number,id:number): Promise<CommonPagingBean<CommonArticlesBean>> {
    return new Promise<CommonPagingBean<CommonArticlesBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<CommonPagingBean<CommonArticlesBean>>>(
        'article/list/'+pageIndex+'/json?cid='+id+'&order_type=1'
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

let mCourseViewModel = new CourseViewModel()

export default mCourseViewModel as CourseViewModel