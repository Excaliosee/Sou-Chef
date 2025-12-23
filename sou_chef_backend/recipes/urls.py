from django.urls import path, include
from . import views
from rest_framework.routers import DefaultRouter

router = DefaultRouter()

router.register(r'recipes', views.RecipeViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('transcribe/', views.transcribe, name='transcribe'),
]