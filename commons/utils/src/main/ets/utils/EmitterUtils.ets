import emitter from '@ohos.events.emitter'

export  class EmitterUtils{

  private static instance: EmitterUtils

  private constructor() {

  }
  static getInstance(): EmitterUtils {
    if (!EmitterUtils.instance) {
      EmitterUtils.instance = new EmitterUtils()
    }
    return EmitterUtils.instance
  }

  //持续订阅指定的事件，并在接收到该事件时，执行对应的回调处理函数。
  on(name:number,callback:(eventData:emitter.EventData)=>void){
    let event :emitter.InnerEvent={
      eventId:name, //事件ID
      priority:emitter.EventPriority.IMMEDIATE //事件立即被投递
    }
    emitter.on(event,callback)
  }


  //取消针对该事件ID的订阅，传入可选参数callback，并且该callback已经通过on或者once接口订阅，则取消该订阅；否则，不做任何处理。
  unregister(name:number){
    emitter.off(name)
  }
  //发送指定的事件
  post(name:number,data?:emitter.EventData){
    let event :emitter.InnerEvent={
      eventId:name, //事件ID
      priority:emitter.EventPriority.IMMEDIATE //事件立即被投递
    }
    let eventdata: emitter.EventData = {
      data:data
    }
    emitter.emit(event,eventdata)
  }

  postCode(name:number,code:number){
    let event :emitter.InnerEvent={
      eventId:name, //事件ID
      priority:emitter.EventPriority.IMMEDIATE //事件立即被投递
    }
    let eventdata: emitter.EventData = {
      data:{'code':code}
    }
    emitter.emit(event,eventdata)
  }
}