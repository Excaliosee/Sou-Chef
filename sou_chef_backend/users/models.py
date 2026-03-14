from django.db import models
from django.conf import settings

class Follow(models.Model):
    users_from = models.ForeignKey(settings.AUTH_USER_MODEL, related_name="rel_from_set", on_delete=models.CASCADE)
    users_to = models.ForeignKey(settings.AUTH_USER_MODEL, related_name="rel_to_set", on_delete=models.CASCADE)
    created = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [models.UniqueConstraint(fields=['users_from', 'users_to'], name = 'unique_followers')]
        ordering = ('-created',)

    def __str__(self):
        return f'{self.users_from} follows {self.users_to}'
