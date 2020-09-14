import nigui
import nigui/msgbox

const
  title = "Діалог"
  message = "Натисніть на щось"
  btnBack = "< Назад"
  btnForward = "Далі >"
  btnCancel = "Відміна"
  btnConfirm = "Так"

template createDialog(number: int, button1, button2, button3: string = "") =
  let res = wnd.msgBox(message, title, button1, button2, button3)
  txt.addLine("Діалог " & $number & " спрацював, результат: " & $res)
  return res == 1

proc dialogOne(wnd: Window, txt: TextArea): bool =
  createDialog(1, btnForward, btnCancel)

proc dialogTwo(wnd: Window, txt: TextArea): bool =
  createDialog(2, btnBack, btnConfirm, btnCancel)

proc funcModOne*(wnd: Window, txt: TextArea) =
  var
    endDialog = false
    firstDialog = true
  while not endDialog:
    if firstDialog:
      if dialogOne(wnd, txt):
        firstDialog = false
      else:
        endDialog = true
    else:
      if dialogTwo(wnd, txt):
        firstDialog = true
      else:
        endDialog = true