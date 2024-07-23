

import requests  # импортируем наш знакомый модуль
# import lxml.html
# from lxml import etree
import json
from datetime import datetime , timedelta


DEVELOPER_CHAT_ID=6879549626

#ПРОГРАММА ЧТЕНИЯ 1 СТРОКИ ИЗ ФАЙЛА (ВИКТОРИНЫ) И ПЕРЕВОД В ПЕРЕМЕННУЮ
def str_obr(ln):
    # print(f'ln1=={ln}')
    ln.replace("'", '"')
    ln_=ln.replace(' ', '')
    # print(f'ln2=={ln}')
    rez = None
    if len(ln_)>1:
        try:
            rez = json.loads(ln)
        except Exception as e:
            print(f'Exeption: {e}')
            print(f'ошибка на строке \n{ln} len(ln)=={len(ln)}  len(ln_)=={len(ln_)}- не переводится в переменную, возможно написана с ошибкой')
    # print(f'rez=={rez}   type=={type(rez)}')
    # variable_type = type(variable)
    return rez


#ПРОГРАММА ЧТЕНИЯ ВСЕЙ ВИКТОРИНЫ
def read_victorina():
    #Блок первичного чтения
    try:
        with open('Victorina.txt', 'r', encoding='utf-8') as file:
            rezz = [str_obr(line) for line in file]
    except Exception as e:
        print(f'Exeption: {e}')
    # Блок переработки до словаря
    vict = {}
    for rz in rezz:
        if not rz is None:
            num = rz['num']
            if num not in vict: vict[num] = {'num': num, 'zagol':'', 'otv': [], 'opeka':[]}
            vic = vict[num]
            for rr in rz:
                if rr != 'num':
                    rr_zn = rz[rr]
                    if rr in ('otv','opeka'):
                        vic[rr].append(rr_zn)
                    else:
                        vic[rr] = rr_zn
    # переработка в список вопросов
    victoryna = []
    for num in vict:
        victoryna.append(vict[num])
    # for vic in victoryna:print(f'read_vic==={vic}')

    return victoryna


#Программа чтения всех записанных пользователей. итогов их игр
def read_users():
    #Блок первичного чтения
    rezz=[]
    try:
        with open('Victorina_users.txt', 'r', encoding='utf-8') as file:
            rezz = [str_obr(line) for line in file]
    except Exception as e:
        print(f'Exeption: {e}')
    rezz = [x for x in rezz if x is not None]
    return rezz


def write_letter(message):
    user_name = message.chat.username
    letter = message.text
    zapis={'user_name':user_name,'now':str(datetime.now()),'letter':letter}
    with open('Victorina_users_letter.txt', 'a', encoding='utf-8') as file:
        file.write(json.dumps(zapis, ensure_ascii=False) + '\n')
    print(f'В базу записано пись мользователя {user_name}: {letter}')
    return


def read_letter():
    #Блок первичного чтения
    try:
        with open('Victorina_users_letter.txt', 'r', encoding='utf-8') as file:
            rezz = [str_obr(line) for line in file]
    except Exception as e:
        print(f'Exeption: {e}')
    print(f'letter_rezz=={rezz}')
    rezz = [x for x in rezz if x is not None]
    return rezz

def clear_letter():
    with open('Victorina_users_letter.txt', 'w', encoding='utf-8') as file:
        file.write( '\n')
    print(f'База всех писем очищена')
    return




# Function to send message to VK user
def send_message_to_vk(user_id, message, access_token):
    vk_url = 'https://api.vk.com/method/messages.send'
    params = {
        'user_id': user_id,
        'message': message,
        'random_id': 0,  # It should be a unique identifier for the message
        'access_token': access_token,
        'v': '5.131'
    }
    response = requests.get(vk_url, params=params)
    return response.json()




#Программа дозаписи пользователя итогов викторины. без удаления старого времени
def write_user(user):
    # user['now']=str(datetime.now().date())
    user['now'] = str(datetime.now())
    text='Итог викторины по требованию пользователя записан'
    if user['xran']!='yes':
        user['otv']=[]
        text=text+' без сохранения ответов'
    with open('Victorina_users.txt', 'a', encoding='utf-8') as file:
        file.write(json.dumps(user, ensure_ascii=False) + '\n')
    print(text)
    return


def read_rabotn():
    #Блок первичного чтения
    try:
        with open('Victorina_rabotniki.txt', 'r', encoding='utf-8') as file:
            rezz = [str_obr(line) for line in file]
    except Exception as e:
        print(f'Exeption: {e}')
    rezz = [x for x in rezz if x is not None]
    return rezz



def write_zoo_korr(victoryna):
    with open('Victorina.txt', 'w', encoding='utf-8') as file:
        for vict in victoryna:
            # print(f'zap_vict==={vict}')
            num=vict['num']
            for nm in vict:
                if nm not in('num','otv','opeka','korrekt'):
                    zn={'num':num,nm:vict[nm]}
                    # print(f'__zn=={zn}')
                    file.write(json.dumps(zn, ensure_ascii=False) + '\n')
                if nm in ('otv'):
                    for ot in vict[nm]:
                        zn = {'num': num, nm: ot}
                        # print(f'__zn=={zn}')
                        file.write(json.dumps(zn, ensure_ascii=False) + '\n')
                if nm in ('opeka'):
                    # print(f'err_vict[*opeka*]=={vict['opeka']}')
                    for op in vict[nm]:
                        # print(f'err_op={op}')
                        zn = {'num': num, nm: op}
                        # print(f'__zn=={zn}')
                        file.write(json.dumps(zn, ensure_ascii=False) + '\n')
            file.write('\n')







#
#
#
# ############# Для погоды чтения
# async def city_lat_lon(session, city): # По имени города даёт его координаты
#     url = f'http://api.openweathermap.org/geo/1.0/direct?q={city}&limit=1&appid={OPENW_TOKEN}'
#     async with session.get(url) as resp:
#         data = await resp.json()
#         lat = data[0]['lat']
#         lon = data[0]['lon']
#         return lat, lon
#
#
# async def collect_forecast(session, lat, lon): # ПО КООРДИНАТАМ ДАЁТ ПОГОДУ
#     url = f'http://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={OPENW_TOKEN}'
#     async with session.get(url) as resp:
#         data = await resp.json()
#         return data
#
#
# ########## Для еды чтение
# async def get_meals(session, url): # ПО url ДАЁТ ИНФОРМАЦИЮ
#     async with session.get(url) as resp:
#         data = await resp.json()
#         return data
#



if __name__ == "__main__":
    vict=read_victorina()
    for vic in vict:
        print(vic)
