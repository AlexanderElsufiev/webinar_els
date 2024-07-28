
# import aiohttp
# from datetime import datetime
# from aiogram.utils.keyboard import ReplyKeyboardBuilder
# from aiogram import Bot, Dispatcher, types
# from aiogram import Bot, Dispatcher, types
# from aiogram.utils.formatting import (Bold, as_list, as_marked_section)
# from googletrans import Translator

from aiogram.filters import Command, CommandObject
# from aiogram.types import Message
from aiogram.types import InlineKeyboardButton, InlineKeyboardMarkup,ReplyKeyboardRemove,Message
# from aiogram.types import ReplyKeyboardRemove
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram import Router, types

import random
import copy # глубокая копия

from zoo_tools import *



router = Router()




class Order_all(StatesGroup): #КЛАСС СОДЕРЖИТ В СЕБЕ ЗАПИСАННУЮ ПОГОДУ и рецепты

    zoo=State()
    zoo_waiting_xran=State()
    zoo_waiting_victory=State()
    zoo_waiting_vibor=State()
    zoo_waiting_otvet=State()
    zoo_rabotnik_parol=State()
    zoo_rabotnik_vibor=State()

    zoo_rabotnik_korr = State()
    zoo_rabotnik_korrect = State()
    zoo_waiting_letter = State()
    zoo_waiting_dostig = State()


# @dp.message_handler(commands=['start'])
# async
def fullname(message: types.Message):
    first_name = message.from_user.first_name
    last_name = message.from_user.last_name
    username = message.from_user.username
    full_name = f"{first_name} {last_name}" #"//{username}"
    return full_name




# ВИКТОРИНА
@router.message(Command("vict_corr"))
async def vict_corr_vhod(message: Message, command: CommandObject, state: FSMContext):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return

    user_name=message.chat.username
    full_name=fullname(message)
    rabitnik = read_rabotn()
    rabot={}
    for rab in rabitnik:
        if rab['user_name']==user_name:rabot=rab
    if rabot=={}:
        await message.answer(f"{full_name} {user_name} Вы не идентифицированы как работник зоопарка! "
                             f"\nПроверьте что ваши данные внесены в базу (файл 'Victorina_rabotniki.txt')")
        return
    #Начинаем пытаться работать с опознанным работником
    await state.set_state(Order_all.zoo_rabotnik_parol.state)
    dann = await state.get_data()  # читаем список всех категорий

    rabot['popitok']=3
    rabot['vhod'] = False
    rabot['vhod_tm'] = 0
    # print(f'rabot=={rabot}')
    dann['rabot']=rabot
    await state.set_data(dann)

    await state.set_state(Order_all.zoo_rabotnik_parol)
    await message.answer(f"{full_name} {user_name} Вы идентифицированы как работник зоопарка! Введите свой пароль."
                         , reply_markup = ReplyKeyboardRemove()) # ВЫКЛЮЧЕНИЕ КЛАВИАТУРЫ
    # zoo_rabotnik_parol(message, state)



@router.message(Order_all.zoo_rabotnik_parol) # работает с одной выбранной категорией
async def zoo_rabotnik_parol(message: types.Message, state: FSMContext):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return
    otvet = message.text
    user_name = message.chat.username
    full_name = fullname(message)
    dann = await state.get_data()
    # data=read_rabotn()
    print(f'dann=={dann}')

    rabot=dann['rabot']
    # print(f'rabot=={rabot}')
    if otvet==dann['rabot']['parol']:
        await message.answer(f"{full_name} {user_name} Ваш пароль правильный, можете работать.")
        now = datetime.now()
        now = now.timestamp()
        rabot['vhod_tm']=now
        rabot['vhod'] = True
        await state.set_state(Order_all.zoo_rabotnik_vibor)
        await zoo_rabotnik_vibor(message,state)
        return
    else:
        dann['rabot']['popitok'] -=1
        await message.answer(f"{full_name} {user_name} Вы ввели неправильный пароль, осталось {dann['rabot']['popitok']} попыток")
        if dann['rabot']['popitok']==0:
            await message.answer(f"Попытки ввода пароля закончились")
            await state.set_state(None)
            await command_start_handler_copy(message)
            return


