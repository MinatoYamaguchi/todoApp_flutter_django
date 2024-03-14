from django.shortcuts import render
from .models import TodoItem
from .serializers import ItemSerializer
from rest_framework.viewsets import GenericViewSet, mixins
from rest_framework.response import Response
from django.shortcuts import get_object_or_404

class TodoView(mixins.CreateModelMixin, mixins.ListModelMixin,
               mixins.UpdateModelMixin, GenericViewSet):
    
    queryset=TodoItem.objects.all()
    serializer_class=ItemSerializer
    
    def get_queryset(self):
        is_completed_param=self.request.query_params.get('isCompleted',None)
        queryset = TodoItem.objects.all()
        if is_completed_param == 'true':
            queryset = queryset.filter(isCompleted=True)
        elif is_completed_param == 'false':
            queryset = queryset.filter(isCompleted=False)
        return queryset
    def get_object(self):
        queryset = self.filter_queryset(self.get_queryset())
        lookup_url_kwarg_value = self.kwargs.get(self.lookup_url_kwarg)
        item = get_object_or_404(queryset, id=lookup_url_kwarg_value)
        return item
    
    
    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        return Response(serializer.data)

    def perform_update(self, serializer):
        serializer.save()
    
    

        