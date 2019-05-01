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
# from https://stackoverflow.com/questions/29780060/trying-to-parse-request-body-from-post-in-django

    content = QueryDict(request.body.decode('utf-8')).dict() # content should be dict now
    username = content["username"]
    try:
        user = User.objects.get(username = username)
    except:
        return JsonResponse({'status':'false','message':"Invalid username"}, status=406)
    password = encrypt(content["password"])
    if (password != user.password):
        return JsonResponse({'status':'false','message':"Invalid password"}, status=406)

    request.session["session_name"] = User.objects.get(username)#set this to the username #learned sessions from session documentation: https://docs.djangoproject.com/en/2.2/topics/http/sessions/
    return JsonResponse({'status':'true','message':"Logged in"}, status=200)

def encrypt(password):
    return password

 def newUser(request):
     # Only POST
     user = User.objects.create(firstname, lastname, username, password)

     if request.method == "POST":
     # NEED CODE HERE TO ACCESS FIRSTNAME, LASTNAME, USERNAME, and PASSWORD from request


# handle all requests at memories
def handleMemories(request):
    session_name = request.session["session_name"]

    content = QueryDict(request.body.decode('utf-8')).dict()

    if request.method == "GET":
        data = {}

        for memory in Memory.objects.filter(username = session_name):
            data[memory.id] = {"title": memory.title, "content": memory.content, "image": memory.image, "date": memory.date}

        return JsonResponse(data, status=200)

     elif request.method == "POST":
        title = content["title"]
        photo = content["photo"]
        text = content["text"]
        date = content["date"]


     elif request.method == "PATCH":
         title = content["title"]
         photo = content["photo"]
         text = content["text"]
         date = content["date"]
         id = content["id"]

     elif request.method == "DELETE":
        id = content["id"]
