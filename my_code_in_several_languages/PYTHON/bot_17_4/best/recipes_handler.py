import aiohttp

from datetime import datetime

from aiogram.filters import Command, CommandObject
from aiogram.types import Message
from aiogram.utils.keyboard import ReplyKeyboardBuilder
from aiogram.utils.formatting import (
    Bold, as_list, as_marked_section
)
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram import Router, types

# from utils import city_lat_lon, collect_forecast
from googletrans import Translator
import random

from token_data import OPENW_TOKEN



router = Router()




############# Для погоды чтения
async def city_lat_lon(session, city): # По имени города даёт его координаты
    url = f'http://api.openweathermap.org/geo/1.0/direct?q={city}&limit=1&appid={OPENW_TOKEN}'
    async with session.get(url) as resp:
        data = await resp.json()
        lat = data[0]['lat']
        lon = data[0]['lon']
        return lat, lon


async def collect_forecast(session, lat, lon): # ПО КООРДИНАТАМ ДАЁТ ПОГОДУ
    url = f'http://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={OPENW_TOKEN}'
    async with session.get(url) as resp:
        data = await resp.json()
        return data


########## Для еды чтение
async def get_meals(session, url): # ПО url ДАЁТ ИНФОРМАЦИЮ
    async with session.get(url) as resp:
        data = await resp.json()
        return data



class Order_all(StatesGroup): #КЛАСС СОДЕРЖИТ В СЕБЕ ЗАПИСАННУЮ ПОГОДУ и рецепты
    waiting_weather = State()
    waiting_meals = State()
    vibor_meals = State()




# ТОЛЬКО ПОЛУЧЕНИЕ КЛАВИАТУРЫ
@router.message(Command("meal"))
async def meal_klava(message: Message, command: CommandObject, state: FSMContext):

    #ДАЛЕЕ ЧТЕНИЕ ДАННЫХ И КЛАВИАТУРА
    data = await state.get_data()  # читаем список всех категорий
    # await message.answer(f"1.Начало Выбор категорий блюд  ")
    bad = False
    if data == {}:
        bad = True
    else:
        if not ('dannie' in data): bad = True
    # await message.answer(f"2. Выбор категорий блюд bad={bad} ")
    if bad:  # Если ещё ничего не читали И НЕ ПИСАЛИ
        await message.answer(f"Выбор категорий блюд - идёт чтение с сайта, это небыстро")
        url = 'https://www.themealdb.com/api/json/v1/1/categories.php'
        async with aiohttp.ClientSession() as session:
            dann = await get_meals(session, url)

        # await message.answer(f"Привет! Выберите категорию блюд2")
        meals = [];
        meals2 = {}
        for dn in dann:
            for dd in dann[dn]:
                meal = dd['strCategory'];
                meal_adr = dd['strCategoryThumb']
                meal_opis = dd['strCategoryDescription']
                meals.append([meal, meal_adr, meal_opis])  # сохранили адреса всех категорий блюд
                meals2[meal] = {'adr': meal_adr, 'opis': meal_opis, 'spis': [], 'name_ru': '', 'opis_ru': ''}
        meals.sort()
        data['dannie'] = meals2

    if 'kol_meal' not in data:
        data['kol_meal'] = 5
    await state.set_data(data)

    # await message.answer(f"3. ВПодготовка данных")
    meals2 = data['dannie'];
    meals = []
    # await message.answer(f"3. ВПодготовка данных  meals2=")
    for meal in meals2:
        ml = meals2[meal]
        meals.append([meal, ml['adr'], ml['opis']])
    meals.sort()

    kb = [];
    kbs = [];
    i = -1
    for dd in meals:
        i += 1
        if i == 5: kbs.append(kb);kb = [];i = 0
        kb.append(types.KeyboardButton(text=dd[0]))
    kbs.append(kb);
    kb = []
    kb.append(types.KeyboardButton(text=f'/random  ({data['kol_meal']} штук)'))
    kb.append(types.KeyboardButton(text='/start'))
    kbs.append(kb)
    keyboard = types.ReplyKeyboardMarkup(keyboard=kbs, resize_keyboard=True)
    await message.answer(f"Выберите категорию блюд на клавиатуре", reply_markup=keyboard)
    await state.set_state(Order_all.waiting_meals.state)  # БЕЗ ЭТОЙ СТРОКИ ВСЁ ЛОМАЛОСЬ





