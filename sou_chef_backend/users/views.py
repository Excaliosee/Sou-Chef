from django.shortcuts import get_object_or_404
from django.contrib.auth.models import User
from rest_framework import generics, permissions, status
from .serializers import UserSerializer
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Follow

class CurrentUserView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)
    
    def put(self, request):
        user = request.user
        serializer = UserSerializer(user, data = request.data, partial = True)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        
        return Response(serializer.errors, status= 400)
    
class FollowUserView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, user_id):
        user_to_follow = get_object_or_404(User, id=user_id)

        if request.user == user_to_follow:
            return Response({"error": "Can't follow yourself."}, status=status.HTTP_400_BAD_REQUEST)
        
        follow_rel = Follow.objects.filter(users_from=request.user, users_to = user_to_follow)

        if follow_rel.exists():
            follow_rel.delete()
            return Response({"status": "unfollowed"}, status= status.HTTP_200_OK)
        else:
            Follow.objects.create(users_from=request.user, users_to=user_to_follow)
            return Response({"status": "followed"}, status= status.HTTP_200_OK)
            

# Create your views here.
