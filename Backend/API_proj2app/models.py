from django.db import models
from django.conf import settings
from decimal import Decimal
from django.contrib.auth.models import User
import urllib
import json
# helpful link: https://www.digitalocean.com/community/tutorials/how-to-create-django-models
# The User model. The user_id is automatically generated
class User(models.Model):
    firstname = models.CharField(max_length=30)
    lastname = models.CharField(max_length=30)
    username = models.CharField(max_length=30)
    password = models.CharField(max_length=30)
    # for displaying a user objects
    def __str__(self):
        return self.username + " (name: " + str(self.firstname) + " " + str(self.lastname) + ")"

class Memory(models.Model):
    username = models.CharField(max_length=30)
    title = models.CharField(max_length=255)
    content = models.TextField()
    image = models.TextField()
    date = models.CharField(max_length=255)

    def __str__(self):
             return "title: " + str(self.title) + " date: " + str(self.date) + " (username:" + str(self.username) + ")"

    class Meta:
        ordering = ['created_on']

        def __unicode__(self):
            return self.title
