import json
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning

# Отключаем предупреждения о небезопасных запросах
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
url = 'https://moscowzoo.ru/animals/kinds'
url = 'https://moscowzoo.ru/animals/kinds/andskiy_kondor'

html = requests.get(url, headers=headers, verify=False).content
print(f'html=={html}')
# data = json.loads(html.decode('utf-8')) # переработка до питоновской переменной
# print(f'data=={data}')
# print('z=3')


v=input('====================')

import json
import requests  # импортируем наш знакомый модуль

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
url = 'https://moscowzoo.ru/animals/kinds'

html = requests.get(url, headers=headers, verify='/path/to/cacert.pem').content
print(f'html=={html}')


headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}

url = 'https://www.themealdb.com/api/json/v1/1/lookup.php?i=52772'
url='https://moscowzoo.ru/animals/kinds'

print('z=1')
html = requests.get(url, headers=headers).content #чтение
print(f'html=={html}')
print('z=2')
data = json.loads(html.decode('utf-8')) # переработка до питоновской переменной
print(f'data=={data}')
print('z=3')

data2=data['meals'][0]
print(f'\ndata2=={data2} \n')

for dn in data2:
    print(f'1.dn=={dn}  data_dn=={data2[dn]}')

name=data2['strMeal']
recept=data2['strInstructions']
pict=data2['strMealThumb']

v=input('===========================')

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}


url='https://moscowzoo.ru/animals/kinds'


html = requests.get(url, headers=headers).content #чтение
print(f'html=={html}')
data = json.loads(html.decode('utf-8')) # переработка до питоновской переменной
print(f'data=={data}')




v=input('=========')











#
# text='Breakfast is the first meal of a day. The word in English refers to breaking the fasting period of the previous night. There is a strong likelihood for one or more "typical", or "traditional", breakfast menus to exist in most places, but their composition varies widely from place to place, and has varied over time, so that globally a very wide range of preparations and ingredients are now associated with breakfast.'
# # # ПЕРЕВОДЧИК
# from googletrans import Translator
# translator = Translator().text
# recipe = translator.translate(text, dest='ru')
# print(recipe.text)
#
# v=input('============')


# import random
#
# z = ['a', 'b', 'c', 'd', 'e']
# random.shuffle(z)
# print(z)
# zz=z[:3:]
# print(zz)
#
# z=['a', 'b', 'c', 'd', 'e']
#
# v=input('==========')

# import asyncio
#
# import logging
# import sys
#
# from aiogram import Bot, Dispatcher, types
# from aiogram.client.default import DefaultBotProperties
# from aiogram.enums import ParseMode
# from aiogram.filters import CommandStart
# from aiogram.types import Message
# from aiogram import F
# from aiogram.utils.formatting import (
#     Bold, as_list, as_marked_section
# )
#
# from token_data import TOKEN
# from weather_handler import router
import json
import requests  # импортируем наш знакомый модуль
import datetime
from datetime import datetime
from token_data import OPENW_TOKEN


# =========================================================

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}

#



# попытка фильтрации
# 'https://www.themealdb.com/api/json/v1/1/filter.php?c=side'



#
# name='side'
# url =f'https://www.themealdb.com/api/json/v1/1/filter.php?c={name}'
url = 'https://www.themealdb.com/api/json/v1/1/lookup.php?i=52772'

html = requests.get(url, headers=headers).content #чтение
print(f'html=={html}')
data = json.loads(html.decode('utf-8')) # переработка до питоновской переменной
print(f'data=={data}')

data2=data['meals'][0]
print(f'\ndata2=={data2} \n')


for dn in data2:
    print(f'1.dn=={dn}  data_dn=={data2[dn]}')

name=data2['strMeal']
recept=data2['strInstructions']
pict=data2['strMealThumb']


    # data2=data[dn]
    # for dd in data2:
    #     print(f'  2.dd=={dd}')
    #     # print(f'   data2_dd=={data2[dd]}')
#


