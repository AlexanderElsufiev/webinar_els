
import telebot
from datetime import datetime
import requests
import json




class my_bot:
    def __init__(self):#, width, height):
        # self.width = width
        # self.height = height
        self.token = "7201521200:AAGg6fCFrxwO2RcqJpWnc_f9rPb-pZkEBmw"
        self.users = {'bot': ['Not']}

        self.valut = {'евро': 'EUR', 'доллар': 'USD', 'рубль': 'RUB', 'лари': 'GEL'}
        valut2 = {}
        for val in self.valut:
            z = self.valut[val]
            val = val.lower()
            valut2[val] = z
            val = z.lower()
            valut2[val] = z
            val = '/' + val
            valut2[val] = z
        self.valut2=valut2

        self.valut_err = ['Ожидалось что будут введены именно 3 параметра (валюта1) (валюта2) (количество)',
                     'Валюта 1 не распознана',
                     'Валюта 2 не распознана',
                     'ошибка в 3 позиции. То что вы ввели  - не распознано как число. Две валюты вы уже ввели. \nЕсли хотите начать заново нажмите /start']


    # def get_token(self):
    #     return self.token

    def get_bot(self):
        return telebot.TeleBot(self.token)


    def str_number(self,item):
        number = None
        try:  # Попытка преобразовать элемент в число
            number = int(item)
        except ValueError:
            try:  # Попытка преобразовать элемент в число
                number = float(item)
            except ValueError:
                item2 = item.replace(',', '.')
                try:  # Попытка преобразовать элемент в число
                    number = float(item2)
                except ValueError:
                    number = None
        return number

    def kurs(self,base, quote):
        r = requests.get(f'https://min-api.cryptocompare.com/data/price?fsym={base}&tsyms={quote}')
        dict = json.loads(r.content)
        for val in dict:
            zn = dict[val]
        # print('dict=', dict)
        # print(f'val={val} zn={zn}')
        return zn

    def get_price(self,base, quote, amount):
        # kurs_ = kurs(base, quote)
        # rez += f'\n курс={kurs_}'
        return amount * self.kurs(base, quote)

    def obrabot_valut(self,message):
        user_ = message.from_user.username
        first_name = message.from_user.first_name
        last_name = message.from_user.last_name
        txt = message.text.lower()
        chat_id = message.chat.id
        step = self.users[user_]['step']
        # print('обрабатываю валюту')
        # print('txt=', txt)
        rez = ''

        # Проверка на ввод валюты за несколько шагов
        if txt in self.valut2:
            val = self.valut2[txt]
            if step in (0,3):
                self.users[user_]['step'] = 1
                self.users[user_]['val1'] = val
                rez = f'Вы ввели 1 валюту={val}, теперь введите валюту 2'
                # print(rez)
                return rez
            if step == 1:
                self.users[user_]['step'] = 2
                self.users[user_]['val2'] = val
                rez = f'Вы ввели 2 валюту={val}, теперь введите количество, или смените валюту 2'
                #print(rez)
                return rez
            if step == 2:
                self.users[user_]['step'] = 2
                self.users[user_]['val2'] = val
                rez = f'Вы поменяли 2 валюту={val}, теперь введите количество'
                #print(rez)
                return rez

        # Проверка на ввод операции за 3 шага. окончание ввода
        if step in (2,3):
            base = self.users[user_]['val1']
            quote = self.users[user_]['val2']
            amount = self.str_number(txt)
            #print(f'значение={amount}')
            if amount is None:
                return self.valut_err[3]
            rez = f'правильность ввода={base} {quote} {amount}'
            summ = self.get_price(base, quote, amount)
            rez += f'\n значение суммы = {summ} единиц {quote}'
            self.users[user_]['step'] = 3
            #print(rez)
            return rez

        # Проверка на ввод операции за 3 шага. сбой
        if self.users[user_]['step'] == 1:
            rez = self.valut_err[2] + '\nЯ ожидаю, что вы введёте 2 валюту, вот их список. можете выбрать нажатием:'
            for val in self.valut:
                rez += f'\n{val} /{self.valut[val]}'
            rez += '\nНо можете выбрать иную операцию, нажав /start'
            return rez

        # Проверка на ввод операции за 1 шаг
        if self.users[user_]['step'] in(0,3):
            #print('проверяю на ввод валюты')
            slova = txt.split()
            if (len(slova) != 3): return self.valut_err[0]

            if slova[0] in self.valut2:
                base = self.valut2[slova[0]]
            else:
                return self.valut_err[1]
            if slova[1] in self.valut2:
                quote = self.valut2[slova[1]]
            else:
                return self.valut_err[2]
            self.users[user_]['val1']=base
            self.users[user_]['val2']=quote
            self.users[user_]['step'] = 2
            amount = self.str_number(slova[2])
            if amount is None: return self.valut_err[3]
            rez = f'правильность ввода={base} {quote} {amount}'
            # print(rez)
            # kurs_=kurs(base, quote)
            summ = self.get_price(base, quote, amount)
            rez += f'\n значение суммы = {summ} единиц {quote}'
            self.users[user_]['step'] = 3
            return rez

        #print(self.users)
        rez = f'Что-то пошло не так {first_name} {last_name} ({user_})\n чтобы узнать список возможностей нажми на /start '

        return rez

    def obrabot_txt(self,message):
        user_ = message.from_user.username
        first_name = message.from_user.first_name
        last_name = message.from_user.last_name
        txt = message.text.lower()
        chat_id = message.chat.id

        if user_ not in self.users:
            self.users[user_] = {'oper': ['Not'], 'val1': '', 'val2': '', 'step': 0}

        if txt in ('/start'):
            self.users[user_]['oper'].append('/start')
            rez = 'могу перевести валюты друг в друга:\n'
            rez += 'Для этого наберите или нажмите /valut \n'
            rez += 'Просто информация о списке доступных валют /values \n'
            #rez += 'Чтобы узнать о погоде наберите или нажмите /pogoda\n'
            rez += 'Чтобы получить справку нажмите /help'
            return rez

        if txt in ('/help'):
            self.users[user_]['oper'].append(txt)
            rez = 'Для старта бота с самого сначала нажмите /start \n'
            rez += 'Для получения курса валют нажмите /valut,\n'
            rez += 'Для информации о списке валют нажмите /values '
            #rez += '\nЧтобы узнать о погоде наберите или нажмите /pogoda - блок временно не работает'
            return rez

        if txt == '/valut':
            rez = 'Доступные валюты:'
            self.users[user_]['oper'].append(txt)
            self.users[user_]['step'] = 0
            for val in self.valut:
                rez += f'\n{val} /{self.valut[val]}'
            rez += '\n Введите (валюта 1) (валюта 2) (сколько единиц)'
            return rez

        if txt == '/values':
            rez = 'Доступные валюты:'
            for val in self.valut:
                rez += f'\n{val} /{self.valut[val]}'
            rez += '\n Надо ввести одной строкой, или нажатиями поочереди (валюта 1) (валюта 2) (сколько единиц)'
            return rez

        if txt == '/pogoda':
            self.users[user_]['oper'].append(txt)
            rez = ('Скачивать умею, а вывести - пока что нет \n Доступны города:\
    /СПб /Москва /Тбилиси /Париж /Хельсинки \
    /SPb /Moskow /Tbilisi /Pari /Helsinki   ')
            return rez

        # Проверка на ввод валюты за несколько шагов
        if self.users[user_]['oper'][-1] == '/valut':
            rez = self.obrabot_valut(message)
            return rez

        #print(self.users)
        rez = f'Приветик  {first_name} {last_name} ({user_})\n чтобы начать работать нажми на /start '

        return rez


