import asyncio

import logging
import sys

from aiogram import Bot, Dispatcher, types
from aiogram.client.default import DefaultBotProperties
from aiogram.enums import ParseMode
from aiogram.filters import CommandStart
from aiogram.types import Message
from aiogram import F
from aiogram.utils.formatting import (
    Bold, as_list, as_marked_section
)

from token_data import TOKEN
from weather_handler import router
import json
import requests  # импортируем наш знакомый модуль
import datetime

from token_data import OPENW_TOKEN



#
# htm==(b'[{"name":"Tbilisi","lon":44.8014495,"country":"GE"}]')
#
# decoded_html = htm.decode('utf-8')
#
# # Десериализация JSON-строки в переменную Python
# data = json.loads(decoded_html)
# print(f'data=={data}')




#################################

# timestamp = 1720774800
#
# # Преобразование метки времени в объект datetime
# dt = datetime.datetime.fromtimestamp(timestamp)
# print(f'timestamp=={timestamp} dt=={dt}')
#
# timestamp==1720774800 dt==2024-07-12 13:00:00
# v=input('=============')

# i==1
# list_zn==dt  val==1720774800 - ВРЕМЯ ТБИЛИСИ
# list_zn==main  val=={'temp': 300.36, 'feels_like': 300.58, 'temp_min': 300.36, 'temp_max': 303.99, 'pressure': 1010, 'sea_level': 1010, 'grnd_level': 940, 'humidity': 47, 'temp_kf': -3.63}
# list_zn==weather  val==[{'id': 500, 'main': 'Rain', 'description': 'light rain', 'icon': '10d'}]
# list_zn==clouds  val=={'all': 40}
# list_zn==wind  val=={'speed': 3.62, 'deg': 136, 'gust': 3.95}
# list_zn==visibility  val==10000
# list_zn==pop  val==0.2
# list_zn==rain  val=={'3h': 0.15}
# list_zn==sys  val=={'pod': 'd'}
# list_zn==dt_txt  val==2024-07-12 09:00:00 - ВРЕМЯ ПО ГРИНВИЧУ


# i==39
# list_zn==dt  val==1721185200
# list_zn==main  val=={'temp': 297.34, 'feels_like': 296.81, 'temp_min': 297.34, 'temp_max': 297.34, 'pressure': 1010, 'sea_level': 1010, 'grnd_level': 940, 'humidity': 38, 'temp_kf': 0}
# list_zn==weather  val==[{'id': 804, 'main': 'Clouds', 'description': 'overcast clouds', 'icon': '04d'}]
# list_zn==clouds  val=={'all': 100}
# list_zn==wind  val=={'speed': 0.28, 'deg': 142, 'gust': 0.9}
# list_zn==visibility  val==10000
# list_zn==pop  val==0
# list_zn==sys  val=={'pod': 'd'}
# list_zn==dt_txt  val==2024-07-17 03:00:00
# i==40
# list_zn==dt  val==1721196000
# list_zn==main  val=={'temp': 301.39, 'feels_like': 300.42, 'temp_min': 301.39, 'temp_max': 301.39, 'pressure': 1009, 'sea_level': 1009, 'grnd_level': 939, 'humidity': 30, 'temp_kf': 0}
# list_zn==weather  val==[{'id': 803, 'main': 'Clouds', 'description': 'broken clouds', 'icon': '04d'}]
# list_zn==clouds  val=={'all': 67}
# list_zn==wind  val=={'speed': 2.48, 'deg': 148, 'gust': 3.06}
# list_zn==visibility  val==10000
# list_zn==pop  val==0
# list_zn==sys  val=={'pod': 'd'}
# list_zn==dt_txt  val==2024-07-17 06:00:00



city='Tbilisi'



# url = 'https://www.gismeteo.ru/weather-tbilisi-5277/'
headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}

url = f'http://api.openweathermap.org/geo/1.0/direct?q={city}&limit=1&appid={OPENW_TOKEN}'


html = requests.get(url, headers=headers).content #чтение
data = json.loads(html.decode('utf-8')) # переработка до питоновской переменной
print(f'data=={data}')

lat = data[0]['lat']
lon = data[0]['lon']
print(f'lat=={lat}  lon=={lon}')

url=f'http://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={OPENW_TOKEN}'


html = requests.get(url, headers=headers).content #чтение
data = json.loads(html.decode('utf-8')) # переработка до питоновской переменной
print(f'data=={data}')
for zn in data:
    print(f'zn=={zn}  val=={data[zn]}')

print('===')
city=data['city']
for zn in city:
    print(f'city_zn=={zn}  val=={city[zn]}')

print('===')
i=0
for ls in data['list']:
    i+=1;print(f'i=={i}')
    for ll in ls:
        print(f'list_zn=={ll}  val=={ls[ll]}')




# async def collect_forecast(session, lat, lon):
#     async with session.get(
#             # url=f'http://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}'
#             #     f'&appid={OPENW_TOKEN}',
#             url=f'http://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={OPENW_TOKEN}'
#     ) as resp:
#         data = await resp.json()
#         return data




v=input('============')



city='Тбилиси'


#
# # координаты города
# async with session.get(
#         url=f'http://api.openweathermap.org/geo/1.0/direct?q={city}'
#             f'&limit=1&appid={OPENW_TOKEN}',
# ) as resp:
#
# data = await resp.json()
# lat = data[0]['lat']
# lon = data[0]['lon']
# print(f'data=={data}')



# url = 'https://www.gismeteo.ru/weather-tbilisi-5277/'
#
# # Заголовки для запроса
# headers = {
#     'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
# }
# response = requests.get(url, headers=headers)
#         response.raise_for_status()  # Проверка на успешность запроса
#
#
#         # Создание дерева из HTML
#         tree = html.fromstring(response.content)
#




v=input('===============')

async def city_lat_lon(session, city): # По имени города даёт его координаты
    async with session.get(
            url=f'http://api.openweathermap.org/geo/1.0/direct?q={city}'
                f'&limit=1&appid={OPENW_TOKEN}',
    ) as resp:
        data = await resp.json()
        lat = data[0]['lat']
        lon = data[0]['lon']
        return lat, lon


async def collect_forecast(session, lat, lon):
    async with session.get(
            # url=f'http://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}'
            #     f'&appid={OPENW_TOKEN}',
            url=f'http://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={OPENW_TOKEN}'
    ) as resp:
        data = await resp.json()
        return data


