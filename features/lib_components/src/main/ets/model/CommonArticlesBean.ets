import { CommonTagsBean } from "./CommonTagsBean"

@Observed
export class CommonArticlesBean {
  author: string = ''
  shareUser: string = ''
  superChapterName: string = ''
  chapterName: string = ''
  link: string = ''
  collect: boolean = false
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
  userId: number = 0
  originId:string=''
}