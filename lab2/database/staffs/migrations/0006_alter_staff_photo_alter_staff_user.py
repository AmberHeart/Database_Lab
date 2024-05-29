# Generated by Django 5.0.6 on 2024-05-29 08:05

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('staffs', '0005_staff_user'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AlterField(
            model_name='staff',
            name='photo',
            field=models.ImageField(default='photos/default.jpg', upload_to='photos/%Y%m%d/'),
        ),
        migrations.AlterField(
            model_name='staff',
            name='user',
            field=models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL),
        ),
    ]
