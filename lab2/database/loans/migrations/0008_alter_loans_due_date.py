# Generated by Django 5.0.6 on 2024-05-29 08:12

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('loans', '0007_alter_loans_due_date'),
    ]

    operations = [
        migrations.AlterField(
            model_name='loans',
            name='due_date',
            field=models.DateTimeField(default=datetime.datetime(2025, 5, 29, 16, 12, 11, 129925)),
        ),
    ]
