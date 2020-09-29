# Імпортуємо цю купу графічних об'єктів
import wNim/[wApp, wMacros, wFrame, wIcon, wBitmap, wPen, wBrush, wStatusBar,
  wUtils, wMenuBar, wMenu, wMemoryDC, wPaintDC]
# А також наші модулі
import shape, editor

type
  # Цей enum відповідає за кнопки у віконному меню
  MenuID = enum
    idSave = 100, idExit,
    idUndo, idRedo, idClear,
    idDot, idLine, idRect, idEllipse
  # А це -- похідний клас від wEditor
  wShapeObjectsEditor* = ref object of wEditor

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


# Макрос, який створює конструктор для даного класу на
# основі функції (чи методу) init.
# В дужках вказується родинний зв'язок.
# Даний макрос характерний лише для бібліотеки wNim,
# а не усієї мови.
wClass(wShapeObjectsEditor of wEditor):
  # Додавання фігури до стека
  proc addShape(self: wShapeObjectsEditor) =
    # Якщо клавіша притиснута, малюємо слід
    shapeList.add(if btnPressed: Trace(p1, p2, currentShape)
      # В іншому разі -- фігуру
      else: currentShape.QuickShape(p1, p2))
    # Щойно ви побачили тернарний оператор у стилі Нім

  # Стирання останньої фігури (дуже простим чином)
  proc removeLastShape(self: wShapeObjectsEditor): bool =
    # Якщо не видалить, поверне false
    result = false
    # Видалити зі стеку останній елемент
    # Якщо стек не порожній, звісно
    if shapeList.len > 0:
      shapeList.del(shapeList.len - 1)
      # А видалить -- true
      result = true
      # result -- це вмонтована змінна, яка містить те,
      # що має повернути функція.
      # Після присвоєння значення до result return можна не писати.

  # Малювання кадру
  proc drawScreen(self: wShapeObjectsEditor) =
    # Очищаємо його спочатку
    self.clearScreen()
    # А потім для кожної фігури:
    for s in shapeList:
      # Установити ручку та пензель залежно від параметрів фігури
      self.mMemDc.setPen(Pen(s.color, s.penStyle, s.penWidth))
      self.mMemDc.setBrush(if s.isTransparent: wTransparentBrush
        else: Brush(color = s.fill))
      # Якби не вмонтований збирач сміття, нам би доводилось
      # вивільняти пам'ять власноруч (від купи ручок та пензлів).

      # В залежності від форми фігури малюємо ту чи іншу... фігуру
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

  # Ініціалізатор (він же основа для конструктора)
  proc init*(self: wShapeObjectsEditor, title: string) =
    # Створимо віконце
    wFrame(self).init(title=title,
      # "стиль" представлений числом (у світі enum), тому, щоб 
      # застосувати декілька стилів, можемо прописати логічне "АБО"
      # (свого роду додавання)
      style=wCaption or wSystemMenu or wMinimizeBox or wModalFrame or wResizeBorder)
    # Додамо нижній текстовий рядок та панель меню
    StatusBar(self)
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
    # Розміри вікна
    self.clientSize = (400, 400)

    # Ініціалізуємо поле, де малюються наші фігури
    self.mMemDc = MemoryDC()
    # Нанесемо зверху карту пікселів
    self.mMemDc.selectObject(Bitmap(wGetScreenSize()))
    # і залиємо білою фарбою
    self.mMemDc.setBackground(wWhiteBrush)
    # Очищаємо екран (щоб одразу побачити ефект)
    self.clearScreen()

    # Далі уже розписані тригери на кнопки.
    # Вони виглядають більш симпатично, ніж
    # frame.connect(wEvent_Menu, idSave) do ():
    # (те саме, але у цьому разі застосовано цукор)
    self.idSave do ():
      self.information "Прикинутись, ніби зберігаю..."
      # Поки що воно лише прикидається, бо зберігати ще не вміє
      # (але й не треба було)

    self.idExit do ():
      self.delete()

    self.idUndo do ():
      # Для скасування видаляємо останню фігуру
      self.removeLastShape()
      # І перемальовуємо екран
      self.drawScreen()
      # Пишемо на нижній рядок:
      self.information "Скасовано останню дію"

    self.idRedo do ():
      # Поки що не вміє скасовувати
      self.information "Прикинутись, ніби повторюю..."

    # Очищення екрану від усіх фігур
    self.idClear do ():
      self.clearScreen()
      # Спорожнюємо стек шляхом присвоєння до нового, чистенького.
      shapeList = @[]
      # Старий стек знищить збирач сміття.

    self.idDot do ():
      self.information "Обрано крапку"
      currentShape = sDot

    self.idLine do ():
      self.information "Обрано лінію"
      currentShape = sLine

    self.idRect do ():
      self.information "Обрано прямокутник"
      currentShape = sRect

    self.idEllipse do ():
      self.information "Обрано еліпс"
      currentShape = sEllipse

    # При клацанні на ліву кнопку миші:
    self.wEvent_LeftDown do (event: wEvent):
      # Фіксуємо стан кнопки
      btnPressed = true
      # Пишемо початкову координату
      p1 = event.getMousePos()
      # Інформація на нижній рядок
      self.information "Поточна позиція: " & $p1

    # При русі мишкою:
    self.wEvent_MouseMove do (event: wEvent):
      # Якщо кнопка зажата:
      if btnPressed:
        # Отримуємо другу координату
        p2 = event.getMousePos()
        # Інформація на нижній рядок
        self.information "Поточна позиція: " & $p2
        # Додаємо фігуру
        self.addShape()
        # Перемальовуємо усе
        self.drawScreen()
        # І, якщо це не крапка
        if currentShape != sDot:
          # Видаляємо тінь
          self.removeLastShape()
          # Це для того, щоб можно було малювати безліч крапок
          # без того, щоб мучити руку.

    # Якщо кнопка відпущена:
    self.wEvent_LeftUp do (event: wEvent):
      # Фіксуємо стан
      btnPressed = false
      # Отримуємо позицію
      p2 = event.getMousePos()
      # Інформація на нижній рядок
      self.information "Кнопку відпущено, позиція: " & $p2
      # Додаємо фігуру
      self.addShape()
      # Перемальовуємо дисплей
      self.drawScreen()
    
    # Кожного разу, коли малюється, копіювати з пам'яті на дисплей.
    # Детальніше у файлі editor.nim
    self.wEvent_Paint do ():
      self.repaint()