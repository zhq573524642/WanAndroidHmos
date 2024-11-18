import { AppConstant, EmitterUtils, ResponseResultC, ToastUtil } from "utils"
import { DateUtil } from "utils/src/main/ets/utils/DateUtil"
import mTodoViewModel from "../viewmodel/TodoViewModel"
import { CreateTodoDialog } from "./CreateTodoDialog"
import { TodoListComponent } from "./TodoListComponent"

@Builder
export function MyTodoPageBuilder() {
  MyTodoPage()
}


@Component
export struct MyTodoPage {
  navPathStack: NavPathStack = new NavPathStack()
  @State currentTabIndex: number = 0
  @State type: number = 0 //工作1；生活2；娱乐3；
  @State status: number = 0 // 0为未完成，1为完成
  @State priority: number = 0 //1重要 2一般
  @State orderby: number = 4 //1:完成日期顺序；2.完成日期逆序；3.创建日期顺序；4.创建日期逆序(默认)；
  createTodoDialogController: CustomDialogController = new CustomDialogController({
    builder: CreateTodoDialog({
      onSaveCreateTodoCallback: (title: string, desc: string, date: string,
        type: number, priority: number) => {
        this.requestCreateTodo(title, desc, date, type, priority)
      }
    }),
    backgroundColor: Color.White,
    autoCancel: true,
    alignment: DialogAlignment.Center,
    cornerRadius: 10
  })

  private requestCreateTodo(title: string, desc: string, date: string,
    type: number, priority: number) {
    mTodoViewModel.createTodo(title, desc, date, type, priority)
      .then((data: ResponseResultC<''>) => {
        if (data.errorCode === 0) {
          ToastUtil.showCenterToast('创建成功')
          this.createTodoDialogController.close()
          EmitterUtils.getInstance().post(AppConstant.FLAG_CREATE_TODO)
        }
      })
      .catch((msg: string) => {
        ToastUtil.showCenterToast(msg)
      })
  }

  build() {
    NavDestination() {
      Column() {
        Tabs() {
          TabContent() {
            TodoListComponent({
              type: this.type,
              status: 0,
              priority: this.priority,
              orderby: this.orderby
            })
          }.tabBar(this.TodoTabs(0, '待办清单'))

          TabContent() {
            TodoListComponent({
              type: this.type,
              status: 1,
              priority: this.priority,
              orderby: this.orderby
            })
          }.tabBar(this.TodoTabs(1, '已完成清单'))

        }
        .barMode(BarMode.Fixed)
        .barHeight(56)
        .onTabBarClick((index: number) => {
          this.currentTabIndex = index
        })
        .onChange((index: number) => {
          EmitterUtils.getInstance().post(AppConstant.FLAG_CREATE_TODO)
          this.currentTabIndex = index
        })

      }.width('100%')
      .height('100%')
    }
    .title('TODO')
    .menus([
      {
        value: '新建TODO',
        icon: "resources/base/media/ic_new_create_todo.png",
        action: () => {
          this.createTodoDialogController.open()
        }
      }
    ])
    .mode(NavDestinationMode.STANDARD)
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack
    })
  }

  @Builder
  TodoTabs(index: number, barName: ResourceStr) {
    Column() {
      Text(barName)
        .fontColor(index === this.currentTabIndex ? Color.Blue : Color.Gray)
        .fontWeight(index === this.currentTabIndex ? FontWeight.Medium : FontWeight.Normal)
        .fontSize(16)
        .margin({ top: 8, bottom: 5 })
      Divider()
        .strokeWidth(2)
        .lineCap(LineCapStyle.Round)
        .width(32)
        .color(index === this.currentTabIndex ? Color.Blue : Color.Transparent)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
  }
}