@router.message(Order_all.zoo_rabotnik_vibor) # работает с одной выбранной категорией
async def zoo_rabotnik_vibor(message: types.Message, state: FSMContext):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return
    await message.answer(f"БЛОК РАБОТЫ ЗООРАБОТНИКА")
    dann = await state.get_data()  # читаем список всех категорий
    if not('vict' in dann):
        await message.answer(f"Читаю условия викторины")
        vict = read_victorina()
        dann['vict'] = vict
    vict = dann['vict']
    kb = [];kbs = [];i = -1
    for vic in vict:
        if 'korrekt' not in vic:vic['korrekt']=False
        i += 1
        if i == 5: kbs.append(kb);kb = [];i = 0
        kb.append(types.KeyboardButton(text=vic['zagol']))
    kbs.append(kb);kb = []
    kb.append(types.KeyboardButton(text=f'/dobav - добавить вопрос'))
    kb.append(types.KeyboardButton(text=f'/smotr - смотреть поступивше жалобы'))
    kbs.append(kb);kb = []
    kb.append(types.KeyboardButton(text=f'/zapis - запись внесённых изменений и выход'))

    # kb.append(types.KeyboardButton(text='/korr - корректировать вопрос'))
    kbs.append(kb)
    keyboard = types.ReplyKeyboardMarkup(keyboard=kbs, resize_keyboard=True)
    await state.set_data(dann)
    await message.answer(f"Что будете делать? Корректировать вопрос или добавить новый?", reply_markup=keyboard)
    await state.set_state(Order_all.zoo_rabotnik_korr.state)

    return



@router.message(Order_all.zoo_rabotnik_korr) # работает с одной выбранной категорией, корректирует
async def zoo_rabotnik_korr(message: types.Message, state: FSMContext):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return

    # await message.answer("Клавиатура убрана", reply_markup=ReplyKeyboardRemove())
    dann = await state.get_data()  # читаем список всех категорий
    otvet = message.text
    # print(f'korr_otvet=={otvet}')
    if otvet[:6:]=='/zapis':
        await message.answer(f"ПРОГРАММА ЗАПИСИ КОРРЕКТИВ В БАЗУ")
        vict=dann['vict']
        write_zoo_korr(vict)
        # ПОЛНЫЙ ОТКАТ НА СТАРТ!!!
        await state.set_state(None)
        await command_start_handler_copy(message)
        return

    if otvet[:6:]=='/smotr':
        await message.answer(f"СМОТРИМ ВСЕ СООБЩЕНИЯ ПОЛЬЗОВАТЕЛЕЙ")
        letter=read_letter()
        for let in letter:
            await message.answer(f"{let}")
        if len(letter)>0:
            await message.answer(f"Для очистки базы сообщений нажмите /clear_letter . \nНо только если уверены что полезных нет!!!")
        else:await message.answer(f"Сообщений от пользователей нет!")
        return

    if otvet[:13:]=='/clear_letter':
        await message.answer(f"ОЧИЩАЮ ВСЕ СООБЩЕНИЯ ПОЛЬЗОВАТЕЛЕЙ")
        clear_letter()
        return


    # await message.answer(f"Скопируйте любую из строк, откорректируйте. и соблюдая синтаксис введите обратно:",
    #                      reply_markup=ReplyKeyboardRemove())
    vict = dann['vict']
    max_num=0
    for vv in vict:
        if vv['zagol'] == otvet: vic = vv
        if vv['num']>max_num:max_num=vv['num']
    if otvet[:6:]=='/dobav':# Если формируем новый ответ
        vic={'num':max_num+1,'zagol':'-','otv':[{'var':1,'txt':'-','bal':0,'rez':'-'}],'vopros':'-','pict':'','info':'','opeka':['']}
    # print(f'vic=={vic}')
    print(f'otvet=={otvet}')
    dann['korr_vopr']=copy.deepcopy(vic)
    dann['korr_first']=True
    await state.set_data(dann)
    await state.set_state(Order_all.zoo_rabotnik_korrect.state)
    await zoo_rabotnik_korrect(message, state)
    return





