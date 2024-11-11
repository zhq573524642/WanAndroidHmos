import { CommonArticlesBean } from "lib_components";
import LazyDataSource from "utils/src/main/ets/utils/LazyDataSource";

@Observed
export class NavigationData {
  cid: number = 0
  articles: Array<CommonArticlesBean> =[]
  name: string = ''
}

