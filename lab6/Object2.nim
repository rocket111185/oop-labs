import wNim/[wMessageDialog, wUtils, wDataObject]

import strutils, os

import random
# Цей виклик необхідний перед генерацією чисел.
# Без нього будуть генеруватись ті самі числа,
# а не випадкові.
randomize()

# Функція, яка виводить на екран вікно з повідомленням
# та однією кнопкою "ОК".
# В разі необхідності можна задати, щоб після показу
# вікна програма завершувалась з кодом 1.
# Це дає змогу створювати вікна з повідомленням про
# те, що в програмі щось пішло не так.
proc ShowDialog(msg: string, toQuit=false) =
  MessageDialog(message=msg, caption="Object2",
    style=wOk).display()
  if toQuit:
    quit(1)

# Функція вікна, яке виконує функції згідно з завданням
proc obj2Wind(n, min, max: string) =

  # Створимо стрічку, у яку запишуться випадкові значення.
  # Її ж і передамо у буфер обміну (та на вікно)
  var textContainer = ""

  # Числа, де зберігаються числа, які парсились
  # з переданих стрічок.
  let
    pn = parseInt(n) # ціле число
    pmin = parseFloat(min) # з плавачою комою
    pmax = parseFloat(max) # з плавачою комою

  # Якщо n < 0
  if pn < 0:
    # Покажемо вікно з помилкою, закриємо програму
    ShowDialog("n має бути більше, ніж 0", true)
  # Якщо min < max
  if pmin > pmax:
    # Покажемо вікно з помилкою, закриємо програму
    ShowDialog("Ви переплутали min та max", true)

  # Наповнимо контейнер ітеративно, від 0 до pn (лічильник
  # ітерації - і)
  for i in 0..<pn:
    # Згенеруємо випадкове число
    let number = pmin + (pmax - pmin).rand()
    # Зформуємо з отриманого числа стрічку з фіксованою точністю
    let numStr = number.formatFloat(ffDecimal, 2)
    # Додамо число до контейнеру
    textContainer.add(numStr)
    textContainer.add(" ")
  # Передамо текст у буфер обміну (причому
  # ми передаємо у буфер обміну не сам текст,
  # а спеціальний об'єкт.
  wSetClipboard(DataObject(textContainer))
  # Викличемо функцію, щоб об'єкт зберігся у
  # буфері обміну навіть після закриття програми.
  wFlushClipboard()
  # Покажемо вікно
  ShowDialog(textContainer)

# До речі, ця програма викликається через
# командний рядок, наприклад:
# Object2.exe 2 3 4
#
# Якщо аргументів менше, ніж 3:
if paramCount() < 3:
  # Попередимо користувача
  ShowDialog("You should input 3 arguments!", true)
# А, якщо достатньо
else:
  # Оголосимо змінні, присвоїмо
  # кожній з них аргумент команди
  let
    n = paramStr(1)
    min = paramStr(2)
    max = paramStr(3)
  # Викличемо функцію
  obj2Wind(n, min, max)
