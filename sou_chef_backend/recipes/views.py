import os
import time
from google import genai
from dotenv import load_dotenv

from rest_framework.decorators import api_view, parser_classes, action
from rest_framework.parsers import MultiPartParser
from rest_framework.response import Response
from rest_framework import status, viewsets, permissions

from .models import Recipe
from .serializers import RecipeSerializer
# from openai import OpenAI
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile

from .permissions import IsOwnerOrReadOnly
from rest_framework.authentication import SessionAuthentication
from recipes.authentication import FirebaseAuthentication

load_dotenv()

# client = OpenAI(
#   api_key=os.getenv('OPENAI_API_KEY')
# )

try:
    client = genai.Client(api_key=os.getenv("GOOGLE_API_KEY"))
except Exception as e:
    print(f"Error configuring Gemini: {e}")
    client = None

class RecipeViewSet(viewsets.ModelViewSet):
    queryset = Recipe.objects.all()
    serializer_class = RecipeSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]
    authentication_classes = [FirebaseAuthentication, SessionAuthentication]
    # permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        return Recipe.objects.prefetch_related('ingredients__ingredient', 'steps').all().order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

    @action(detail = False, methods = ["get"], permission_classes = [permissions.IsAuthenticated])
    def mine(self, request):
        user = request.user
        my_recipes = Recipe.objects.filter(created_by = user)
        serializer = self.get_serializer(my_recipes, many = True)
        return Response(serializer.data)
    
    @action(detail=True, methods= ["post"], permission_classes = [permissions.IsAuthenticated])
    def like(self, request, pk=None):
        recipe = self.get_object()
        user = request.user

        if user in recipe.likes.all():
            recipe.likes.remove(user)
            liked = False
        else:
            recipe.likes.add(user)
            liked = True

        return Response({"liked":liked, "likes_count":recipe.likes.count()})
    
    @action(detail=False, methods=["get"], permission_classes = [permissions.IsAuthenticated])
    def favorites(self, request):
        liked_recipes = Recipe.objects.filter(likes = request.user).order_by("-id")

        serializer = self.get_serializer(liked_recipes, many = True)
        return Response(serializer.data)
    
    
@api_view(['POST'])
@parser_classes([MultiPartParser])
def transcribe(request):
    if "audio" not in request.data:
        return Response(
            {"error": "No audio file found."},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    audio_file = request.data['audio']

    temp_file_name = f"temp_audio_{int(time.time())}_{audio_file.name}"
    file_path = default_storage.save(temp_file_name, ContentFile(audio_file.read()))
    full_path = default_storage.path(file_path)

    # if not client.api_key:
    #     return Response(
    #         {"error": "OpenAI API key not configured on the server."},
    #         status=status.HTTP_500_INTERNAL_SERVER_ERROR,
    #     )
    
    # try:
    #     transcription = client.audio.transcriptions.create(
    #         model="g",
    #         file=audio_file,
    #         response_format="text"
    #     )
    #     return Response({"text": transcription})
    
    # except Exception as e:
    #     return Response(
    #         {"error": str(e)},
    #         status=status.HTTP_500_INTERNAL_SERVER_ERROR
    #     )

    try:
        my_file = client.files.upload(path = full_path)
        prompt = "Generate a transcript of the speech."

        response = client.models.generate_content(model="gemini-2.0-flash", contents=[my_file, prompt])
        client.files.delete(name=my_file.name)
        default_storage.delete(file_path)

        return Response({"text": response.text})
    
    except Exception as e:
        if "file_path" in locals():
            default_storage.delete(file_path)
        if "my_file" in locals() and client:
            try:
                client.files.delete(name=my_file.name)
            except:
                pass

        return Response(
            {"error": str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    