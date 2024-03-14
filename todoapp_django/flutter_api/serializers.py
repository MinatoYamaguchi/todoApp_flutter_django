from rest_framework import serializers
from .models import TodoItem


class ItemSerializer(serializers.ModelSerializer):
    class Meta:
        model=TodoItem
        fields=(
            'id','title','content','isCompleted'
        )