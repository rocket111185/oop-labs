# Імпорт необхідних графічних підмодулів
# wApp відповідає за основні графічні типи даних,
# wMessageDialog -- за діалог повідомлення
import wNim/[wApp, wMessageDialog]

# Створимо незмінювані підписи
const
  title = "Module 1"
  messageText = "Натисніть на щось"
  labelForward = "Далі >"
  labelBack = "< Назад"
  labelCancel = "Відміна"
  labelConfirm = "Так"

# Реалізація процедури (функції), що відповідає за перший діалог.
# Коротко про нотацію:
# proc foo(arg: typeOfArg): typeOfReturnedValue =
#   bodyOfProc

proc dialogOne(frame: wFrame): bool =
  # Створимо діалог з 2 кнопками ОК та Скасувати
  var msg = MessageDialog(frame, message=messageText,
    caption=title, style=wOKCancel)

  # Ніхто не заважає ці кнопки перепідписати
  msg.setOKCancelLabels(ok=labelForward, cancel=labelCancel)

  # Зображаємо вікно, очікуємо на вихід та отримуємо відповідне id.
  let id = msg.display()

  # wIdOk ми отримуємо, коли користувач натисне на кнопку ОК,
  # яка уже підписана як "Далі >"
  return id == wIdOk

proc dialogTwo(frame: wFrame): bool =
  # А зараз уже 3 кнопки: Так, Ні, Скасувати
  var msg = MessageDialog(frame, message=messageText,
    caption=title, style=wYesNoCancel)

  # Згоден, трохи дивно, що кнопка Ні уже стала кнопкою "Так".
  # Але завдання на те є і завдання
  msg.setYesNoCancelLabels(yes=labelBack, no=labelConfirm,
    cancel=labelCancel)

  let id = msg.display()

  # Зверніть увагу, що даний ідентифікатор підполягає
  # кнопці "Назад <"
  return id == wIdYes


# Тіло процедури, що відповідає за керування діалогами.
# Після її назви пишемо зірочку, щоб зробити процедуру
# доступною для інших файлів (публічною).

proc funcModuleOne*(frame: wFrame) =
  # Створимо змінні, які відповідають за наступний стан діалогу
  var
    endDialog = false
    firstDialog = true
  
  while not endDialog:
    if firstDialog:
      # Виклик процедури, що відповідає за діалог,
      # можна вставити в умову, тоді програма очікуватиме
      # на значення, яке поверне процедура, а потім почнеться
      # подальше виконання в залежності від значення.

      # Якщо в першому діалозі клацнули на "Далі >"
      if dialogOne(frame):
        # Перейти на наступний діалог
        firstDialog = false
      # В іншому разі
      else:
        # Завершуємо роботу
        endDialog = true
    else:
      # Якщо в другому діалозі клацнули на "Назад <"
      if dialogTwo(frame):
        # Повернутись на перший діалог
        firstDialog = true
      # В іншому разі
      else:
        # До побачення, качки!
        endDialog = true