# Generated by Django 5.0.6 on 2024-05-29 07:10

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('loans', '0005_loans_apply_status_alter_loans_due_date_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='loans',
            name='due_date',
            field=models.DateTimeField(default=datetime.datetime(2025, 5, 29, 15, 10, 58, 979538)),
        ),
    ]
