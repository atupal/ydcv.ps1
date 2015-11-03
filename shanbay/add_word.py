#!/bin/sh
# -*- coding: utf-8 -*-
''''which python2 >/dev/null && exec python2 "$0" "$@" # '''
''''which python  >/dev/null && exec python  "$0" "$@" # '''

import time
import requests
import json
import pprint

cookie = 'sessionid=xx'
with open('./cookie') as fd:
    cookie = fd.read()

wordbook_id = '116254'
vocabulary_id = '262456'
headers = {
        'cookie': cookie,
        }

def query_word(word):
    url = 'http://www.shanbay.com/api/v1/bdc/search/?word={0}&_={1}'.format(word, int(time.time()*1000))
    res = requests.get(url, headers=headers)
    #pprint.pprint(json.loads(res.content))
    return json.loads(res.content)

def query_collins(word):
    ret = query_word(word)
    url = 'http://www.shanbay.com/api/v1/bdc/vocabulary/definitions/{0}?_={1}'.format(ret['data']['content_id'], int(time.time()*1000))
    ret = requests.get(url, headers=headers)
    print ret.content
    return json.loads(ret.content)


def add_word(word):
    global vocabulary_id
    url = 'http://www.shanbay.com/api/v1/wordlist/vocabulary/'
    headers = {
            'cookie': cookie,
            }
    data = {
            'id': vocabulary_id,
            'word': word.lower(),
            }
    try:
        res = requests.post(url, headers=headers, data=data)
        ret = json.loads(res.content)
    except:
        print word
        exit(0)

    if ret['msg'] == u'词串中单词数量超过上限，无法添加单词':
        new_list_name = 'all_{0}'.format(word)
        url = 'http://www.shanbay.com/api/v1/wordbook/wordlist/'
        headers = {
                'cookie': cookie,
                }
        data = {
                'name': new_list_name,
                'description': 'auto add by script',
                'wordbook_id': wordbook_id,
                }
        try:
            ret = requests.post(url, headers=headers, data=data)
            print ret.content
            vocabulary_id = json.loads(ret.content)['data']['wordlist']['id']
            add_word(word)
        except Exception as e:
            print word
            print e
            exit(0)

        print 'create new list: {0}'.format(new_list_name)

    elif ret['msg'] != 'SUCCESS':
        print word, ret['msg']

def add_top4k():
    words = '''
    '''
    for word in words.split():
        add_word(word)
        time.sleep(3)

def add_word_to_today(word):
    ret = query_word(word)
    url = 'http://www.shanbay.com/api/v1/bdc/learning/'
    requests.post(url, headers=headers, data={'id': ret['data']['content_id']})

def add_today_words():
    words = '''
    tender
    automobile verbal
    '''
    for word in words.split():
        add_word_to_today(word)
        time.sleep(3)


query_word('rim')