# СЛУЧАЙНОЕ КОЛИЧЕСТВО БЛЮД - УСТЬАНОВИТЬ. И ЗАТЕМ ПОЛУЧЕНИЕ КЛАВИАТУРЫ
@router.message(Command("category_search_random"))
async def meal_search_random(message: Message, command: CommandObject, state: FSMContext):
    kol_meal = command.args
    data = await state.get_data()  # читаем список всех категорий
    if data=={}: # Если ещё ничего не читали И НЕ ПИСАЛИ
        data={}

    if kol_meal is None:
        await message.answer("Ошибка: не переданы аргументы, по умолчанию будет 5 штук")
        kol_meal=5
    try:  # Попытка преобразовать элемент в число
        kol_meal = int(kol_meal)
    except ValueError:
        await message.answer("Ошибка: аргумент не переводится в число, по умолчанию будет 5 штук")
        kol_meal = 5
    data['kol_meal']=kol_meal
    async with aiohttp.ClientSession() as session:
        await state.set_data(data)
        await message.answer(f"записано количество блюд для случайного выбора={kol_meal}: Если хотите его изменить, в одном сообщении введите число, в другом  нажмите /meal")
        await state.set_state(Order_all.waiting_meals.state)


    #ДАЛЕЕ ЧТЕНИЕ ДАННЫХ И КЛАВИАТУРА
    data = await state.get_data()  # читаем список всех категорий
    # await message.answer(f"1.Начало Выбор категорий блюд  ")
    bad = False
    if data == {}:
        bad = True
    else:
        if not ('dannie' in data): bad = True
    # await message.answer(f"2. Выбор категорий блюд bad={bad} ")
    if bad:  # Если ещё ничего не читали И НЕ ПИСАЛИ
        await message.answer(f"Выбор категорий блюд - идёт чтение с сайта, это небыстро")
        url = 'https://www.themealdb.com/api/json/v1/1/categories.php'
        async with aiohttp.ClientSession() as session:
            dann = await get_meals(session, url)

        # await message.answer(f"Привет! Выберите категорию блюд2")
        meals = [];
        meals2 = {}
        for dn in dann:
            for dd in dann[dn]:
                meal = dd['strCategory'];
                meal_adr = dd['strCategoryThumb']
                meal_opis = dd['strCategoryDescription']
                meals.append([meal, meal_adr, meal_opis])  # сохранили адреса всех категорий блюд
                meals2[meal] = {'adr': meal_adr, 'opis': meal_opis, 'spis': [], 'name_ru': '', 'opis_ru': ''}
        meals.sort()
        data['dannie'] = meals2

    if 'kol_meal' not in data:
        data['kol_meal'] = 5
    await state.set_data(data)

    # await message.answer(f"3. ВПодготовка данных")
    meals2 = data['dannie'];
    meals = []
    # await message.answer(f"3. ВПодготовка данных  meals2=")
    for meal in meals2:
        ml = meals2[meal]
        meals.append([meal, ml['adr'], ml['opis']])
    meals.sort()

    kb = [];
    kbs = [];
    i = -1
    for dd in meals:
        i += 1
        if i == 5: kbs.append(kb);kb = [];i = 0
        kb.append(types.KeyboardButton(text=dd[0]))
    kbs.append(kb);
    kb = []
    kb.append(types.KeyboardButton(text=f'/random  ({data['kol_meal']} штук)'))
    kb.append(types.KeyboardButton(text='/start'))
    kbs.append(kb)
    keyboard = types.ReplyKeyboardMarkup(keyboard=kbs, resize_keyboard=True)
    await message.answer(f"Выберите категорию блюд на клавиатуре", reply_markup=keyboard)
    await state.set_state(Order_all.waiting_meals.state)  # БЕЗ ЭТОЙ СТРОКИ ВСЁ ЛОМАЛОСЬ







