
from aiogram import Router, types
import time

router = Router()

#
# @router.message()
# async def command_start_handler(message: Message) -> None:
#     # This handler receives messages with `/start` command
#    await message.answer(f"Hello, {hbold(message.from_user.full_name)}!")



@router.message()
async def echo_handler(message: types.Message) -> None:
   # Handler will forward receive a message back to the sender
   # By default, message handler will handle all message types (like a text, photo, sticker etc.)

   try:
       await message.send_copy(chat_id=message.chat.id)
       time.sleep(3)
   except TypeError:
       await message.answer("Nice try!")


