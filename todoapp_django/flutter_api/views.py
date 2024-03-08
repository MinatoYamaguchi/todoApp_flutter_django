from django.shortcuts import render
from rest_framework.generics import CreateAPIView,RetrieveUpdateAPIView,UpdateAPIView
from .models import Todo_Item
from rest_framework import viewsets
from .serializers import ItemSerializer



class TodoView(viewsets.ModelViewSet):
    queryset=Todo_Item.objects.all()
    serializer_class=ItemSerializer
    

        