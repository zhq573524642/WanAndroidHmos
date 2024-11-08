import { LoadingDialog } from '../components/LoadingDialog'

export class BaseViewModel {
  private loadingDialog?: LoadingDialog

  showLoading() {
    if (!this.loadingDialog) {
      this.loadingDialog = new LoadingDialog();
    }
    this.loadingDialog.showLoading()
  }

  showMsgLoading(msg: string) {
    if (!this.loadingDialog) {
      this.loadingDialog = new LoadingDialog();
    }
    this.loadingDialog.showMsgLoading(msg)
  }


  hideLoading() {
    if (this.loadingDialog) {
      this.loadingDialog.hide()
      this.loadingDialog = undefined
    }
  }
}