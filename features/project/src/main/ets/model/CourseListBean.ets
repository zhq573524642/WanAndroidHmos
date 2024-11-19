export class CourseListBean {
  /**
   * "author": "阮一峰",
   "children": [],
   "courseId": 13,
   "cover": "https://www.wanandroid.com/blogimgs/f1cb8d34-82c1-46f7-80fe-b899f56b69c1.png",
   "desc": "C 语言入门教程。",
   "id": 548, // 单个教程下所有文章列表会使用到
   "lisense": "知识共享 署名-相同方式共享 3.0协议",
   "lisenseLink": "https://creativecommons.org/licenses/by-sa/3.0/deed.zh",
   "name": "C 语言入门教程_阮一峰",
   "order": 270000,
   "parentChapterId": 547,
   "userControlSetTop": false,
   "visible": 1
   */

  author: string = ''
  courseId: number = 0
  cover: string = ''
  desc: string = ''
  id: number = 0
  lisense: string = ''
  lisenseLink: string = ''
  name: string = ''
  userControlSetTop: boolean = false
  visible: number = 0
  order: number = 0
  parentChapterId: number = 0
}