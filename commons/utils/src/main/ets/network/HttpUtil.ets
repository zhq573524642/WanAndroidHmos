import {
  AxiosError,
  AxiosProgressEvent,
  AxiosRequestConfig,
  AxiosResponse,
  CancelToken,
  CancelTokenSource,
  CancelTokenStatic,
  FormData
} from '@ohos/axios'

import axios from './ApiRequst'
import fs from '@ohos.file.fs';
import HashMap from '@ohos.util.HashMap';
import Logger from '../utils/Logger';

const cancelTokenStatic: CancelTokenStatic = axios.CancelToken
const requestMap: HashMap<string, object> = new HashMap();
let context = getContext(this)

export interface BaseParams {
  cancelToken?: CancelToken
  baseHostTag?: string
}

// header接口
export interface HeaderInterface {
  getHeader(): Record<string, string>
}

// 定义返回数据类型的泛型 T，默认值是 any
export function http<T, D>(option: AxiosRequestConfig<D>): Promise<T> {
  return new Promise((resolve: Function, reject: Function) => {
    const successHandler = (res: AxiosResponse<T>) => {
      if (res.status === 200) {
        if (res.data['code'] == 401) {
          // EventBus.getInstance().post(401)
          reject(res.data['info']);
        } else {
          resolve(res.data)
        }
      } else {
        reject(res.statusText);
      }
    }
    const failHandler = (error: AxiosError) => {
      if (error.response && error.response?.status === 401) {
        // EventBus.getInstance().post(401)
      } else {
        reject(error.message);
      }
      console.info(JSON.stringify(error));
    }

    // option.method = option.method || 'GET'
    //分配一个token
    // let cancelSource = cancelTokenStatic.source()

    if (option.params === undefined || option.params === null) {
      option.params = {}
    }
    // option.params.cancelToken = cancelSource.token
    //缓存起来
    // requestMap.set(option.url, cancelSource)
    //添加公共参数
    // this.addCommonParams(params)

    if (option.filePath !== undefined && option.filePath !== '') {
      try {
        fs.accessSync(option.filePath);
        fs.unlinkSync(option.filePath);
      } catch (err) {
      }
    }

    axios<T, AxiosResponse<T>, D>(option).then(successHandler).catch(failHandler)
  });
}

export function httpARequestGet<T>(url: string, params?: Record<string, Object>, host?: string,
  header?: HeaderInterface): Promise<T> {
  let option: AxiosRequestConfig = {
    url: url,
    baseURL: host,
    params: params,
    method: 'GET',
    headers: header?.getHeader()
  }
  return http<T, Record<string, Object>>(option);
}


export function httpBodyRequestPost<T>(url: string, params: Record<string, Object>, host?: string,
  header?: HeaderInterface): Promise<T> {
  let option: AxiosRequestConfig = {
    url: url,
    baseURL: host,
    data: params,
    method: 'POST',
    headers: header?.getHeader()
  }
  return http<T, Record<string, Object>>(option);
}

export function httpFormRequestPost<T>(url: string, params: Record<string, Object>, host?: string,
  header?: HeaderInterface): Promise<T> {
  let option: AxiosRequestConfig = {
    url: url,
    baseURL: host,
    params: params,
    method: 'POST',
    headers: header?.getHeader()
  }
  return http<T, Record<string, Object>>(option);
}


export function download(url: string, onDownloadProgress?: (progressEvent: AxiosProgressEvent) => void,
  savePath?: string, host?: string): Promise<string> {
  let filePath = savePath
  if (savePath === undefined) {
    let name = new Date().getTime();
    let endD = url.lastIndexOf('.')
    let suf = url.substring(endD + 1, url.length)
    filePath = context.cacheDir + `/${name}.${suf}`
  }
  let option: AxiosRequestConfig = {
    url: url,
    baseURL: host,
    method: 'get',
    context: context,
    filePath: filePath,
    onDownloadProgress: onDownloadProgress
  }
  return http<string, null>(option);

}


// let formData = new FormData();
// formData.append('file', buffer);
// formData.append('name', 'blue.jpg');
// uploadProgress = progressEvent && progressEvent.loaded && progressEvent.total ? Math.ceil(progressEvent.loaded / progressEvent.total * 100) : 0;
// 上传
export function upload<T>(url: string, formData: FormData,
  onUploadProgress?: (progressEvent: AxiosProgressEvent) => void, host?: string): Promise<T> {
  let option: AxiosRequestConfig<FormData> = {
    url: url,
    baseURL: host,
    method: 'post',
    context: context,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    data: formData,
    responseType: 'object',
    onUploadProgress: onUploadProgress
  }
  return http<T, FormData>(option);

}


//取消任务
export function cancel(url: string) {
  let source = requestMap.remove(url) as CancelTokenSource
  try {
    source.cancel('')
  } catch (e) {
    Logger.error(e)
  }
}

//取消所有任务
export function cancelAll() {
  requestMap.forEach((v, k) => {
    let source = v as CancelTokenSource
    try {
      source.cancel('')
    } catch (e) {
      Logger.error(e)
    }
  })
}