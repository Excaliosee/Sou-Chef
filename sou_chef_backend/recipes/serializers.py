from rest_framework import serializers
from .models import Recipe, Ingredient, RecipeIngredient, RecipeStep
from django.db import transaction

class RecipeStepSerializer(serializers.ModelSerializer):
    class Meta:
        model = RecipeStep
        fields = ["step_number", "instruction"]

class RecipeIngredientSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source="ingredient.name")
    class Meta:
        model = RecipeIngredient
        fields = ["name", "quantity"]

class RecipeSerializer(serializers.ModelSerializer):
    ingredients = RecipeIngredientSerializer(many=True)
    steps = RecipeStepSerializer(many=True)
    created_by = serializers.ReadOnlyField(source = "created_by.email")

    class Meta:
        model = Recipe
        fields = ["id", "title", "description", "prep_time", "cook_time", "ingredients", "steps", "created_at", "created_by"]
        read_only_fields = ["created_by", "created_at"]

    def create(self, validated_data):
        ingredients_data = validated_data.pop("ingredients")
        steps_data = validated_data.pop("steps")

        with transaction.atomic():
            recipe = Recipe.objects.create(**validated_data)

            for item in ingredients_data:
                ingredient_name = item["ingredient"]["name"]
                quantity = item["quantity"]

                ingredient_name = ingredient_name.strip()

                ingredient_obj, _ = Ingredient.objects.get_or_create(name__iexact=ingredient_name, defaults={"name": ingredient_name})

                RecipeIngredient.objects.create(recipe=recipe, ingredient=ingredient_obj, quantity=quantity)

            for step in steps_data:
                RecipeStep.objects.create(recipe=recipe, **step)
                
            return recipe
        
    def update(self, instance, validated_data):
        ingredients_data = validated_data.pop("ingredients", None)
        steps_data = validated_data.pop("steps", None)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        instance.save()

        if ingredients_data is not None:
            instance.ingredients.all().delete()

            for item in ingredients_data:
                ingredient_name = item["ingredient"]["name"]
                quantity = item["quantity"]

                ingredient_name = ingredient_name.strip()

                ingredient_obj, _ = Ingredient.objects.get_or_create(
                    name__iexact=ingredient_name, defaults={"name": ingredient_name}
                )

                RecipeIngredient.objects.create(recipe=instance, ingredient=ingredient_obj, quantity=quantity)
            
        if steps_data is not None:
            instance.steps.all().delete()
            for step in steps_data:
                RecipeStep.objects.create(recipe=instance, **step)
        
        return instance