import { CommonArticlesBean } from "lib_components"

export default class HarmonyListBean {
  links: HMLinks = new HMLinks()
  open_sources: HMOpenSources = new HMOpenSources()
  tools: HMTools = new HMTools()
}

export class HMLinks {
  name: string = ''
  articleList: Array<CommonArticlesBean> = []
}

export class HMOpenSources {
  name: string = ''
  articleList: Array<CommonArticlesBean> = []
}

export class HMTools {
  name: string = ''
  articleList: Array<CommonArticlesBean> = []
}