@router.message(Command("random_meal")) # вывод 1 случайного блюда
async def random_meal(message: Message, command: CommandObject, state: FSMContext):
    url = 'https://www.themealdb.com/api/json/v1/1/random.php'
    async with aiohttp.ClientSession() as session:
        data = await get_meals(session, url)

    data2 = data['meals'][0]
    # id = data2['idMeal']
    pict = data2['strMealThumb']
    adres = data2['strSource']
    name_ = data2['strMeal']
    recept = data2['strInstructions']

    await message.answer(f"Привет! Случайное блюдо {name_}  {pict}")
    await message.answer(f"Полное описание по адресу {adres}")
    await message.answer(f"Рецепт {recept}")
    translator = Translator()
    recept_ru = translator.translate(recept, dest='ru').text
    name_ru = translator.translate(name_, dest='ru').text

    await message.answer(f"По русски: {name_ru}   Рецепт {recept_ru}")






@router.message(Command("random")) # вывод списка случайных блюд в заданном количестве
async def random_meals(message: Message, command: CommandObject, state: FSMContext):
    data = await state.get_data()  # читаем список всех категорий
    # await message.answer(f"1.Начало Выбор категорий блюд  ")
    if data == {}:  # Если ещё ничего не читали И НЕ ПИСАЛИ
        data = {}
    kol_meal=data['kol_meal']
    grup_name=''
    if 'last_name' in data:
        grup_name=data['last_name']
        grup_name_ru = data['last_name_ru']
    else:
        await message.answer(f"1.Пока что никакая группа не была выбрана ")
        return None
    dann = data['dannie']
    # await message.answer(f"1.Надо выбрать случайных {kol_meal} штук из группы {grup_name}  ")
    grup=dann[grup_name]
    spis=grup['spis']
    # await message.answer(f"2.Надо выбрать случайных {kol_meal} штук из группы {grup_name}  ")
    ll=len(spis)
    await message.answer(f"Надо выбрать случайных {kol_meal} штук из группы {grup_name}({grup_name_ru})  в которой {ll} блюд. \nПодождите, идёт перевод на русский ")
    # await message.answer(f"4.список {spis} ")
    random.shuffle(spis)
    vibor=spis[:kol_meal:]
    vibor=spis[:kol_meal:]
    data['vibor']=vibor
    # await message.answer(f"4.Выбранный список=  {vibor} ")
    vivod='Как вам такие варианты?: '
    for vib in vibor:
        name=vib['strMeal']
        id=vib['idMeal']
        translator = Translator()
        name_ru = translator.translate(name, dest='ru').text
        vib['name_ru']=name_ru
        vivod=vivod+f'\n {name_ru} /{id} '
    await message.answer(f"{vivod} ")
    await state.set_data(data)  # СОХРАНЕНИЕ ТОЛЬКО В state
    await state.set_state(Order_all.vibor_meals.state)  # НЕПОСРЕДСТВЕННО ЗАНЕСЕНИЕ В ПАМЯТЬ В НУЖНЫЙ РАЗДЕЛ
    # await state.set_state(Order_all.vibor_meals)


#######################################################################







@router.message(Order_all.vibor_meals)
async def vivod_meals(message: Message, state: FSMContext):
    # await message.answer(f"0.Полная выборка ")
    id = message.text
    if id[0]=='/':id=id[1::]
    # await message.answer(f"1.Выбран элемент = {id} ")
    data = await state.get_data()  # читаем список всех категорий
    vibor=data['vibor']
    name_ru=''
    for vib in vibor:
        if str(vib['idMeal'])==str(id):
            name_ru=vib['name_ru']
            break
    if name_ru=='':
        await message.answer(f"Элемент {id} не найден в списке. Переходим обратно к клавиатуре")
        if message.text.startswith("/"):
            await message.answer(f"Команда начиналась со знака / Все обработчики отключены. попробуйте ещё раз")
            await state.clear()
            return None
        else:
            await state.set_state(Order_all.waiting_meals)
            await meal_waiting_meals(message,state)
            return None
    # await message.answer(f"Найден элемент {vib} ")
    url=f'https://www.themealdb.com/api/json/v1/1/lookup.php?i={id}'
    async with aiohttp.ClientSession() as session:
        dann = await get_meals(session, url)
    dann = dann['meals'][0]
    # name = dann['strMeal']
    recept = dann['strInstructions']
    pict = dann['strMealThumb']
    ingred='ingredients: '
    for dn in dann:
        if dn[:13:]=='strIngredient':
            if dann[dn]!='':
                ingred=ingred+str(dann[dn])+', '
    ingred=ingred[:len(ingred)-2:]+'.'
    # name_ru = translator.translate(name, dest='ru').text
    await message.answer(f"Блюдо {name_ru} {pict} ")
    translator = Translator()
    recept_ru = translator.translate(recept, dest='ru').text
    await message.answer(f"{recept_ru}")
    ingred_ru = translator.translate(ingred, dest='ru').text
    await message.answer(f"{ingred_ru}")
    await message.answer(f"Можете выбрать следующее блюдо, сделать другую случайную выборку, или просмотреть другой раздел блюд, или пойти на /start")








