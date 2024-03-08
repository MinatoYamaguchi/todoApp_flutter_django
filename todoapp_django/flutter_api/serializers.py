from rest_framework import serializers
from .models import Todo_Item


class ItemSerializer(serializers.ModelSerializer):
    class Meta:
        model=Todo_Item
        fields=(
            'id','title','content','isCompleted'
        )