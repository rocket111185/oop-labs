# Імпортуємо цю купу графічних об'єктів
import wNim/[wApp, wMacros, wFrame, wIcon, wBitmap, wImage, wPen, wBrush,
  wStatusBar, wToolBar, wUtils, wMenuBar, wMenu, wMemoryDC, wPaintDC, wListBox]
# А також наші модулі
import shape, editor, myTable

type
  # Цей enum відповідає за кнопки у віконному меню
  MenuID = enum
    idSave = 100, idExit,
    idUndo, idRedo, idClear,
    idDot, idLine, idRect, idEllipse,
    idLineOO, idCube,
    idTable
  # А це -- похідний клас від wEditor
  wShapeObjectsEditor* = ref object of wEditor

# Іконки
const
  iDotRes = staticRead(r"images/dot.png")
  iLineRes = staticRead(r"images/line.png")
  iRectRes = staticRead(r"images/rect.png")
  iEllipseRes = staticRead(r"images/ellipse.png")
  iLineOORes = staticRead(r"images/lineoo.png")
  iCubeRes = staticRead(r"images/cube.png")

let
  iDot = Image(iDotRes).scale(24, 24)
  iLine = Image(iLineRes).scale(24, 24)
  iRect = Image(iRectRes).scale(24, 24)
  iEllipse = Image(iEllipseRes).scale(24, 24)
  iLineOO = Image(iLineOORes).scale(24, 24)
  iCube = Image(iCubeRes).scale(24, 24)

# Глобальні змінні.
# Це не ООП-практика, але у даній ситуації
# без цього ніяк.
# Вважатимемо це статичними полями (оскільки зірочки
# біля імен не стоїть, вони ще й приватні)
var
  # Чи притиснута клавіша
  btnPressed = false
  # Поточна фігура
  currentShape = sDot
  # Стек усіх фігур.
  # При наступному додаванні фігури до стеку
  # усі фігури на дисплеї стираються та малюються
  # заново.
  # Не хоче по-іншому)
  shapeList: seq[CShape]
  # Точки позиції.
  p1, p2: wPoint
  # Попередній індекс позначеної фігури
  prevIndex = -1