@router.message(Order_all.waiting_meals) # работает с одной выбранной категорией
async def meal_waiting_meals(message: types.Message, state: FSMContext):
    name = message.text
    kol_meal=0
    # await message.answer(f"На вход подано  {name} ")
    try:  # Попытка преобразовать элемент в число
        kol_meal = int(name)
    except ValueError:
        kol_meal=0
    # await message.answer(f"На вход подано число  {kol_meal} ")
    if kol_meal>0:
        await message.answer(f"Вы ввели число случайно выбираемых блюд = {kol_meal}. \nЕсли хотите его изменить, в одном сообщении введите число, а затем в другом нажмите   /meal   ")
        data = await state.get_data()  # читаем список всех категорий
        data['kol_meal']=kol_meal
        await state.set_data(data)  # СОХРАНЕНИЕ ТОЛЬКО В state
        await state.set_state(Order_all.waiting_meals.state)  # НЕПОСРЕДСТВЕННО ЗАНЕСЕНИЕ В ПАМЯТЬ В НУЖНЫЙ РАЗДЕЛ
        # await meals(message, 'meal', state)
        return

    # await message.answer(f"Выбрана категория {name} блюд  ")
    data = await state.get_data() #читаем список всех категорий
    data['last_name'] = name
    dann=data['dannie']
    dn = dann[name]
    # await message.answer(f"Блюдо список {name} по адресу:  \n{dn['adr']} \n{dn['opis']} ") # {'adr':meal_adr,'opis':meal_opis}
    name_ru=dn['name_ru'];opis_ru=dn['opis_ru'];pict=dn['adr']
    await message.answer(f"{pict}  ")
    if name_ru=='':
        await message.answer(f"Блюдо список {name} по адресу:  \n{dn['opis']} ")
        await message.answer(f"Перевожу на русский ")
        translator = Translator()
        opis_ru = translator.translate(dn['opis'], dest='ru').text
        name_ru= translator.translate(name, dest='ru').text
        dn['name_ru']= name_ru
        dn['opis_ru']=opis_ru

    await message.answer(f"Блюдо \n{name_ru} \n описание:  \n{opis_ru} "  )
    data['last_name_ru'] = name_ru
    spisok=dn['spis'];ll=len(spisok)
    # await message.answer(f"По категории {name} есть список из {ll} блюд  ")
    if ll==0:
        await message.answer(f"По категории {name} читаю список с сайта  ")
        url = f'https://www.themealdb.com/api/json/v1/1/filter.php?c={name} '
        async with aiohttp.ClientSession() as session:
            meals = await get_meals(session, url)
        meals = meals['meals']
        dn['spis'] = meals
        # await state.set_data(data) # СОХРАНЕНИЕ ТОЛЬКО В state
        # await state.set_state(Order_all.waiting_meals.state)  # НЕПОСРЕДСТВЕННО ЗАНЕСЕНИЕ В ПАМЯТЬ В НУЖНЫЙ РАЗДЕЛ
    ll = len(dann[name]['spis'])
    await message.answer(f"По категории {name} ({name_ru}) есть список из {ll} блюд  ")
    await state.set_data(data)  # СОХРАНЕНИЕ ТОЛЬКО В state
    await state.set_state(Order_all.waiting_meals.state)  # НЕПОСРЕДСТВЕННО ЗАНЕСЕНИЕ В ПАМЯТЬ В НУЖНЫЙ РАЗДЕЛ
        # print(f'\ndata2=={data2} \n')











##########################################################################
# ДАЛЕЕ ВСЁ ПРО ПОГОДУ




