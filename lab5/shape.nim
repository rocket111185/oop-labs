import system
import wNim/[wApp, wTypes]

type
  # ShapeVar -- variant of Shape
  # enumerated -- кращий друг Німа
  ShapeVar* = enum
    sDot, sLine, sRect, sEllipse,
    # Складнi фігури
    sLineOO = 100, sCube
    # І чому присвоєно 100 до sLineOO?
    # Кожному enumerated дається унікальний
    # числовий еквівалент (ord, "ordinal").
    # За умовчуванням, вони йдуть як індекси в
    # масиві, тобто, 0, 1, 2...
    # Якщо явно присвоїти число, то з того
    # моменту починається відлік саме з того числа.
    # Таким чином, sCube має еквівалент 101.
    # Це зроблено для простішої перевірки на групи
    # фігур (s.variant.ord > 99 дасть true для
    # виокремленої групи складних фігур)
  CShape* = ref object of RootObj
    # enumerated може представляти тип даних
    variant*: ShapeVar
    # wPoint -- (int x, int y)
    # словом, це позиція, задана у двовимірній площині
    p1*: wPoint
    p2*: wPoint
    # 0 -- суцільна лінія, 1 -- рисками, 2 -- цятками
    penStyle*: int
    # Ширина ручки
    penWidth*: int
    # Колір контура
    color*: wColor
    # Колір заповнення
    fill*: wColor
    # чиПрозора
    isTransparent*: bool
    # чиПозначена
    isChecked*: bool
    # Стек підфігур
    stack*: seq[CShape]

# В Нім лекго і просто перегрузити оператори.
# Наприклад, треба отримати розмір фігури, але наявні
# лише дві точки: початок і кінець.
# Можемо написати функцію, яка обчислить необхідне значення
# (а ще можемо вказати тип, який повертається).
# Словом, оператори -- це ті самі функції.
proc `-`*(p2, p1: wPoint): wSize =
  return (p2.x - p1.x, p2.y - p1.y)

# Таким чином і для тих випадків, коли замість крапки
# краще намалювати лінію, і хочеться зробити так:
# позиція + (1, 1)
proc `+`*(p2, p1: wPoint): wPoint =
  return (p2.x + p1.x, p2.y + p1.y)
# Зверніть увагу, що імена операторів-функцій
# при оголошенні записуються в обернених лапках.

proc `-`*(s2, s1: wSize): wSize =
  return (s2.width - s1.width, s2.height - s1.height)

# Функція, що представляє собою конструктор.
# Для функції та класу імена повинні бути різними.
#
# При оголошенні функції до аргументів можна присвоїти
# значення за умовчанням, тоді тип аргументів буде визначено
# за тими значеннями.
proc Shape(variant = sDot, p1 = (0, 0), p2 = (0, 0),
  # Допускається перехід на новий рядок після коми,
  # але продовження тоді треба пересунути на рівень вперед
  penStyle = 0, penWidth = 2, color = wBlack, fill = wWhite,
    isTransparent = false, stack: seq[CShape] = @[]): CShape =
  # Тіло функції (процедури) уже іде на рівень вперед
  # від ключового слова `proc`
  #
  # Створимо екземпляр класу
  let shape = CShape()
  # Присвоїмо значення аргументів до полів об'єкта
  shape.variant = variant
  # Унікальний випадок для еліпса (тому що центр еліпса
  # має знаходитись там, це курсор)
  if variant == sEllipse:
    let po1 = (2 * p1[0] - p2[0], 2 * p1[1] - p2[1])
    shape.p1 = po1
  else:
    shape.p1 = p1
  # Все інше без змін
  shape.p2 = p2
  shape.penStyle = penStyle
  shape.penWidth = penWidth
  shape.color = color
  shape.fill = fill
  shape.isTransparent = isTransparent
  shape.isChecked = false
  shape.stack = stack
  # Повернемо екземпляр
  return shape

# Спрощений конструктор для точки
proc Dot(p: wPoint): CShape =
  return Shape(p1 = p)

# Спрощений конструктор для лінії
proc Line(p1, p2: wPoint): CShape =
  return Shape(variant = sLine, p1 = p1, p2 = p2)

# Для прямокутника (згідно із завданням)
proc Rect(p1, p2: wPoint): CShape =
  return Shape(variant = sRect, p1 = p1, p2 = p2,
    isTransparent = true)

# Для еліпса (згідно із завданням)
proc Ellipse(p1, p2: wPoint): CShape =
  return Shape(variant = sEllipse, p1 = p1, p2 = p2,
    fill = wGrey)

proc LineOO(p1, p2: wPoint): CShape =
  var stack: seq[CShape]
  stack.add Line(p1, p2)
  stack.add Ellipse(p1, p1 + (10, 10))
  stack.add Ellipse(p2, p2 + (10, 10))
  return Shape(variant = sLineOO, stack = stack,
    p1 = p1, p2 = p2)

proc Cube(p1, p2: wPoint): CShape =
  var stack: seq[CShape]
  let
    dY = ((p2.y - p1.y) / 4).int()
    dX = ((p2.x - p1.x) / 4).int()
  stack.add Rect(p1, (p2.x - dX, p2.y - dY))
  stack.add Rect((p1.x + dX, p1.y + dY), p2)
  stack.add Line(p2, (p2.x - dX, p2.y - dY))
  stack.add Line((p1.x + dX, p1.y + dY), p1)
  stack.add Line((p1.x, p2.y - dY), (p1.x + dX, p2.y))
  stack.add Line((p2.x - dX, p1.y), (p2.x, p1.y + dY))
  return Shape(variant = sCube, stack = stack,
    isTransparent = true, p1 = p1, p2 = p2)

proc QuickShape*(variant: ShapeVar, p1, p2: wPoint): CShape =
  case variant:
  of sDot:
    return Dot(p1)
  of sLine:
    return Line(p1, p2)
  of sRect:
    return Rect(p1, p2)
  of sEllipse:
    return Ellipse(p1, p2)
  of sLineOO:
    return LineOO(p1, p2)
  of sCube:
    return Cube(p1, p2)

# Слід при малюванні
proc Trace*(variant: ShapeVar, p1, p2: wPoint): CShape =
  # Для крапки сліду нема, вона просто малюється
  let col = if variant == sDot: wBlack else: wRed
  if variant == sLineOO:
    result = LineOO(p1, p2)
  elif variant == sCube:
    result = Cube(p1, p2)
  else:
    result = Shape(variant = variant, p1 = p1, p2 = p2)

  result.penStyle = 1
  result.color = col
  result.isTransparent = true
