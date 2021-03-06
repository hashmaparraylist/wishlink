from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse
import jieba

import json

@csrf_exempt
def segment(request):
    inputStr = ""
    if request.method == 'POST':
        try:
            inputStr = request.POST['input']
        except KeyError:
            pass
    elif request.method == 'GET':
        try:
            inputStr = request.GET['input']
        except KeyError:
            pass
    seg_list = jieba.cut_for_search(inputStr)
    return HttpResponse(json.dumps({'result': list(seg_list)}, ensure_ascii=False))
