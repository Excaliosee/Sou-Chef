import firebase_admin
from firebase_admin import auth, credentials
from django.conf import settings
from rest_framework import authentication
from rest_framework import exceptions
from django.contrib.auth.models import User

if not firebase_admin._apps:
    cred = credentials.Certificate(settings.FIREBASE_ADMIN_CREDENTIALS_PATH) 
    firebase_admin.initialize_app(cred)

class FirebaseAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION')
        if not auth_header:
            return None

        parts = auth_header.split()
        if parts[0].lower() != 'bearer':
            return None

        if len(parts) != 2:
            raise exceptions.AuthenticationFailed('Authorization header must contain two space-delimited values')

        token = parts[1]

        try:
            decoded_token = auth.verify_id_token(token, clock_skew_seconds=10)
            uid = decoded_token['uid']
            email = decoded_token.get('email', '')
        except Exception as e:
            print(f"\nToken Verification Failed: {e}")
            raise exceptions.AuthenticationFailed('Invalid Firebase token')

        user = None

        if email:
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                pass
            except User.MultipleObjectsReturned:
                user = User.objects.filter(email=email).first()

        if not user:
            try:
                user = User.objects.get(username=uid)
                
                if email and not user.email:
                    user.email = email
                    user.save()
                    print(f"✅ Self-healed user {user.username}: Saved email {email}")

            except User.DoesNotExist:
                pass

        if not user:
            try:
                user = User.objects.create_user(username=uid, email=email)
                print(f"🆕 Created new user: {uid} with email {email}")
            except Exception as e:
                raise exceptions.AuthenticationFailed('User could not be created')

        return (user, None)