@router.message(Order_all.zoo_rabotnik_korrect) # работает с одной выбранной категорией, корректирует
async def zoo_rabotnik_korrect(message: types.Message, state: FSMContext):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return
    dann = await state.get_data()  # читаем список всех категорий
    vic=dann['korr_vopr'] # настраиваемая сейчас викторина
    # await message.answer(f"БЛОК РАБОТЫ ЗООРАБОТНИКА - корректировка вопроса - изменение поля")
    # await message.answer("Клавиатура убрана", reply_markup=ReplyKeyboardRemove())
    reply=''
    if message.reply_to_message:reply=message.reply_to_message.text
    otvet = message.text
    if dann['korr_first']:otvet='/obnov';dann['korr_first']=False
    # print(f'otvet=*{otvet}*    reply==*{reply}*')

    if otvet == '/exit':
        await message.answer(f"СОХРАНИТЬ И ВЫЙТИ - ещё не сделано")
        await message.answer(f"Выберите вариант:  /zapis -записать и выйти   /vixod - выйти без записи")
        return

    if otvet == '/zapis':
        opeka=vic['opeka']
        # print(f'opeka={opeka}')
        op=[x for x in opeka if x!='']
        vic['opeka']=op
        # print(f'zap_opeka={vic['opeka']}')
        otv=vic['otv']
        # print(f'otv={otv}')
        otv_=[x for x in otv if (x['txt']!='' or x['rez']!='')]
        for ot in otv_:# сделать количество баллов числовым
            try:ot['bal']=int(ot['bal'])
            except Exception as e:ot['bal']=0
        vic['otv']=otv_
        vic['korrekt'] = True
        # print(f'zap_otv={vic['otv']}')
        # print(f'vic={vic}')
        vict=dann['vict']
        # print(f'vict=={vict}')
        num=vic['num']
        put=False
        for i, vv in enumerate(vict):
        # for vv in vict:
            if vv['num']==num:vict[i]=copy.deepcopy(vic);put=True
        if not put:vict.append(vic)
        # print(f'vict2=={vict}')
        otvet='/vixod'

    if otvet == '/vixod':
        dann['korr_vopr']=None
        await state.set_data(dann)
        await state.set_state(Order_all.zoo_rabotnik_vibor.state)
        await zoo_rabotnik_vibor(message, state)
        return

    rav=otvet.find('=')
    rav_rep = reply.find('=')
    # pars = 'obnov' #чтобы потом автоматом обновило, если надо
    if rav>0:
        param=otvet[:rav:];znach=otvet[rav+1::]
    if rav_rep > 0:
        param = reply[:rav_rep:];znach = otvet
    if rav > 0 or rav_rep>0:
        znach=znach.strip()
        # print(f'param=*{param}*  znach=*{znach}*')
        pars=param.split(':')
        ll=len(pars)
        # print(f'pars={pars}  ll={ll}')
        opeka=vic['opeka']
        otv=vic['otv']

        if ll==1:
            vic[param]=znach
            await message.answer(f"Изменение: строка {param} равна {znach}")
        elif ll==2 and pars[0]=='opeka':
            opeka[int(pars[1])-1]=znach
            await message.answer(f"Изменение: строка opeka[{int(pars[1])}] равна {znach}")
        elif ll==3 and pars[0]=='otv' and pars[2] in('txt','bal','rez'):
            otv[int(pars[1]) - 1][pars[2]] = znach
            await message.answer(f"Изменение: строка otv[{pars[1]}] равна {otv[int(pars[1]) - 1]}")
        await state.set_data(dann)

    #Далее снова выводим на экран список строк
    if otvet == '/obnov':
        await message.answer(f"Скопируйте любую из строк, откорректируйте. и соблюдая синтаксис введите обратно. "
                             f"Либо введите только текст ответом на нужное сообщение:",
                             reply_markup = ReplyKeyboardRemove())
        # vict = dann['vict']
        vic=dann['korr_vopr']
        # print(f'vic=={vic}')
        for nm in ('zagol','vopros','otv','pict','info','opeka',):
            if nm=='otv':
                otv=vic['otv']
                ot={'var':len(otv)+1,'txt':'','bal':0,'rez':''}
                otv.append(ot)
                for ot in otv:
                    for nm in ('txt','bal','rez'):
                        # print(f'ot=={ot}')
                        var=ot['var']
                        txt=f"otv:{ot['var']}:{nm}= {ot[nm]}"
                        await message.answer(txt)
            elif nm=='opeka':
                i=0;
                opeka=vic['opeka']
                # print(f'opeka=={opeka}')
                opeka.append('')
                # print(f'opeka=={opeka}')
                for op in opeka:
                    i+=1
                    txt = f'opeka:{i}= {op}'
                    await message.answer(txt)
            else:
                if nm!='num':
                    # i += 1
                    txt=f'{nm}= {vic[nm]}'
                    await message.answer(txt)
        await message.answer('/exit= Выход и запись итога')
        await message.answer('/obnov= Для удобства заново вывести все строки')

    await state.set_data(dann)
    await state.set_state(Order_all.zoo_rabotnik_korrect.state)



