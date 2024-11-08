export class ResponseResultC<T> {
  /**  ，0成功 */
  errorCode: number;
  /**  数据 */
  data: T;
  /**  消息 */
  errorMsg: string;

  constructor(code: number, data: T, msg: string) {
    this.errorCode = code;
    this.data = data;
    this.errorMsg = msg;
  }
}


