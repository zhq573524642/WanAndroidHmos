import { BaseViewModel } from 'commons';
import { CommonPagingBean } from 'lib_components';
import { httpARequestGet, ResponseResultC } from 'utils';
import { MessageBean } from '../model/MessageBean';

class MessageViewModel extends BaseViewModel {
  //获取消息列表
  getMsgList(isRead: boolean, pageIndex: number): Promise<CommonPagingBean<MessageBean>> {
    return new Promise<CommonPagingBean<MessageBean>>(async (resolve, reject) => {
      let url = ''
      if (isRead) {
        url = 'message/lg/readed_list/' + pageIndex + '/json'
      } else {
        url = 'message/lg/unread_list/' + pageIndex + '/json'
      }
      httpARequestGet<ResponseResultC<CommonPagingBean<MessageBean>>>(url)
        .then((data: ResponseResultC<CommonPagingBean<MessageBean>>) => {
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

let mMessageViewModel = new MessageViewModel()

export default mMessageViewModel as MessageViewModel