@router.message(Command("weather"))
async def weather(message: Message, command: CommandObject):
    city=command.args
    if city is None:
        await message.answer(
            "Ошибка: не переданы аргументы, по умолчанию будет Тбилиси"
        )
        city='Тбилиси'
        # return
    async with aiohttp.ClientSession() as session:
        lat, lon = await city_lat_lon(session, city)
        data = await collect_forecast(session, lat, lon)
        dtime = datetime.now().timestamp()
        data_dates = {item['dt']: item for item in data['list']}
        data_dates = dict(sorted(data_dates.items()))
        resp = 0

        for date_key, date_item in data_dates.items():
            if date_key > dtime:
                resp = round(date_item['main']['temp'] - 273.15)
                break

        await message.answer(
            f"Привет, погода в городе {city} на ближайшие часы:   {resp} °C",
        )


@router.message(Command("forecast"))
async def forecast(message: Message, command: CommandObject):
    city = command.args
    if city is None:
        await message.answer(
            "Ошибка: не переданы аргументы, по умолчанию будет Тбилиси"
        )
        city = 'Тбилиси'
        # return
    async with aiohttp.ClientSession() as session:
        lat, lon = await city_lat_lon(session, city)
        data = await collect_forecast(session, lat, lon)

        forecast = { # В словарь записываются данные
            datetime.fromtimestamp(item['dt']): item['main']['temp'] for item in data['list']
        }

        # await message.answer(f'координаты= {lat} {lon}')
        needed_ids = {
            list(forecast.keys())[i].date():
                round(sum(list(forecast.values())[i:i + 8]) / 8 - 273.15)
            for i in range(0, len(forecast.keys()), 8)
        }
        # await message.answer(f'координаты2= {lat} {lon}')
        response = as_list(
            as_marked_section(
                Bold(f"Привет, погода в городе {city} на 5 дней:"),
                *[f'{k}  {v} °C' for k, v in needed_ids.items()],
                marker="🌎",
            ),
        )
        # await message.answer(f'координаты3= {lat} {lon}')
        await message.answer(**response.as_kwargs())




@router.message(Command("weather_time"))
async def weather_time(message: Message, command: CommandObject, state: FSMContext):
    city = command.args
    if city is None:
        await message.answer(
            "Ошибка: не переданы аргументы, по умолчанию будет Тбилиси"
        )
        city = 'Тбилиси'
        # return
    async with aiohttp.ClientSession() as session:
        lat, lon = await city_lat_lon(session, city)
        data = await collect_forecast(session, lat, lon)

        data_dates = {datetime.fromtimestamp(item['dt']).isoformat(): item for item in data['list']}
        await state.set_data({'city': city, 'data_dates': data_dates})
        builder = ReplyKeyboardBuilder()
        for date_item in data_dates:
            builder.add(types.KeyboardButton(text=date_item))
        builder.adjust(4)
        markup = builder.as_markup(resize_keyboard=True) # КЛАВИАТУРА СДЕЛАННАЯ

        await message.answer(f"Выберите время:",reply_markup=markup) # БЕЗ ЭТОЙ СТРОКИ ВСЁ ЛОМАЛОСЬ
        await state.set_state(Order_all.waiting_weather.state) # БЕЗ ЭТОЙ СТРОКИ ВСЁ ЛОМАЛОСЬ






@router.message(Order_all.waiting_weather)
async def weather_by_date(message: types.Message, state: FSMContext):
    data = await state.get_data()
    await message.answer(
        f"Погода_в_городе {data['city']} в {message.text}:  "
        f"{round(data['data_dates'][message.text]['main']['temp'] - 273.15)} °C"
    )





@router.message(Command("spisok_time"))
async def weather_time(message: Message, command: CommandObject, state: FSMContext):
    city = command.args
    if city is None:
        await message.answer("Ошибка: не переданы аргументы, по умолчанию будет Тбилиси")
        city = 'Тбилиси'
    async with aiohttp.ClientSession() as session:
        lat, lon = await city_lat_lon(session, city)
        data = await collect_forecast(session, lat, lon)

        data_dates = {datetime.fromtimestamp(item['dt']).isoformat(): item for item in data['list']}
        await state.set_data({'city': city, 'data_dates': data_dates})
        otvet=f'Прогноз погоды в городе {city}:'
        dt0=''
        for dat in data_dates:
            dt1=dat[:10:]
            if dt0!=dt1:
                otvet = otvet + f'\n{dt1} : '
            dt0=dt1
            tm=dat[11:13]
            zn = data_dates[dat]['main']['temp'] - 273.15
            zn = round(zn)
            otvet = otvet + f'({tm}ч->{zn}°C)  '

        await message.answer(otvet)