# ВИКТОРИНА
@router.message(Command("victorina"))
async def victorina_(message: Message, command: CommandObject, state: FSMContext):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return
    user_name=message.chat.username
    full_name=fullname(message)
    await message.answer(f"Читаю условия викторины {user_name} {full_name}")

    # ПЕРВИЧНАЯ УСТАНОВКА ДАННЫХ ВИКТОРИНЫ
    await state.set_state(Order_all.zoo.state)
    dann = await state.get_data()  # читаем список всех категорий
    bad = False
    if dann == {}:
        bad = True
    else:
        if not ('vict' in dann): bad = True
    # await message.answer(f"2. Выбор категорий блюд bad={bad} ")
    if bad:  # Если ещё ничего не читали И НЕ ПИСАЛИ
        # await message.answer(f"Читаю условия викторины {user_name}")
        vict = read_victorina()
        dann['vict']=vict
    vict=dann['vict']
    kol_vopr=len(vict)
    await message.answer(f"викторина содержит {kol_vopr} вопросов {user_name}, сыграем?")

    # исходная установка старопрочитанных игроков
    if 'user' in dann:
        user=dann['user']
    else:
        users=read_users()
        user = {}
        for us in users:  # поиск игрока в старом списке
            # print(f'user_name=={user_name}  us=={us}')
            if us['user_name'] == user_name:
                user = us
                user['spros_xran']=False
        if user == {}:# если игок впервые и не найден
            user = {'user_name': user_name, 'xran': '???','spros_xran':False}
            # users.append(user)
    dann['user']=user
    dann['full_name']=full_name
    await state.set_data(dann)
    delt=0

    if user['xran']=='???':
        await message.answer(f"Мы прежде никогда не встречались {user_name} Хотите сохранять сведения о себе?")
    if user['xran']=='yes':
        await message.answer(f"Мы прежде встречались {user_name} ваши прежние итоги сохранены")
    if user['xran']=='no':
        #проверка как давно встречались, дольше 1 минуты
        if 'now' in user:
            old = user['now']
            old = datetime.strptime(old, '%Y-%m-%d %H:%M:%S.%f')
            old = old.timestamp()
        else:old=0

        now = datetime.now()
        now = now.timestamp()
        delt = now - old
        text=f"Мы прежде встречались {user_name} ваши итоги не сохраняются"
        if delt>60:text = text+ f", но за прошедшее время. свыше 60 секунд, может уже передумали"
        await message.answer(text)


    # await state.set_data(dann)
    if user['xran'] in ('no','???') and ((not user['spros_xran']) or delt>60):
        await message.answer(f"{full_name} Хотите ли вы сохранять данные о своём прохождении викторины, на случай разрыва связи? \n"
                             f"/yes =ДА /no =НЕТ")
        await state.set_state(Order_all.zoo_waiting_xran)
        return
    await state.set_state(Order_all.zoo_waiting_victory)
    await ask_victory(message, state, "")






@router.message(Order_all.zoo_waiting_xran) # работает с одной выбранной категорией
async def zoo_waiting_xran(message: types.Message, state: FSMContext):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return
    dann = await state.get_data()
    otvet = message.text.lower()
    if otvet[0]=='/':otvet=otvet[1::]
    full_name=dann['full_name']
    if otvet not in ('yes','no'):
        await message.answer(
            f"{full_name} Я не смог распознать варианты ответов, да или нет. Пока останется нерешённым")
        otvet='???'
    if otvet=='yes':
        await message.answer(f"{full_name} Я буду сохранять ваши ответы.")
    if otvet=='no':
        await message.answer(f"{full_name} Я не буду сохранять ваши ответы.")

    dann['user']['xran']=otvet
    dann['user']['spros_xran'] = True
    await state.set_data(dann)
    await state.set_state(Order_all.zoo_waiting_victory)
    await ask_victory(message, state, "")


