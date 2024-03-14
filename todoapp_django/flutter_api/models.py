from django.db import models


class TodoItem(models.Model):
    title=models.CharField(max_length=30)
    content=models.CharField(max_length=300)
    isCompleted=models.BooleanField(default=False)