# Generated by Django 5.0.6 on 2024-05-28 14:02

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('loans', '0003_loans_remain_money_alter_loans_due_date'),
    ]

    operations = [
        migrations.AlterField(
            model_name='loans',
            name='due_date',
            field=models.DateTimeField(default=datetime.datetime(2025, 5, 28, 22, 2, 49, 150681)),
        ),
    ]