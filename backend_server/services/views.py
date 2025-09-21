import random
from rest_framework import status
from django.core.mail import send_mail
from services.serializers import OTPVerifySerializer,OTPRequestSerializer
from services.models import EmailOTP
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework_simplejwt.authentication import JWTAuthentication


class HelloWorldView(APIView):
    def get(self, request):
        return Response({"message": "Hello, it is working fine!"})


class OTPRequestView(APIView):
    def post(self, request):
        serializer = OTPRequestSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            code = str(random.randint(1000, 9999))

            EmailOTP.objects.filter(email=email).delete()
            EmailOTP.objects.create(email=email, code=code)

            send_mail(
                'Your OTP Code',
                f'Your OTP code is: {code}',
                'your_email@gmail.com',
                [email],
                fail_silently=False,
            )

            return Response({'success': True,
                'message': 'OTP sent successfully'}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OTPVerifyView(APIView):
    def post(self, request):
        serializer = OTPVerifySerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            code = serializer.validated_data['code']
            try:
                otp_entry = EmailOTP.objects.get(email=email, code=code)
                if otp_entry.is_expired():
                    otp_entry.delete()
                    return Response({'success': False,
                        'message': 'OTP expired'}, status=status.HTTP_400_BAD_REQUEST)

                otp_entry.delete()  # One-time use
                return Response({ 'success': True,
                    'registration_token': f'reg_token_{otp_entry.created_at.strftime("%Y%m%d%H%M%S")}_{otp_entry.email}'},
                                status=status.HTTP_200_OK)
            except EmailOTP.DoesNotExist:
                return Response({'success': False,
                    'message': 'Invalid OTP'}, status=status.HTTP_400_BAD_REQUEST)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)