#
# data=={'meals': [
#     {'strMeal': 'Blini Pancakes',
#      'strMealThumb': 'https://www.themealdb.com/images/media/meals/0206h11699013358.jpg',
#      'idMeal': '53080'},
#     {'strMeal': 'Boulangère Potatoes',
#                           'strMealThumb': 'https://www.themealdb.com/images/media/meals/qywups1511796761.jpg', 'idMeal': '52914'},
#     {'strMeal': 'Brie wrapped in prosciutto & brioche', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/qqpwsy1511796276.jpg',
#      'idMeal': '52913'},
#     {'strMeal': 'Burek', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/tkxquw1628771028.jpg', 'idMeal': '53060'}, {'strMeal': 'Corba', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/58oia61564916529.jpg', 'idMeal': '52977'}, {'strMeal': 'Fennel Dauphinoise', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/ytttsv1511798734.jpg', 'idMeal': '52919'}, {'strMeal': 'Feteer Meshaltet', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/9f4z6v1598734293.jpg', 'idMeal': '53030'}, {'strMeal': 'French Onion Soup', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/xvrrux1511783685.jpg', 'idMeal': '52903'}, {'strMeal': 'Fresh sardines', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/nv5lf31628771380.jpg', 'idMeal': '53061'}, {'strMeal': 'Japanese gohan rice', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/kw92t41604181871.jpg', 'idMeal': '53033'}, {'strMeal': 'Kumpir', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/mlchx21564916997.jpg', 'idMeal': '52978'}, {'strMeal': 'Mushroom soup with buckwheat', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/1ngcbf1628770793.jpg', 'idMeal': '53059'}, {'strMeal': 'Mustard champ', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/o7p9581608589317.jpg', 'idMeal': '53038'}, {'strMeal': 'Pierogi (Polish Dumplings)', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/45xxr21593348847.jpg', 'idMeal': '53019'}, {'strMeal': 'Prawn & Fennel Bisque', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/rtwwvv1511799504.jpg', 'idMeal': '52922'}, {'strMeal': 'Snert (Dutch Split Pea Soup)', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/9ptx0a1565090843.jpg', 'idMeal': '52981'}, {'strMeal': 'Split Pea Soup', 'strMealThumb': 'https://www.themealdb.com/images/media/meals/xxtsvx1511814083.jpg', 'idMeal': '52925'}]}
#







v=input('=====================')


# Найдите один случайный прием пищи
url ='https://www.themealdb.com/api/json/v1/1/random.php'


html = requests.get(url, headers=headers).content #чтение
print(f'html=={html}')
data = json.loads(html.decode('utf-8')) # переработка до питоновской переменной
print(f'data=={data}')


# for dn in data:
#     print(f'1.dn=={dn}')
#     print(f'data_dn=={data[dn]}')
#     data2=data[dn][0]
#     for dd in data2:
#         print(f'  2.dd=={dd}')
#         print(f'   data2_dd=={data2[dd]}')
#
# dd==strMealThumb
#    data2_dd==https://www.themealdb.com/images/media/meals/x0lk931587671540.jpg
# 2.
# dd == strYoutube
# data2_dd == https: // www.youtube.com / watch?v = Mt5lgUZRoUg
# 2.dd==strSource
#    data2_dd==https://www.dailymail.co.uk/femail/food/article-8240361/Pizza-Express-release-secret-recipe-Margherita-Pizza-make-home.html


data2=data['meals'][0]
id=data2['idMeal']
pict=data2['strMealThumb']
adres=data2['strSource']
name_=data2['strMeal']
recept=data2['strInstructions']
print(f'name_=={name_}')
print(f'recept=={recept}')
print(f'pict=={pict}')
print(f'adres=={adres}')


v=input('================')


# Перечислить все категории блюд
print('KATEGORII')
url ='www.themealdb.com/api/json/v1/1/categories.php'
url ='https://www.themealdb.com/api/json/v1/1/categories.php'

html = requests.get(url, headers=headers).content #чтение
print(f'html=={html}')
data = json.loads(html.decode('utf-8')) # переработка до питоновской переменной
print(f'data=={data}')

kb = [];kbs=[];meals=[];i=0
for dn in data:
    print(f'1.dn=={dn}')
    for dd in data[dn]:
        meal = dd['strCategory'];
        meal_adr = dd['strCategoryThumb']

        print(f'dd_=={dd['strCategory']} == {dd['strCategoryThumb']}')
        for pr in dd:
            print(f'   pr=={pr} dd[pr]=={dd[pr]}')
        meals.append([meal, meal_adr])

meals.sort()
print('\n',meals)

v=input('==============')


# =========================================================


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

data_dates = {datetime.fromtimestamp(item['dt']).isoformat(): item for item in data['list']}
print(f'\n data_dates=={data_dates}')
otvet=''
for dat in data_dates:
    zz=data_dates[dat]
    print(f'zz=={zz}')
    zn=zz['main']['temp']-273.15
    zn=round(zn,2)
    print(f'dat={dat}  zn={zn}')
    otvet=otvet+f'\n{dat}->{zn}'
print(otvet)

# 'data_dates == {'2024-07-12T16:00:00': {'dt': 1720785600,
#                                        'main': {'temp': 304.39, 'feels_like': 303.45, 'temp_min': 304.39,
#                                                 'temp_max': 306.45, 'pres'


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


