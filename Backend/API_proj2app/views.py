# standard imports

from django.shortcuts import render
from django.views import View
from django.http import HttpResponse, JsonResponse, QueryDict
from django.urls import include, path
from rest_framework import routers
from API_proj2app.models import *
from django.contrib.auth.models import User
# Create your views here.

# request data will be storied in request's body
def index(request):
    return HttpResponse("welcome")

def login(request):
    # Only POST
    # return request.body
    body = json.loads(request.body.decode('utf-8')) # from https://stackoverflow.com/questions/29780060/trying-to-parse-request-body-from-post-in-django

    content = QueryDict(body).dict() # content should be dict now

    username = content["username"]
    try:
        user = User.objects.get(username = username)
    except:
        return JsonResponse({'status':'false','message':"Invalid username"}, status=406)
    password = encrypt(content["password"])
    if (password != user.password):
        return JsonResponse({'status':'false','message':"Invalid password"}, status=406)

    request.session["session_name"] = User.objects.get(username)#set this to the username #learned sessions from session documentation: https://docs.djangoproject.com/en/2.2/topics/http/sessions/
    return JsonResponse({'status':'false','message':"Logged in"}, status=200)
def encrypt(password):
    return password
#
# def newUser(request):
#     # Only POST
#
#     # NEED CODE HERE TO ACCESS FIRSTNAME, LASTNAME, USERNAME, and PASSWORD from request
#
#     user = User.objects.create(firstname, lastname, username, password)

# handle all requests at memories
def handleMemories(request):
    session_name = request.session["session_name"]

    if request.method == "GET":
        data = {}

        for memory in Memory.objects.filter(username = session_name):
            data[memory.id] = {"title": memory.title, "content": memory.content, "image": memory.image, "date": memory.date}

        return JsonResponse(data, status=200)
    #
    # if request.method == "POST":
    #
    # if request.method == "PATCH":
    #
    # if request.method == "DELETE":
