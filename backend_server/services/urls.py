from django.urls import path
from services.views import HelloWorldView,OTPVerifyView,OTPRequestView

urlpatterns = [
    path('hello/', view=HelloWorldView.as_view(), name='hello'),
    path('auth/request-otp/', OTPRequestView.as_view()),
    path('auth/verify-otp/', OTPVerifyView.as_view()),
]