@router.message(Order_all.zoo_waiting_victory) # работает с одной выбранной категорией
async def ask_victory(message: types.Message, state: FSMContext, question_text: str):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return
    dann = await state.get_data()
    user=dann['user']
    vict=dann['vict']

    kb = [];
    kbs = [];
    i = -1
    for vic in vict:
        i += 1
        if i == 5: kbs.append(kb);kb = [];i = 0
        kb.append(types.KeyboardButton(text=vic['zagol']))
    kbs.append(kb);kb = []
    kb.append(types.KeyboardButton(text=f'/random - случайная категория'))
    kb.append(types.KeyboardButton(text='/totem - определить тотемное животное'))
    kbs.append(kb);kb = []
    # xran=user['xran']
    soob_xran='/save - выход обратно'
    if user['xran']=='yes':soob_xran='/save - сохранить и выйти'
    kb.append(types.KeyboardButton(text=soob_xran))
    kb.append(types.KeyboardButton(text='/letter - отправить сообщение'))
    kbs.append(kb);kb = []
    keyboard = types.ReplyKeyboardMarkup(keyboard=kbs, resize_keyboard=True)
    await message.answer(f"Выберите тему вопроса", reply_markup=keyboard)
    await state.set_state(Order_all.zoo_waiting_vibor.state)





#@dp.message(CommandStart())
async def command_start_handler_copy(message: Message) -> None:
    # val='12124142'
    kb = [[
        # types.KeyboardButton(text="Погода"),
        # types.KeyboardButton(text="ЕДА"),
        types.KeyboardButton(text="Зоопарк"),
        types.KeyboardButton(text="Описание бота"),
        ],]
    # kb[0].append(types.KeyboardButton(text=val))
    keyboard = types.ReplyKeyboardMarkup(keyboard=kb,resize_keyboard=True)
    await message.answer(f"Привет! С чего начнем?", reply_markup=keyboard)



@router.message(Order_all.zoo_waiting_letter) # работает с одной выбранной категорией
async def zoo_waiting_letter_(message: types.Message, state: FSMContext):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return
    letter = message.text
    await message.answer( f"Ваше сообщение разработчикам: {letter}", reply_markup=ReplyKeyboardRemove())  # КЛАВИАТУРА УБРАНА
    await message.answer(f"Посылаю и записываю в базу")
    write_letter(message)
    await message.answer("Ваше сообщение НЕ было отправлено разработчику. Он его прочитает когда войдёт в систему")
    await state.set_state(Order_all.zoo_waiting_victory)
    await ask_victory(message, state,"")

def zoo_func_param(vict,name):
    zn=''
    if name in vict:
        zn = vict[name]
    if str(type(zn)) == "<class 'list'>":  # Если вариантов много - любой случайный
        zn = random.choice(zn)
    return zn

async def zoo_vivod_vibor(message: types.Message, vic, good):
    # print(f'блок печати тотемного животного {vic}')
    if good:
        await message.answer(f"ваше тотемное животное {vic['zagol']} . Хотите с ним подружиться???")
    else:
        await message.answer(f"Например {vic['zagol']} - вы плохо знаете про него . Хотите с ним подружиться")
    pict=zoo_func_param(vic,'pict')

    if pict != "":
        await message.answer(f"вот так он выглядит: {pict}")
    info = zoo_func_param(vic,'info')
    if info != '':
        if good:await message.answer(f"Вы о нём много знаете. но почитать никогда не вредно: {info}")
        else:await message.answer(f"Почитайте про него: {info}")
    opeka = zoo_func_param(vic,'opeka')

    await message.answer(f"{opeka}")




