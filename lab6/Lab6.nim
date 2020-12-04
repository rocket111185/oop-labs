import wNim/[wFrame, wPanel, wTextCtrl, wButton, wStaticText]
import strutils, os

# Створимо вікно
let dialog = Frame(size=(320, 400), style=wCaption or wSystemMenu)
# Створимо внутрішню область вікна
let panel = Panel(dialog)

# Створимо текст, який є підписом поля n
StaticText(panel, label="N:", pos=(10, 10))
# Поле для вводу
let textctrlN = TextCtrl(panel, pos=(10, 50), size=(270, 30),
  style=wBorderSunken)

# Створимо текст, який є підписом поля Min
StaticText(panel, label="Min:", pos=(10, 90))
# Поле для вводу
let textctrlMin = TextCtrl(panel, pos=(10, 130), size=(270, 30),
  style=wBorderSunken)

# Створимо текст, який є підписом поля Max
StaticText(panel, label="Max:", pos=(10, 170))
# Поле для вводу
let textctrlMax = TextCtrl(panel, pos=(10, 210), size=(270, 30),
  style=wBorderSunken)

# Кнопка "ОК"
let buttonOk = Button(panel, label="&OK",
  size=(90, 30), pos=(100, 320))
# Кнопка "Скасувати"
let buttonCancel = Button(panel, label="&Cancel",
  size=(90, 30), pos=(200, 320))

# Якщо вікно закрити
dialog.wEvent_Close do ():
  # Воно повністю завершить дію, програма зупинила дію.
  dialog.delete()

# Якщо натиснути на кнопку "ОК"
buttonOk.wEvent_Button do ():
  # Прочитаємо значення всіх полів, запишемо
  # у змінні
  let
    n = textctrlN.value
    min = textctrlMin.value
    max = textctrlMax.value
  # Якщо жодне з полів не є порожнім
  if n.len > 0 and min.len > 0 and max.len > 0:
    # Сховаємо основне вікно
    dialog.hide()
    # Запустимо програму Object2.exe
    # У ній 3 аргументи, які розділені пробілом
    # Можемо створити масив з необхідних стрічок та
    # об'єднати їх в одну стрічку, причому вони будуть
    # розділені пробілом.
    # 
    # execShellCmd() запустає програму та вертає число:
    # 0 - все добре, 1 - все погано
    if execShellCmd(["Object2.exe", n, min, max].join(" ")) < 1:
      # Після відпрацювання Object2.exe запуститься Object3.exe
      discard execShellCmd("Object3.exe")
      # Нім не любить, коли ми якесь значення нікуди
      # не передали, або не присвоїли.
      # Передамо у функцію discard (нічогоНеРоби)
    # Покажемо основне вікно
    dialog.show()

# Якщо натиснути на кнопку "Скасувати"
buttonCancel.wEvent_Button do ():
  # Вікно закриється
  dialog.close()

# Розмістимо вікно по центру
dialog.center()
# Покажемо
dialog.showModal()
# Після відпрацювання - знищимо
dialog.delete()
