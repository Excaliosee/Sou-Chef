from rest_framework.decorators import api_view, parser_classes
from rest_framework.response import Response
from .models import Recipe
from .serializers import RecipeSerializer
from rest_framework import status
from rest_framework.parsers import MultiPartParser
# from openai import OpenAI
import os
from dotenv import load_dotenv
import google.generativeai as genai
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import time

load_dotenv()

# client = OpenAI(
#   api_key=os.getenv('OPENAI_API_KEY')
# )

try:
    client = genai.Client(api_key=os.getenv("GOOGLE_API_KEY"))
except Exception as e:
    print(f"Error configuring Gemini: {e}")
    client = None

@api_view(['GET', 'POST'])
def recipe_list(request):
    if request.method == 'GET':
        recipes = Recipe.objects.all()
        serializer = RecipeSerializer(recipes, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = RecipeSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
@api_view(['POST'])
@parser_classes([MultiPartParser])
def transcribe(request):
    if 'audio' not in request.data:
        return Response(
            {"error": "No audio file found."},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    audio_file = request.data['audio']

    temp_file_name = f"temp_audio_{int(time.time())}_{audio_file.name}"
    file_path = default_storage.save(temp_file_name, ContentFile(audio_file.read()))

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
        my_file = client.files.upload(file = file_path)
        prompt = 'Generate a transcript of the speech.'

        transcription = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=[prompt, my_file]
        )

        default_storage.delete(file_path)
        client.files.delete(name=my_file.name)

        return Response({"text": transcription.text})
    
    except Exception as e:
        if 'file_path' in locals():
            default_storage.delete(file_path)
        if 'gemini_file' in locals():
            client.files.delete(name=my_file.name)

        return Response(
            {"error": str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    