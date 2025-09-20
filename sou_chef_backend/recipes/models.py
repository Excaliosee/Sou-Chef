from django.db import models

class Recipe(models.Model):
    title = models.CharField(max_length=50)
    description = models.TextField()
    ingredients = models.TextField(help_text="Separate ingredients by new line.")
    instructions = models.TextField()
    prep_time = models.IntegerField(help_text="Add in minutes.")
    cook_time = models.IntegerField(help_text="Add in minutes.")

    created_by = models.CharField(max_length=128)
    created_at = models.DateTimeField(auto_now_add=True)


    def __str__(self):
        return self.title