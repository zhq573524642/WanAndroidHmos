import router from '@ohos.router';

export class RouterUtil {
  static pushUrl(url: string, param?: Record<string, Object>) {
    router.pushUrl({
      url: url,
      params: param
    }).catch((error: Error) => {
      AlertDialog.show({ message: JSON.stringify(error) })
    });
  }

  static pushNamedRoute(name: string, param?: Record<string, Object>) {
    router.pushNamedRoute({
      name: name,
      params: param
    }).catch((error: Error) => {
      AlertDialog.show({ message: JSON.stringify(error) })
    });
  }

  static replaceNamedRoute(name: string, param?: Record<string, Object>) {
    router.replaceNamedRoute({
      name: name,
      params: param
    }).catch((error: Error) => {
      AlertDialog.show({ message: JSON.stringify(error) })
    });
  }

  static replaceNamedRouteSingle(name: string, param?: Record<string, Object>) {
    router.replaceNamedRoute({
      name: name,
      params: param
    }, router.RouterMode.Single).catch((error: Error) => {
      AlertDialog.show({ message: JSON.stringify(error) })
    });
  }

  static pushNamedRouteSingle(name: string, param?: Record<string, Object>) {
    router.pushNamedRoute({
      name: name,
      params: param
    }, router.RouterMode.Single).catch((error: Error) => {
      AlertDialog.show({ message: JSON.stringify(error) })
    });
  }

  static replaceUrl(url: string, param?: Record<string, Object>) {
    router.replaceUrl({
      url: url,
      params: param
    }).catch((error: Error) => {
      AlertDialog.show({ message: JSON.stringify(error) })
    });
  }

  static back(url: string, param?: Record<string, Object>) {
    router.back({
      url: url,
      params: param
    })
  }

  static clear() {
    router.clear()
  }

  static getParams(): Record<string, Object> {
    return router.getParams() as Record<string, Object>
  }

  static getVOfKey(key: string): Object {
    let params = router.getParams() as Record<string, Object>
    return params[key] ?? undefined
  }
}