@router.message(Order_all.zoo_waiting_dostig) # работает с одной выбранной категорией
async def zoo_waiting_dostig_(message: types.Message, state: FSMContext):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return
    # await message.answer(f"РАБОТАЕТ БЛОК после нажатия клавиатуры ВЫБОРА ВАРИАНТА ОТВЕТА")
    # variant = message.text
    dann = await state.get_data()
    user=dann['user']
    totem=user['totem']
    pict = zoo_func_param(totem, 'pict')
    zagol= zoo_func_param(totem, 'zagol')

    text = f'УРА! Я прошёл викторину! Все идите в боту: (https://t.me/ElsufievAl_bot) Моё тотемное животное {zagol}'
    vk_share_link = f'https://vk.com/share.php?url=https://t.me/ElsufievAl_bot&title={text}'
    if pict!='':vk_share_link = vk_share_link + f'&image={pict}'

    keyboard = InlineKeyboardMarkup(inline_keyboard=[[InlineKeyboardButton(text='Перейти в ВК', url=vk_share_link)]])
    if pict=='':
        await message.answer(text="Нажмите на кнопку ниже, чтобы перейти на страницу ВКонтакте:",reply_markup=keyboard)
    else:
        await message.answer_photo(photo=pict,reply_markup=keyboard,
                               caption="Нажмите на кнопку ниже, чтобы перейти на страницу ВКонтакте:")
    await state.set_state(Order_all.zoo_waiting_victory)
    await ask_victory(message, state,"")




@router.message(Order_all.zoo_waiting_vibor) # работает с одной выбранной категорией
async def zoo_waiting_vibor_(message: types.Message, state: FSMContext):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return
    # await message.answer(f"РАБОТАЕТ БЛОК после нажатия клавиатуры ВЫБОРА ВАРИАНТА ОТВЕТА")
    variant = message.text
    dann = await state.get_data()
    user=dann['user']
    vict=dann['vict'];vic={} # вся викторина и конкретный вопрос в ней

    if variant[:7:] == '/letter':
        await message.answer(f"Напишите сообщение, что именно вы хотите передать разработчикам сайта. "
                             f"Мы его сразу отправим.", reply_markup=ReplyKeyboardRemove()) # КЛАВИАТУРА УБРАНА
        await state.set_state(Order_all.zoo_waiting_letter.state)
        return

    if variant[:5:]=='/save':
        await message.answer(f"Блок сохранения данных")
        write_user(user)
        await message.answer(f"Данные сохранены")
        # ПОЛНЫЙ ОТКАТ НА СТАРТ!!!
        await state.set_state(None)
        await command_start_handler_copy(message)
        return
    if variant[:6:] == '/totem':
        # await message.answer(f"Блок определения тотемного животного по вашим ответам")
        if 'user' not in dann:
            await message.answer(f"Ещё слишком рано определять ваше тотемное животное, мало ответов")
            return
        user = dann['user']
        if 'otv' not in user:
            await message.answer(f"Ещё слишком рано определять ваше тотемное животное, мало ответов")
            return
        us_otveti = user['otv']
        bests=[]
        not_bests=[]
        maxx_bal=0
        # print(f'maxx_bal=={maxx_bal}')
        for otv in us_otveti:  #Нахождение списка максимальных ответов
            if otv['bal'] == maxx_bal: bests.append(otv)
            if otv['bal']>maxx_bal:not_bests=not_bests+bests;bests=[otv];maxx_bal=otv['bal']
            if otv['bal']<maxx_bal: not_bests.append(otv)
            # print(f'otv=={otv}')
            # print(f'maxx_bal=={maxx_bal}')
            # print(f'bests=={bests}')
            # print(f'not_bests=={not_bests}')
        if len(bests)==1:
            num=bests[0]['num'];good=1
            for vv in vict:
                if vv['num']==num:totem=vv
            await zoo_vivod_vibor(message,totem,True)

        else:
            if len(not_bests) == 0:
                await message.answer(f"Вы одинаково хорошо знаете всех зверей, про кого отвечали!!! "
                                 f"Будет сложно выбрать. \n Хотите покормить животных, узнать их поближе?"
                                     f"Такому знатоку природы точно надо сделать опеку хоть над кем-нибудь."
                                     f"\nА я выбираю случайного из тех, кого вы так хорошо знаете.")
                vibor = [random.choice(bests)]
                num = vibor[0]['num'];good=2
                for vv in vict:
                    if vv['num'] == num:totem=vv
                await zoo_vivod_vibor(message, totem, True)

            else:
                await message.answer(f"У вас много одинаково хороших ответов, целых{len(bests)} штук!!! Будет сложно выбрать. "
                                     f"\n Но есть те, кого вы знаете существенно хуже")

                vibor = [random.choice(not_bests)]
                num = vibor[0]['num'];good=0
                for vv in vict:
                    if vv['num'] == num:totem=vv
                await zoo_vivod_vibor(message, totem, False)
        if good>0:
            # print(f'начинаю делиться с друзьями достижением')
            user['totem']=totem
            await state.set_data(dann)
            kb = [];kbs = [];
            kb.append(types.KeyboardButton(text=f'Поделиться с друзьями в соцсети'))
            kb.append(types.KeyboardButton(text='Не надо'))
            kbs.append(kb)
            keyboard = types.ReplyKeyboardMarkup(keyboard=kbs, resize_keyboard=True)
            await message.answer(f"Хотите ли вы поделиться своим достижением с друзьями?", reply_markup=keyboard)
            await state.set_state(Order_all.zoo_waiting_dostig.state)
        return

    if variant[:7:]=='/random':
        await message.answer(f"Блок выбора случайной категории (ещё не готов, беру первый попавшийся)")
        vic=vict[0]
    for vv in vict:
        if vv['zagol']==variant:
            vic=vv
    if vic=={}:
        await message.answer(f"Вы нажали что-то не то, получилось {message.text}, попробуйте ещё раз")
        # print(f'err_vict=={vict}')
        # print(f'err_message==*{message.text}*')
        return
    # вариант выбран, идёт на печать
    vopros=vic['vopros']
    text=f"Вот мой вопрос: {vopros} \n Варианты ответов:"
    # await message.answer(f"Вот мой вопрос: {vopros} \n Варианты ответов:")
    otveti=vic['otv']
    # print(f'otveti=[otveti')
    for otv in otveti:
        # print(f'otv=={otv}')
        # print(f"\n /{otv['var']} : {otv['txt']}")
        text = text + f"\n /{otv['var']} : {otv['txt']}"
        # print(f'text=={text}')
    await message.answer(f"{text}", reply_markup=ReplyKeyboardRemove())
    dann['vopros']=vic
    await state.set_data(dann)
    await state.set_state(Order_all.zoo_waiting_otvet.state)




