from django.conf import settings
from django.core.cache import cache
from django.http import JsonResponse
from random import randint
from urllib.parse import quote


def get_state():
    res = ""
    for i in range(8):
        res += str(randint(0, 9))
    return res


def apply_code(request):
    appid = settings.QQ_APPID
    redirect_uri = quote(settings.SITE_BASE_URL + "/settings/qq/web/receive_code/")
    state = get_state()

    cache.set(state, True, 7200)  # state有效期2小时

    apply_code_url = "https://graph.qq.com/oauth2.0/authorize"
    return JsonResponse({
        'result': "success",
        'apply_code_url': apply_code_url + "?response_type=code&client_id=%s&redirect_uri=%s&state=%s" % (appid, redirect_uri, state)
    })
