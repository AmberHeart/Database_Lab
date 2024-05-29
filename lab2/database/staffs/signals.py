from django.db.models.signals import post_save, post_delete, pre_save
from django.contrib.auth.models import User, Group
from django.dispatch import receiver
from .models import Staff

@receiver(post_save, sender=Staff)
def create_staff_user(sender, instance, created, **kwargs):
    if created and not instance.user:
        # 创建用户账号
        user = User.objects.create_user(
            username=f"staff_{instance.staff_id}",
            password='staff123'
        )
        # 设置为员工账户
        user.is_staff = True
        user.is_active = True
        user.save()
        
        instance.user = user
        instance.save()

@receiver(post_delete, sender=Staff)
def delete_staff_user(sender, instance, **kwargs):
    if instance.user:
        instance.user.delete()