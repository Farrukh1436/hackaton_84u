from rest_framework import serializers
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.db import models
from accounts.models import CustomUser, MedicalRecord, GENDER_CHOICES, BLOOD_TYPE_CHOICES

class PersonalDataSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    name = serializers.CharField()
    surname = serializers.CharField()
    age = serializers.IntegerField()
    gender = serializers.ChoiceField(choices=GENDER_CHOICES)
    passport = serializers.CharField()



class MedicalDataSerializer(serializers.Serializer):
    blood_type = serializers.ChoiceField(choices=BLOOD_TYPE_CHOICES)
    allergies = serializers.CharField()
    illness = serializers.CharField()
    additional_info = serializers.CharField(required=False, allow_blank=True)





class CustomLoginSerializer(serializers.Serializer):
    identifier = serializers.CharField()  # can be email or passport
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        identifier = data.get("identifier")
        password = data.get("password")

        try:
            user_obj = CustomUser.objects.get(
                models.Q(email=identifier) | models.Q(passport_series=identifier)
            )
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("User not found")

        # Check if user is active
        if not user_obj.is_active:
            raise serializers.ValidationError("User account is disabled")

        # Debug: Print credentials being used for authentication
        print(f"Attempting auth with email: {user_obj.email}, password: {password}")

        user = authenticate(
            request=self.context.get('request'),
            username=user_obj.email,  # Ensure this matches USERNAME_FIELD
            password=password
        )

        if not user:
            # Verify password manually for debugging
            if not user_obj.check_password(password):
                print("Password check failed!")
            raise serializers.ValidationError("Invalid password or authentication failure")

        # Generate JWT token
        refresh = RefreshToken.for_user(user)

        # Build user_data
        user_data = {
            "name": user.first_name,
            "surname": user.last_name,
            "phone": getattr(user, "phone", ""),
            "email": user.email,
            "age": user.age,
            "gender": user.gender,
            "passport": user.passport_series,
        }

        try:
            medical = user.medical_record
            user_data.update({
                "blood_type": medical.blood_type,
                "allergies": medical.allergies,
                "illness": medical.ongoing_illness,
                "additional_info": medical.additional_info,
            })
        except MedicalRecord.DoesNotExist:
            pass

        return {
            "success": True,
            "token": str(refresh.access_token),
            "message": "Login successful",
            "user_data": user_data,
        }
class RegisterSerializer(serializers.Serializer):
    personal = PersonalDataSerializer()
    medical = MedicalDataSerializer()

    def create(self, validated_data):
        personal = validated_data['personal']
        medical = validated_data['medical']

        password = personal.pop('password')

        user = CustomUser.objects.create_user(
            email=personal['email'],
            first_name=personal['name'],
            last_name=personal['surname'],
            age=personal['age'],
            gender=personal['gender'],
            passport_series=personal['passport'],
            password=password
        )

        MedicalRecord.objects.create(
            user=user,
            blood_type=medical['blood_type'],
            allergies=medical['allergies'],
            ongoing_illness=medical['illness'],
            additional_info=medical.get('additional_info', '')
        )

        return user