@router.message(Order_all.zoo_waiting_otvet)  # работает с одной выбранной категорией
async def zoo_waiting_otvet_(message: types.Message, state: FSMContext):
    if message.text == '/start':
        await state.set_state(None)
        await command_start_handler_copy(message)
        return
    # await message.answer(f"РАБОТАЕТ БЛОК АНАЛИЗА ВЫБОРА ВАРИАНТА ОТВЕТА - НАЖАТИЕ КНОПКИ ЖИВОТНОГО")
    variant = message.text
    if variant[0]=='/':variant=variant[1::]

    dann = await state.get_data()
    user = dann['user']
    vopros = dann['vopros'];num_v=vopros['num']
    vopros_name=vopros['zagol']
    otveti=vopros['otv']
    otvet={}
    for otv in otveti:#Ищем ответ по номеру ответа
        if str(otv['var'])==variant:otvet=otv
    if otvet=={}:
        await message.answer(f"Вы нажали что-то не то, на входе было {message.text}, а я жду названия животного, попробуйте ещё раз!")

        # print(f'err_message==*{message.text}*')
        # print(f'err_vopros=={vopros}')
        # print(f'err_vict=={dann['vict']}')
        return
    rez=otvet['rez'];bal=otvet['bal'];var=otvet['var']
    await message.answer(f"{rez} Вы заработали {bal} баллов")
    if 'otv' not in user:user['otv']=[]
    us_otveti=user['otv']
    novii=True
    for otv in us_otveti:
        if otv['num']==num_v:
            bal_=otv['bal']
            novii=False
            if bal_>bal:await message.answer(f"Какая жалость, вы на этот вопрос прежде отвечали лучше...")
            if bal_ < bal: await message.answer(f"Поздравляю! В прошлый раз на этот же вопрос вы ответили хуже.")
            otv['bal']=bal;otv['var']=var
    if novii:
        otv={'num':num_v,'var':var,'bal':bal,'zagol':vopros_name}
        us_otveti.append(otv)
        await message.answer(f"Прежде на этот вопрос вы ещё не отвечали.")
    summ=0
    for otv in us_otveti:summ+=otv['bal']
    await message.answer(f"Всего на данный момент вы набрали {summ} баллов")
    user['summ']=summ
    await state.set_data(dann)
    await state.set_state(Order_all.zoo_waiting_victory.state)  # БЕЗ ЭТОЙ СТРОКИ ВСЁ ЛОМАЛОСЬ
    await ask_victory(message, state, "")
    return





























