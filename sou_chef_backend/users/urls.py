from django.urls import path
from .views import CurrentUserView, FollowUserView

urlpatterns = [
    path("me/", CurrentUserView.as_view(), name="current-user"),
    path("follow/<int:user_id>/", FollowUserView.as_view(), name="follow-user"),
]