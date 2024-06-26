
import telebot
from datetime import datetime
import requests
import json

from extensions import *  # ЭТОТ ВАРИАНТ ДЛЯ ДЗ ПО БОТУ
#from valut_bot_all import * # ЭТОТ ВАРИАНТ мой для валют и погоды

from my_bot_token import *




mbot=my_bot()


#bot = telebot.TeleBot(mbot.get_token())
bot = mbot.get_bot()


@bot.message_handler(content_types=['text'])
def send_text(message):
    chat_id = message.chat.id
    # username = message.from_user.username
    # first_name=message.from_user.first_name
    # last_name = message.from_user.last_name
    otvet=mbot.obrabot_txt(message)
    print(otvet)
    bot.send_message(chat_id,  otvet)



bot.polling(none_stop=True)





