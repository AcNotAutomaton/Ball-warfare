from django.conf import settings
from django.contrib.auth import login
from django.contrib.auth.models import User
from django.core.cache import cache
from django.shortcuts import redirect
import requests
from random import randint
from urllib.parse import parse_qs

from game.models.player.player import Player


def receive_code(request):
    data = request.GET
    code = data.get('code')
    state = data.get('state')

    if not cache.has_key(state):
        return redirect("index")
    cache.delete(state)

    redirect_uri = settings.SITE_BASE_URL + "/settings/qq/web/receive_code/"

    # 换取access_token，QQ的token接口返回纯文本
    token_res = requests.get(
        "https://graph.qq.com/oauth2.0/token",
        params={
            "grant_type": "authorization_code",
            "client_id": settings.QQ_APPID,
            "client_secret": settings.QQ_APPKEY,
            "code": code,
            "redirect_uri": redirect_uri,
        },
    ).text
    access_token = parse_qs(token_res).get("access_token", [""])[0]
    if not access_token:
        return redirect("index")

    # 获取openid
    openid_res = requests.get(
        "https://graph.qq.com/oauth2.0/me",
        params={"access_token": access_token, "fmt": "json"},
    ).json()
    openid = openid_res.get("openid", "")
    if not openid:
        return redirect("index")

    players = Player.objects.filter(openid=openid)
    if players.exists():  # 已注册用户直接登录
        login(request, players[0].user)
        return redirect("index")

    # 获取用户昵称和头像
    userinfo_res = requests.get(
        "https://graph.qq.com/user/get_user_info",
        params={
            "access_token": access_token,
            "oauth_consumer_key": settings.QQ_APPID,
            "openid": openid,
        },
    ).json()
    username = userinfo_res.get("nickname", "")
    photo = userinfo_res.get("figureurl_qq_2") or userinfo_res.get("figureurl_qq_1") or ""

    while User.objects.filter(username=username).exists():  # 处理重名
        username += str(randint(0, 9))

    user = User.objects.create(username=username)
    Player.objects.create(user=user, photo=photo, openid=openid)

    login(request, user)

    return redirect("index")
