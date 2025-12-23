from django.contrib import admin
from .models import Recipe, Ingredient, RecipeIngredient, RecipeStep

class RecipeIngredientInline(admin.TabularInline):
    model = RecipeIngredient
    extra = 1

class RecipeStepInLine(admin.TabularInline):
    model = RecipeStep
    extra = 1

@admin.register(Recipe)
class RecipeAdmin(admin.ModelAdmin):
    list_display = ('title', 'created_by', 'prep_time', 'cook_time', 'created_at')
    inlines = [RecipeIngredientInline, RecipeStepInLine]

@admin.register(Ingredient)
class IngredientAdmin(admin.ModelAdmin):
    list_display = ('name',)
