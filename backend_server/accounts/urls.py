from django.urls import path

from accounts.views import RegisterAPIView,CustomLoginView

urlpatterns = [
    path('register/', view=RegisterAPIView.as_view(), name='register'),
    path('login/', CustomLoginView.as_view(), name='login'),
]
