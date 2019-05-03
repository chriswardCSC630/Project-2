# standard imports

from django.shortcuts import render
from django.views import View
from django.http import HttpResponse, JsonResponse, QueryDict
from django.urls import include, path
from rest_framework import routers
from API_proj2app.models import *
#from django.contrib.auth.models import User
# Create your views here.

class requestHandlers(View):
    # request data will be storied in request's body
    def index(request):
        return HttpResponse("Welcome")

    # handle all requests at .../login/
    def login(request):
        # Only POSTing to .../login/
    # from https://stackoverflow.com/questions/29780060/trying-to-parse-request-body-from-post-in-django

        if request.method == "POST":
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

    # handle all requests at .../newUser/
    def newUser(request):
         # Only POST
        content = QueryDict(request.body.decode('utf-8')).dict() #access content from request
        lastname = content["lastname"]
        firstname = content["firstname"]
        username = content["username"]
        password = content["password"]

        if request.method == "POST":
            if len(User.objects.filter(username = username)) > 0:
                return JsonResponse({'status':'false','message':"This username is already in use"}, status=406)

            try:
                new_user = User.objects.create(firstname = firstname, lastname = lastname, username = username, password = password)
            except:
                return JsonResponse({'status':'false', 'message':"Invalid username or password"}, status=406)

            new_user.save()
            return JsonResponse({'status':'true', 'message':"Your account has been created, please login"}, status=201) #201 -> new resource created


    # handle all requests at .../memories/
    def handleMemories(request):
        session_name = request.session["session_name"]

        # Decode request body content
        content = QueryDict(request.body.decode('utf-8')).dict()

        if request.method == "GET":
            data = {}

            # Propogate memories to return to frontend
            for memory in Memory.objects.filter(username = session_name):
                data[memory.id] = {"title": memory.title, "text": memory.text, "photo": memory.photo, "date": memory.date}

            # Return data to frontend
            return JsonResponse(data, status=200)

        elif request.method == "POST":
            title = content["title"]
            photo = content["photo"]
            text = content["text"]
            date = content["date"]

            # Create a memory and save its reference to access id
            memory = Memory.object.create(title = title, photo = photo, text = text, date = date)
            memory.save()
            # Return id as part of JsonResponse so frontend can set id
            return JsonResponse({'status':'false', "message": "memory POSTed", "id": memory.id}, status=201) #201 -> new resource created


        elif request.method == "PATCH":
            # Access memory data to update as well as the memory id
            data = {"title": content["title"], "photo": content["photo"], "text": content["text"], "date": content["date"]}
            id = content["id"]

            # Access memory based on id
            memory = Memory.objects.get(id=id)

            # Update memory
            for (key, value) in data.items():
                setattr(object, key, value)
            object.save() #save the modified object

            data["status"] = "true"
            data["message"] = "memory PATCHed"
            #Memory.data.update(data)

            return JsonResponse(data, status=200)

        elif request.method == "DELETE":
            id = content["id"]

            # Delete memory based on id
            Memory.objects.get(id=id).delete()

            return JsonResponse({"status": "true", "message": "memory DELETEd"}, status=200)
