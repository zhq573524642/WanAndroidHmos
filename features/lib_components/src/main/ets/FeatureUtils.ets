import { ArkTSUtils, util } from "@kit.ArkTS";
import { httpFormRequestPost } from "utils/src/main/ets/network/HttpUtil";
import { ResponseResultC } from "utils/src/main/ets/network/ResponseResult";


export class FeatureUtils {
  static instance: FeatureUtils

  static getInstance(): FeatureUtils {
    if (FeatureUtils.instance == null) {
      FeatureUtils.instance = new FeatureUtils()
    }
    return FeatureUtils.instance
  }

  static getRandomColor() {
    const letters: string = '0123456789ABCDEF';
    let color: string = '#';
    for (let i = 0; i < 6; i++) {
      let Itemp: number = Math.floor(Math.random() * 16)
      color += letters[Itemp];
    }
    console.log(color)
    return color;
  }


  //收藏文章
  handleCollectArticle(id: string): Promise<ResponseResultC<''>> {
    return new Promise<ResponseResultC<''>>(async (resolve, reject) => {
      httpFormRequestPost<ResponseResultC<''>>('lg/collect/' + id + '/json', {})
        .then((data: ResponseResultC<''>) => {
          if (data.errorCode === 0) {
            resolve(data)
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