# Generated by Django 4.2.1 on 2023-05-27 07:55

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('users', '0009_bankuser_branch'),
    ]

    operations = [
        migrations.CreateModel(
            name='UserAccounts',
            fields=[
                ('account_id', models.AutoField(primary_key=True, serialize=False)),
                ('money', models.IntegerField(default=0)),
                ('branch', models.CharField(max_length=20)),
                ('create_date', models.DateTimeField(auto_now_add=True)),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='UserAccounts', to='users.bankuser')),
            ],
        ),
    ]