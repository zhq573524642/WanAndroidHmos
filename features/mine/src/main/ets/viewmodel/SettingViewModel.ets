import { BaseViewModel } from 'commons/src/main/ets/base/BaseViewModel'
import { httpARequestGet, ResponseResultC } from 'utils'
import { MineApi } from '../api/MineApi'
import { ToolsListBean } from '../model/ToolsListBean'

class SettingViewModel extends BaseViewModel {
  getToolsListData(): Promise<Array<ToolsListBean>> {
    this.showLoading()
    return new Promise<Array<ToolsListBean>>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<Array<ToolsListBean>>>(
        MineApi.API_TOOLS_LIST
      ).then((data: ResponseResultC<Array<ToolsListBean>>) => {
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

  handleLogout(): Promise<string> {
    this.showLoading()
    return new Promise<string>(async (resolve, reject) => {
      httpARequestGet<ResponseResultC<string>>(MineApi.API_LOGOUT)
        .then((data: ResponseResultC<string>) => {
          this.hideLoading()
          if (data.errorCode === 0) {
            resolve('退出登录成功')
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

let mSettingViewModel = new SettingViewModel()

export default mSettingViewModel as SettingViewModel