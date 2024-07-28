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
# from token_data import OPENW_TOKEN

from recipes_handler import router


dp = Dispatcher()
dp.include_router(router)






@dp.message(CommandStart())
async def command_start_handler(message: Message) -> None:
    # val='12124142'
    kb = [[
        types.KeyboardButton(text="Погода"),
        types.KeyboardButton(text="ЕДА"),
        types.KeyboardButton(text="Описание бота"),
        ],]
    # kb[0].append(types.KeyboardButton(text=val))
    keyboard = types.ReplyKeyboardMarkup(keyboard=kb,resize_keyboard=True)
    await message.answer(f"Привет! С чего начнем?", reply_markup=keyboard)
    # await state.finish()


@dp.message(F.text.lower() == "погода")
async def commands(message: types.Message):
    response = as_list(
        as_marked_section(
            Bold("Команды о погоде:"),
            "/start - Старт бота в самое начало",
            "/weather - weather by city",
            "/forecast - forecast 1 - 5 days",
            "/weather_time - weather by date/time",
            "/spisok_time -  моя программа",
            marker="✅ ",
        ))
    await message.answer(**response.as_kwargs())


@dp.message(F.text.lower() == "еда")
async def commands(message: types.Message):
    response = as_list(
        as_marked_section(
            Bold("Команды о еде:"),
            "/category_search_random - случайные блюда (по кумолчанию 5 штук)",
            "/random_meal - выбор одного случайного блюда",
            marker="✅ ",
        ))
    await message.answer(**response.as_kwargs())

@dp.message(F.text.lower() == "описание бота")
async def description(message: types.Message):
    await message.answer("Этот бот предоставляет информацию о погоде.\n И о еде")


async def main() -> None:
    bot = Bot(TOKEN, default=DefaultBotProperties(parse_mode=ParseMode.HTML))
    await dp.start_polling(bot)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, stream=sys.stdout)
    asyncio.run(main())
