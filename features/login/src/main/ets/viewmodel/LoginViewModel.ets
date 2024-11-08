import { BaseViewModel } from 'commons/src/main/ets/base/BaseViewModel';
import { httpFormRequestPost, ResponseResultC } from 'utils';
import { LoginApi } from '../api/LoginApi';
import { LoginResultBean } from '../model/LoginResultBean';

class LoginViewModel extends BaseViewModel {
  register(username: string, password: string, repassword: string): Promise<LoginResultBean> {
    this.showMsgLoading('正在注册..')
    return new Promise<LoginResultBean>(async (resolve, reject) => {
      let params: Record<string, Object> = {
        "username": username,
        "password": password,
        "repassword": repassword
      }
      httpFormRequestPost<ResponseResultC<LoginResultBean>>(LoginApi.API_REGISTER, params)
        .then((data: ResponseResultC<LoginResultBean>) => {
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

  login(username: string, password: string): Promise<LoginResultBean> {
    this.showMsgLoading('正在登录..')
    return new Promise<LoginResultBean>(async (resolve, reject) => {
      let params: Record<string, Object> = {
        "username": username,
        "password": password
      }
      httpFormRequestPost<ResponseResultC<LoginResultBean>>(LoginApi.API_LOGIN, params)
        .then((data: ResponseResultC<LoginResultBean>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            data.data.password = password
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
}

let mLoginViewModel = new LoginViewModel()

export default mLoginViewModel as LoginViewModel