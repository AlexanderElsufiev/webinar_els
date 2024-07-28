from token_data import OPENW_TOKEN


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



# async def get_meals(session, url): # ПО url ДАЁТ ИНФОРМАЦИЮ
#     async with session.get(url) as resp:
#         data = await resp.json()
#         return data




def list_num(slist):# перевод списка в числовой вид, если возможно
    nlist = [] # Новый список, в который будут добавлены элементы в виде чисел
    for item in slist:
        try: # Попытка преобразовать элемент в число
            number = int(item)
            nlist.append(number)
        except ValueError:
            try:  # Попытка преобразовать элемент в число
                number = float(item)
                nlist.append(number)
            except ValueError:
                item2 = item.replace(',', '.')
                try:  # Попытка преобразовать элемент в число
                    number = float(item2)
                    nlist.append(number)
                except ValueError:
                    nlist.append(item)
    return nlist