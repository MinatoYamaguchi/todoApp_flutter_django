from django.urls import path
from django.conf.urls import include
from rest_framework.routers import DefaultRouter
from .views import TodoView
app_name='flutter_api'

router=DefaultRouter(trailing_slash=False)
router.register('todo_item',TodoView)
urlpatterns=[
    path('',include(router.urls)),
]