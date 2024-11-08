import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { AppConstant } from '../../../../Index'
import Logger from '../utils/Logger'
import { PreferenceManager } from '../utils/PreferenceManager'
import { HashSet } from '@kit.ArkTS'


axios.defaults.baseURL = 'https://www.wanandroid.com/'

export function setHost(hostUrl: string) {
  axios.defaults.baseURL = hostUrl
}

export function setHeader(key: string, value: string) {
  axios.defaults.headers.common[key] = value
}

//添加请求拦截器
axios.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  // 对请求数据做点什么
  config.headers['token'] = AppConstant.TOKEN
  PreferenceManager.getInstance().getValue<string[]>(AppConstant.COOKIE)
    .then((value: string[] | null) => {
      let cacheCookies = ['loginUserName=' + AppConstant.USERNAME, 'loginUserPassword=' + AppConstant.PASSWORD]
      if (value !== null) {
        value.forEach((cookie: string) => {
          cacheCookies.push(cookie)
        })
      }
      config.headers['cookie'] = cacheCookies
    })
  if (config.method == 'get' || config.method == 'GET') {
    Logger.debug(`===请求：${config.method}=${config.baseURL}${config.url}`, JSON.stringify(config.headers),
      JSON.stringify(config.params))
  } else {
    Logger.debug(`===请求${config.method}=${config.baseURL}${config.url}`,
      JSON.stringify(config.headers), JSON.stringify(config.data ?? config.params))
  }

  return config;
}, (error: AxiosError) => {
  // 对请求错误做些什么
  return Promise.reject(error);
});

// 添加响应拦截器
axios.interceptors.response.use((response: AxiosResponse) => {
  Logger.debug('===响应=' + response.config.url, JSON.stringify(response.data))
  // Logger.debug('===Header:' + JSON.stringify(response.headers))
  // 对响应数据做点什么
  if (response.config.url?.includes('user/login')) {
    let cookies: string[] | undefined = response.headers['set-cookie']
    if (cookies && cookies.length > 0) {
      PreferenceManager.getInstance().setValue(AppConstant.COOKIE, cookies)
    }
  }
  return response;
}, (error: AxiosError) => {
  // 对响应错误做点什么
  Logger.debug('===响应 error=' + error.response?.config.url + error.message)
  return Promise.reject(error);
});

export default axios