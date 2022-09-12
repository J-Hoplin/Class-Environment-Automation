from typing import Any, MutableSequence,Union
import json


'''
JSON Format

img | required | image tag name
mem | selection, default : should upper than 500mb | memory limit 
env | required | environments
'''

class CommandParser(object):
    def __init__(self) -> None:
        pass

    def __loadConfigJSON(self) -> dict[Any,Any]:
        with open('./config.json','r') as j:
            return json.load(j)

    def build(self,args):
        pass

    def remove(self,args):
        pass