# Макрос, який створює конструктор для даного класу на
# основі функції (чи методу) init.
# В дужках вказується родинний зв'язок.
# Даний макрос характерний лише для бібліотеки wNim,
# а не усієї мови.
wClass(wShapeObjectsEditor of wEditor):
  # Додавання фігури до стека
  proc addShape(self: wShapeObjectsEditor) =
    # Якщо клавіша притиснута, малюємо слід
    shapeList.add(if btnPressed: currentShape.Trace(p1, p2)
      # В іншому разі -- фігуру
      else: currentShape.QuickShape(p1, p2))
    # Щойно ви побачили тернарний оператор у стилі Нім
    #
    # До речі, цікаво, чому функції беруть три аргументи, а
    # виклики зроблено так, ніби вони є методами, і беруть
    # два аргументи.
    #
    # Річ у тому, що a.fn(b) ідентично fn(a, b)
    # Тобто, у "методах" першим аргументом йде сам об'єкт.
    # Живіть з цим.

  proc revertOldColor (self: wShapeObjectsEditor) =
    if prevIndex < shapeList.len and prevIndex != -1:
      shapeList[prevIndex].isChecked = false
    else:
      prevIndex = -1

  # Стирання останньої фігури (дуже простим чином)
  proc removeShape(self: wShapeObjectsEditor, index = shapeList.len - 1): bool {.discardable, raises: [].} =
    # Отже, щодо {.discardable, raises: [].}
    # Це називається "прагма".
    # Що воно робить? Це додаткові вказівки щодо даної функції.
    # discardable -- це значить, що значенням, яке повертає
    # ця функція, можна знехтувати (і не писати кожен раз discard)
    # raises: [список типів помилок, які може викинути функція]
    # Якщо ви бажаєте прискорити роботу компілятора, або визначити
    # вручну поведінку функції, використовуйте прагми.

    # Якщо не видалить, поверне false
    result = false
    # Видалити зі стеку останній елемент
    # Якщо стек не порожній, звісно
    if shapeList.len > 0:
      shapeList.del(index)
      # А видалить -- true
      result = true
      # result -- це вмонтована змінна, яка містить те,
      # що має повернути функція.
      # Після присвоєння значення до result return можна не писати.

  proc removeAll(self: wShapeObjectsEditor) =
    self.clearScreen()
    # Спорожнюємо стек шляхом присвоєння до нового, чистенького.
    shapeList = @[]
    # Старий стек знищить збирач сміття.

  # Функція, яка відповідає за відображення простих фігур.
  # Грубо кажучи, це шмат коду, який виведено окремо, щоб
  # не писати двічі.
  # СТОП, ЦЕЙ ОПИС ПІДХОДИТЬ ДЛЯ КОЖНОЇ ФУНКЦІЇ
  proc drawShape(self: wShapeObjectsEditor, s: CShape) = 
    # Визначимо варіант простої фігури, щоб потім відобразити
    # коректно.
    case s.variant:
    of sDot:
      self.mMemDc.drawLine(s.p2, s.p2 + (1, 1))
    of sLine:
      self.mMemDc.drawLine(s.p1, s.p2)
    # Для прямокутника та еліпса другим параметром
    # задається не друга координата, а величини фігури.
    # Детальніше дивитись у файлі shape.nim
    of sRect:
      self.mMemDc.drawRectangle(s.p1, s.p2 - s.p1)
    of sEllipse:
      self.mMemDc.drawEllipse(s.p1, s.p2 - s.p1)
    else:
      discard

  # Малювання кадру
  proc drawScreen(self: wShapeObjectsEditor) =
    # Очищаємо його спочатку
    self.clearScreen()
    # А потім для кожної фігури:
    for s in shapeList:
      # Установити ручку та пензель залежно від параметрів фігури
      self.mMemDc.setPen(Pen(if s.isChecked: wGold
        else: s.color, s.penStyle, s.penWidth))
      self.mMemDc.setBrush(if s.isTransparent: wTransparentBrush
        else: Brush(color = s.fill))
      # Якби не вмонтований збирач сміття, нам би доводилось
      # вивільняти пам'ять власноруч (від купи ручок та пензлів).

      # В залежності від форми фігури малюємо ту чи іншу... фігуру
      # s.variant.ord ідентично ord(s.variant)
      # Що повертає ord?
      # Для enumerated -- відповідний індекс.
      # Чому саме така перевірка -- детальніше в shape.nim
      if (s.variant.ord > 99):
        # Для складної фігури виводимо кожну просту підфігуру
        for subS in s.stack:
          self.drawShape subS
      # Для простої фігури малювання відбувається не з вмонтованого
      # стеку.
      else:
        self.drawShape s

  # Ініціалізатор (він же основа для конструктора)
  proc init*(self: wShapeObjectsEditor, title: string) =
    # Створимо віконце
    wFrame(self).init(title=title,
      # "стиль" представлений числом (у світі enum), тому, щоб 
      # застосувати декілька стилів, можемо прописати логічне "АБО"
      # (свого роду додавання)
      style=wCaption or wSystemMenu or wMinimizeBox or wModalFrame or wResizeBorder)
    # Додамо нижній текстовий рядок та панель меню
    #StatusBar(self)
    let menubar = MenuBar(self)
    # Ну, з цим усе точно ясно.
    let menuProject = Menu(menubar, "&Файл")
    menuProject.append(idSave, "&Зберегти")
    menuProject.append(idExit, "&Вийти")

    let menuActions = Menu(menubar, "&Дії")
    menuActions.append(idUndo, "&Скасувати")
    menuActions.append(idRedo, "&Повторити")
    menuActions.appendSeparator()
    menuActions.append(idClear, "&Очистити екран")

    let menuObjects = Menu(menubar, "&Об\'єкти")
    menuObjects.appendRadioItem(idDot, "&Крапка").check()
    menuObjects.appendRadioItem(idLine, "&Лінія")
    menuObjects.appendRadioItem(idRect, "&Прямокутник")
    menuObjects.appendRadioItem(idEllipse, "&Еліпс")
    menuObjects.appendRadioItem(idLineOO, "&ЛініяOO")
    menuObjects.appendRadioItem(idCube, "&Куб")

    let menuAdditional = Menu(menubar, "&Додатково")
    menuAdditional.appendCheckItem(idTable, "&Таблиця об\'єктів")

    # Створимо тулбар, розмістимо внизу
    let toolbar = ToolBar(self, style = wTbBottom)
    # Додамо потрібні інструменти
    # Параметри addTool():
    # 1) ідентифікатор
    # 2) назва на панелі
    # 3) малюнок, який відображатиметься
    # 4) підказка при наведені курсором
    toolbar.addTool(idDot, "Крапка", Bitmap(iDot), "Крапка")
    toolbar.addTool(idLine, "Лінія", Bitmap(iLine), "Лінія")
    toolbar.addTool(idRect, "Прямокутник", Bitmap(iRect), "Прямокутник")
    toolbar.addTool(idEllipse, "Еліпс", Bitmap(iEllipse), "Еліпс")
    toolbar.addTool(idLineOO, "ЛініяOO", Bitmap(iLineOO), "ЛініяOO")
    toolbar.addTool(idCube, "Куб", Bitmap(iCube), "Куб")
    # Розміри вікна
    self.clientSize = (450, 400)

    # Ініціалізуємо поле, де малюються наші фігури
    self.mMemDc = MemoryDC()
    # Нанесемо зверху карту пікселів
    self.mMemDc.selectObject(Bitmap(wGetScreenSize()))
    # і залиємо білою фарбою
    self.mMemDc.setBackground(wWhiteBrush)
    # Очищаємо екран (щоб одразу побачити ефект)
    self.clearScreen()

    let table = getMyTableInstance()

    # Далі уже розписані тригери на кнопки.
    # Вони виглядають більш симпатично, ніж
    # frame.connect(wEvent_Menu, idSave) do ():
    # (те саме, але у цьому разі застосовано цукор)
    self.idSave do ():
      # Поки що воно лише прикидається, бо зберігати ще не вміє
      # (але й не треба було)
      discard

    self.idExit do ():
      self.delete()

    self.idUndo do ():
      # Для скасування видаляємо останню фігуру
      # І, якщо це вдалось (стек був не порожнім):
      if self.removeShape():
        self.revertOldColor()
        # Перемальовуємо вікно
        self.drawScreen()
        table.remove()

    self.idRedo do ():
      # Поки що не вміє скасовувати
      discard
      
    # Очищення екрану від усіх фігур
    self.idClear do ():
      self.removeAll()
      table.clear()
      prevIndex = -1

    self.idDot do ():
      currentShape = sDot
      # Напряму обираємо елемент в меню.
      # Якщо обрати інструмент у тулбарі, у меню пункт
      # самостійно не переобереться.
      menuObjects[0].check()

    self.idLine do ():
      currentShape = sLine
      menuObjects[1].check()

    self.idRect do ():
      currentShape = sRect
      menuObjects[2].check()

    self.idEllipse do ():
      currentShape = sEllipse
      menuObjects[3].check()

    self.idLineOO do ():
      currentShape = sLineOO
      menuObjects[4].check()

    self.idCube do ():
      currentShape = sCube
      menuObjects[5].check()

    self.idTable do ():
      if menuAdditional[0].isChecked:
        table.show()
      else:
        table.hide()

    # При клацанні на ліву кнопку миші:
    self.wEvent_LeftDown do (event: wEvent):
      # Фіксуємо стан кнопки
      btnPressed = true
      # Пишемо початкову координату
      p1 = event.getMousePos()

    # При русі мишкою:
    self.wEvent_MouseMove do (event: wEvent):
      # Якщо кнопка зажата:
      if btnPressed:
        # Отримуємо другу координату
        p2 = event.getMousePos()
        # Додаємо фігуру
        self.addShape()
        # Перемальовуємо усе
        self.drawScreen()
        # І, якщо це не крапка
        if currentShape != sDot:
          # Видаляємо тінь
          self.removeShape()
          # Тут колись був discard перед викликом.
          # Тепер це не треба!
        else:
          table.add($currentShape & ";" & $p1 & " - " & $p2)

    # Якщо кнопка відпущена:
    self.wEvent_LeftUp do (event: wEvent):
      # Фіксуємо стан
      btnPressed = false
      # Отримуємо позицію
      p2 = event.getMousePos()
      # Додаємо фігуру
      self.addShape()
      if currentShape != sDot:
        table.add($currentShape & ";" & $p1 & " - " & $p2)
      # Перемальовуємо дисплей
      self.drawScreen()

    self.wEvent_Close do ():
      table.delete()
      self.delete()

    table.btnRemove.wEvent_Button do ():
      let index = table.getIndex()
      if index > -1:
        table.remove index
        self.removeShape index
        self.revertOldColor()
        self.drawScreen()

    table.btnChoose.wEvent_Button do ():
      let index = table.getIndex()
      if index > -1:
        shapeList[index].isChecked = true
      if prevIndex > -1 and prevIndex != index:
        shapeList[prevIndex].isChecked = false
      prevIndex = index
      self.drawScreen()

    table.btnClear.wEvent_Button do ():
      table.clear()
      self.removeAll()
      prevIndex = -1

    
    # Кожного разу, коли малюється, копіювати з пам'яті на дисплей.
    # Детальніше у файлі editor.nim
    self.wEvent_Paint do ():
      self.repaint()