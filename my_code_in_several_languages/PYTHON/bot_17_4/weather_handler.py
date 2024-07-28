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

from utils import city_lat_lon, collect_forecast

router = Router()


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

        await message.answer(f'координаты= {lat} {lon}')
        needed_ids = {
            list(forecast.keys())[i].date():
                round(sum(list(forecast.values())[i:i + 8]) / 8 - 273.15)
            for i in range(0, len(forecast.keys()), 8)
        }
        await message.answer(f'координаты2= {lat} {lon}')
        response = as_list(
            as_marked_section(
                Bold(f"Привет, погода в городе {city} на 5 дней:"),
                *[f'{k}  {v} °C' for k, v in needed_ids.items()],
                marker="🌎",
            ),
        )
        await message.answer(f'координаты3= {lat} {lon}')
        await message.answer(**response.as_kwargs())


#   File "C:\Users\user\PycharmProjects\pythonProject3_12\bot_17_4\weather_handler.py", line 63, in forecast
#     for i in range(0, len(forecast.keys()), 8)
#                           ^^^^^^^^^^^^^
# AttributeError: 'function' object has no attribute 'keys'




class OrderWeather(StatesGroup): #КЛАСС КАК-ТО СОДЕРЖИТ В СЕБЕ ЗАПИСАННУЮ ПОГОДУ
    # waiting_for_forecast = State()
    waiting = State()


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
        await state.set_state(OrderWeather.waiting.state) # БЕЗ ЭТОЙ СТРОКИ ВСЁ ЛОМАЛОСЬ



@router.message(OrderWeather.waiting)
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






