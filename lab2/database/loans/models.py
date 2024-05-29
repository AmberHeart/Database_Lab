from django.db import models
from django.core.validators import MinValueValidator
from users.models import BankUser
from branch.models import BankBranch
from datetime import datetime, timedelta

class Loans(models.Model):
    apply_status_choices = [
        ('未审批', '未审批'),
        ('批准', '批准'),
        ('拒绝', '拒绝'),
    ]

    loan_status_choices = [
        ('未还清', '未还清'),
        ('已还清', '已还清'),
    ]

    loan_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(BankUser, on_delete=models.CASCADE, related_name='UserLoans')
    branch = models.ForeignKey(BankBranch, on_delete=models.CASCADE, related_name='BranchLoans')
    money = models.FloatField(default=0.0, validators=[MinValueValidator(0.0)])
    remain_money = models.FloatField(default=0.0, validators=[MinValueValidator(0.0)])
    loan_date = models.DateTimeField(auto_now_add=True)
    due_date = models.DateTimeField(default=datetime.now() + timedelta(days=365))
    apply_status = models.CharField(max_length=10, choices=apply_status_choices, default='未审批')
    status = models.CharField(max_length=10, choices=loan_status_choices, default='未还清')

    def __str__(self):
        return f"贷款号{self.loan_id}-{self.user.name}"
