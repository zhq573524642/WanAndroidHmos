import { CommonTagsBean } from "./CommonTagsBean"

@ObservedV2
export class CommonArticlesBeanV2 {
  author: string = ''
  shareUser: string = ''
  superChapterName: string = ''
  chapterName: string = ''
  link: string = ''
  @Trace collect: boolean = false
  id: string = ''
  title: string = ''
  name: string = ''
  desc: string = ''
  niceDate: string = ''
  niceShareDate: string = ''
  zan: number = 0
  fresh: boolean = false
  tags: Array<CommonTagsBean> = []
  envelopePic: string = ''
  projectLink: string = ''
}