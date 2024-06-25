
import telebot
from datetime import datetime
import requests
import json
from extensions import *






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
    bot.send_message(chat_id,  otvet)



bot.polling(none_stop=True)





