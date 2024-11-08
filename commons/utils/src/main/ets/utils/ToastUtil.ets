import promptAction from '@ohos.promptAction'

let duration = 3000

export enum ToastPosition {
  top = '90%',
  center = '50%',
  bottom = '10%',
}

/**
 * @Author csx
 * @DateTime 2024/1/24 19:31
 * @TODO ToastUtil 文本提示框工具类
 */
export class ToastUtil {
  /**
   * 弹出文本消息提示框,默认时长为2s,距离底部默认为20vp
   * @param msg 提示消息
   * @param options: {duration:'',bottom:'',showMode:0}  提示参数duration为显示时长，bottom为距离底部位置,showMode设置弹窗是否显示在应用之上0内,1上
   */
  static showToast(msg: ResourceStr, options?: toastOptions): void {
    if (!options) {
      options = new toastOptions();
    }
    promptAction.showToast({
      message: msg,
      duration: options.duration,
      bottom: options.bottom
    })
  }

  static showCenterToast(msg: ResourceStr) {
    promptAction.showToast({
      message: msg,
      alignment: Alignment.Center
    })
  }
}

/**
 * toast弹窗入参对象
 */
class toastOptions {
  duration: number = 2000;
  bottom: string | number = '50vp';
  showMode: number = 0;
}