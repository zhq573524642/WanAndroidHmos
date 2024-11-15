import { BaseViewModel } from 'commons';
import { CommonPagingBean } from 'lib_components';
import { httpARequestGet, httpFormRequestPost, ResponseResultC } from 'utils';
import { MineApi } from '../api/MineApi';
import { TodoList } from '../model/TodoListBean';
import { data } from '@kit.TelephonyKit';

class TodoViewModel extends BaseViewModel {
  getTodoList(pageIndex: number, status: number, type: number,
    orderby: number, priority: number): Promise<CommonPagingBean<TodoList>> {
    return new Promise<CommonPagingBean<TodoList>>(async (resolve, reject) => {
      let url = MineApi.API_TODO_LIST
        + pageIndex + '/json?status=' + status
        + '&type=' + type + '&orderby=' + orderby + '&priority=' + priority
      httpARequestGet<ResponseResultC<CommonPagingBean<TodoList>>>(url)
        .then((data: ResponseResultC<CommonPagingBean<TodoList>>) => {
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

  /**
   *
   title: 新增标题（必须）
   content: 新增详情（必须）
   date: 2018-08-01 预定完成时间（不传默认当天，建议传）
   type: 大于0的整数（可选）；
   priority 大于0的整数（可选）；
   * @returns
   */
  createTodo(title: string, desc: string, date: string,
    type: number, priority: number): Promise<ResponseResultC<''>> {
    this.showLoading()
    return new Promise<ResponseResultC<''>>(async (resolve, reject) => {
      let params: Record<string, Object> = {
        "title": title,
        "content": desc,
        "date": date,
        "type": type,
        "priority": priority
      }

      httpFormRequestPost<ResponseResultC<''>>(MineApi.API_TODO_CREATE, params)
        .then((data: ResponseResultC<''>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            resolve(data)
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

  updateTodo(id: string, title: string, desc: string, date: string,
    type: number, priority: number): Promise<ResponseResultC<''>> {
    this.showLoading()
    return new Promise<ResponseResultC<''>>(async (resolve, reject) => {
      let params: Record<string, Object> = {
        "title": title,
        "content": desc,
        "date": date,
        "status": 0,
        "type": type,
        "priority": priority
      }
      let url = MineApi.API_TODO_UPDATE + id + '/json'
      httpFormRequestPost<ResponseResultC<''>>(url, params)
        .then((data: ResponseResultC<''>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            resolve(data)
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
}

let mTodoViewModel = new TodoViewModel()

export default mTodoViewModel as TodoViewModel