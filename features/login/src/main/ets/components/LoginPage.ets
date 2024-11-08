import { App, router } from '@kit.ArkUI';
import { AppConstant, PreferenceManager, ToastUtil } from 'utils';
import { LoginResultBean } from '../model/LoginResultBean';
import { InputComponent } from '../view/InputComponent';
import { TitleBarComponent } from '../view/TitleBarComponent';
import mLoginViewModel from '../viewmodel/LoginViewModel';

const view_width_percent: string = '80%'

@Entry({ routeName: 'LoginPage' })
@Component
export struct LoginPage {
  @State isLoginLayout: boolean = true
  @State isHaveAccount: boolean = true
  @State inputAccount: string = ''
  @State inputPwd1: string = ''
  @State inputPwd2: string = ''

  build() {
    Column() {
      Image(this.isLoginLayout ? $r('app.media.ic_close_page') : $r('app.media.ic_back_black'))
        .objectFit(ImageFit.Fill)
        .width(30)
        .height(30)
        .padding(5)
        .margin(20)
        .onClick(() => {
          if (this.isLoginLayout) {
            router.back()
          } else {
            this.isLoginLayout = true
          }
        })
      Column() {
        if (this.isLoginLayout) {
          if (this.isHaveAccount) {
            this.AccountView()
          } else {
            this.LoginView()
          }
        } else {
          this.RegisterView()
        }

      }.width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)
    }.backgroundColor('#c9eaf9')
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  changeLayout(isLoginLayout: boolean, isHaveAccount: boolean) {
    this.isLoginLayout = isLoginLayout
    this.isHaveAccount = isHaveAccount
  }

  private requestLogin() {
    if (this.inputAccount.length <= 0) {
      ToastUtil.showToast('请输入账号')
      return
    }
    if (this.inputPwd1.length <= 0) {
      ToastUtil.showToast('请输入密码')
      return
    }
    if (this.inputPwd1.length < 6) {
      ToastUtil.showToast('密码不得小于6位')
      return
    }
    mLoginViewModel.login(this.inputAccount, this.inputPwd1)
      .then((data: LoginResultBean) => {
        if (data.id !== '') {
          ToastUtil.showToast('登录成功')
          AppConstant.TOKEN = data.token
          AppConstant.USERNAME = data.username
          AppConstant.PASSWORD = data.password
          AppConstant.ID = data.id
          PreferenceManager.getInstance().setValue(AppConstant.KEY_USERNAME,data.username)
          PreferenceManager.getInstance().setValue(AppConstant.KEY_PASSWORD,data.password)
          PreferenceManager.getInstance().setValue(AppConstant.USER_ID, data.id)
            .then(() => {
              router.back()
            })
        }
      })
      .catch((msg: string) => {
        ToastUtil.showToast(msg)
      })
  }

  private requestRegister() {
    if (this.inputAccount.length <= 0) {
      ToastUtil.showToast('请输入账号')
      return
    }
    if (this.inputPwd1.length <= 0) {
      ToastUtil.showToast('请输入密码')
      return
    }
    if (this.inputPwd1.length < 6) {
      ToastUtil.showToast('密码不得小于6位')
      return
    }
    if (this.inputPwd2.length <= 0) {
      ToastUtil.showToast('请再次输入密码')
      return
    }
    if (this.inputPwd1 !== this.inputPwd2) {
      ToastUtil.showToast('两次密码输入不一致')
      return
    }
    mLoginViewModel.register(this.inputAccount, this.inputPwd1, this.inputPwd2)
      .then((data: LoginResultBean) => {
        if (data.username !== '') {
          ToastUtil.showToast('注册成功')
          this.requestLogin()
        }
      })
      .catch((msg: string) => {
        ToastUtil.showToast(msg)
      })
  }

  @Builder
  LoginView() {
    LoginAvatar({
      title: '欢迎登录'
    })
    Column({ space: 25 }) {
      LoginInput({
        title: '账号',
        placeholder: '请输入账号',
        inputContent: this.inputAccount
      })
      LoginInput({
        title: '密码',
        placeholder: '请输入密码',
        inputType: InputType.Password,
        inputContent: this.inputPwd1
      })
      LoginButton({
        title: '立即登录',
        onButtonClick: () => {
          this.requestLogin()
        }
      })
      Text('注册')
        .fontSize(14)
        .fontColor($r('app.color.color_login_theme'))
        .onClick(() => {
          this.changeLayout(false, this.isHaveAccount)
        })
    }.width('100%')

  }

  @Builder
  AccountView() {
    LoginAvatar({
      title: '用户1232243444'
    })
    Column({ space: 25 }) {
      LoginButton({
        title: '以此账号登录',
        onButtonClick: () => {

        }
      })
      LoginButton({
        title: '不是你？换个账号',
        onButtonClick: () => {
          this.changeLayout(true, false)
        }
      })
      Text('注册')
        .fontSize(14)
        .fontColor($r('app.color.color_login_theme'))
        .onClick(() => {
          this.changeLayout(false, this.isHaveAccount)
        })
    }.width('100%')

  }

  @Builder
  RegisterView() {
    LoginAvatar({
      title: '欢迎注册'
    })
    Column({ space: 25 }) {
      LoginInput({
        title: '账号',
        placeholder: '请输入账号',
        inputContent: this.inputAccount
      })
      LoginInput({
        title: '密码',
        placeholder: '请输入密码',
        inputType: InputType.Password,
        inputContent: this.inputPwd1
      })
      LoginInput({
        title: '确认密码',
        placeholder: '请再次输入密码',
        inputType: InputType.Password,
        inputContent: this.inputPwd2
      })
      LoginButton({
        title: '立即注册',
        onButtonClick: () => {
          this.requestRegister()
        }
      })
    }.width('100%')
  }
}

@Component
struct LoginButton {
  title: string = ''
  onButtonClick?: () => void

  build() {
    Button(this.title)
      .backgroundColor($r('app.color.color_login_theme'))
      .fontColor(Color.White)
      .fontSize(14)
      .width(view_width_percent)
      .onClick(() => {
        this.onButtonClick?.()
      })
  }
}

@Component
struct LoginInput {
  title: string = ''
  placeholder?: string = '请输入内容'
  inputType?: InputType = InputType.Normal
  @Link inputContent: string

  build() {
    Column() {
      Text(this.title)
        .fontColor($r('app.color.color_262626'))
        .fontSize(13)
      TextInput({ placeholder: this.placeholder, text: $$this.inputContent })
        .width('100%')
        .height(40)
        .type(this.inputType)
        .placeholderFont({ size: 13 })
        .placeholderColor($r('app.color.color_999999'))
        .fontSize(13)
        .padding(0)
        .borderWidth(0)
        .borderRadius(0)
        .textAlign(TextAlign.Start)
        .fontColor($r('app.color.color_262626'))
        .backgroundColor(Color.Transparent)

    }
    .width(view_width_percent)
    .borderRadius(15)
    .padding(13)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
  }
}

@Component
struct LoginAvatar {
  title: string = ''

  build() {
    Column() {
      Image($r('app.media.ic_login_default_avatar'))
        .width(100)
        .height(100)
        .borderRadius(60)
        .borderWidth(2)
        .padding(2)
        .borderColor(Color.White)
        .objectFit(ImageFit.Cover)
      Text(this.title)
        .fontSize(16)
        .fontColor($r('app.color.color_login_theme'))
        .margin({ top: 20 })

    }
  }
}


