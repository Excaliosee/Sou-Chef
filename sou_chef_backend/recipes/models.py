from django.db import models
from django.contrib.auth.models import User
from django.conf import settings

class Ingredient(models.Model):
    name = models.CharField(max_length=100, unique=True)
    def __str__(self):
        return self.name
    
class Recipe(models.Model):
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='recipes')

    title = models.CharField(max_length=100)
    description = models.TextField()

    prep_time = models.PositiveBigIntegerField()
    cook_time = models.PositiveBigIntegerField()

    created_at = models.DateTimeField(auto_now_add=True)
    likes = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name="liked_recipes", blank=True)

    image = models.ImageField(upload_to="recipe_images/", null=True, blank=True)

    def __str__(self): 
        return self.title
    
class RecipeIngredient(models.Model):
    recipe = models.ForeignKey(Recipe, on_delete=models.CASCADE, related_name="ingredients")
    ingredient = models.ForeignKey(Ingredient, on_delete=models.CASCADE)
    quantity = models.CharField(max_length=50)

    class Meta:
        unique_together = ("recipe", "ingredient")

class RecipeStep(models.Model):
    recipe = models.ForeignKey(Recipe, on_delete=models.CASCADE, related_name="steps")
    step_number = models.PositiveBigIntegerField()
    instruction = models.TextField()

    class Meta:
        ordering = ['step_number']
        unique_together = ('recipe', 'step_number')