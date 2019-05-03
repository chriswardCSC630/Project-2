from django.db import models
from django.conf import settings
from decimal import Decimal
from django.contrib.auth.models import AbstractUser
import urllib
import json
from django.core.files import File
from . import helper # we created this

# helpful link: https://www.digitalocean.com/community/tutorials/how-to-create-django-models
# The User model. The user_id is automatically generated
class User(AbstractUser):

    hash_id = models.CharField(max_length=32, default=helper.create_hash, unique=True)

    firstname = models.CharField(max_length=30, default="none")
    lastname = models.CharField(max_length=30, default="none")

    # username and password already in AbstractUser
    #username = models.CharField(max_length=30, default="none", unique=True)
    #password = models.CharField(max_length=30, default="none")
    # for displaying a user objects
    def __str__(self):
        return self.username + " (name: " + self.firstname + " " + self.lastname + ")"


class Memory(models.Model):
    hash_id = models.CharField(max_length=32,default=helper.create_hash,unique=True)
    title = models.CharField(max_length=255, default="none")
    text = models.TextField(default="none")
    photo = models.FileField(upload_to='images/', null=True, verbose_name="") #models.TextField(default="none") # models.ImageField(upload_to='images/') --> alternatively: https://wsvincent.com/django-image-uploads/
    date = models.CharField(max_length=255, default="none")

    def __str__(self):

             return "title: " + self.title + " date: " + str(self.date) + " (id:" + str(self.userID) + ")"

    # orders posts by date created : https://www.digitalocean.com/community/tutorials/how-to-create-django-models
    class Meta:
        ordering = ['date']

        def __unicode__(self):
            return self.title

# associating imagefile path with image field https://stackoverflow.com/questions/1308386/programmatically-saving-image-to-django-imagefield
# memory = Memory()
# memory.image = "images/image.png"
# memory.save()
