from django.db import models
from django.conf import settings
from decimal import Decimal
from django.contrib.auth.models import User
import urllib
import json
from django.core.files import File
# helpful link: https://www.digitalocean.com/community/tutorials/how-to-create-django-models
# The User model. The user_id is automatically generated
class User(models.Model):
    firstname = models.CharField(max_length=30)
    lastname = models.CharField(max_length=30)
    username = models.CharField(max_length=30)
    password = models.CharField(max_length=30)
    # for displaying a user objects
    def __str__(self):
        return self.username + " (name: " + self.firstname + " " + self.lastname + ")"


class Memory(models.Model):
    username = models.CharField(max_length=30)
    title = models.CharField(max_length=255)
    text = models.TextField()
    image = models.ImageField(upload_to='images/') #how to use imagefield: https://wsvincent.com/django-image-uploads/
    date = models.CharField(max_length=255)

    def __str__(self):

             return "title: " + self.title + " date: " + str(self.date) + " (id:" + str(self.userID) + ")"

    # orders posts by date created : https://www.digitalocean.com/community/tutorials/how-to-create-django-models
    class Meta:
        ordering = ['date']

        def __unicode__(self):
            return self.title

# associating image file path with image field https://stackoverflow.com/questions/1308386/programmatically-saving-image-to-django-imagefield
memory = Memory()
memory.image = "images/image.png"
memory.save()
