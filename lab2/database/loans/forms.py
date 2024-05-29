from django import forms
from .models import Loans
from branch.models import BankBranch
from users.models import BankUser
from accounts.models import UserAccounts
from django.core.exceptions import ValidationError
from datetime import timedelta, datetime

class LoanForm(forms.ModelForm):
    user = forms.ModelChoiceField(label='客户信息', queryset=BankUser.objects.all(), disabled=True)
    branch = forms.ModelChoiceField(label='所属分行', queryset=BankBranch.objects.all(), disabled=True)
    money = forms.FloatField(label='借贷金额', min_value=0.0)
    due_date = forms.DateTimeField(label='还款期限')

    class Meta:
        model = Loans
        fields = ('user', 'branch', 'money', 'due_date')
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['due_date'].initial = datetime.now() + timedelta(days=30)

class PayForm(forms.ModelForm):
    loan = forms.ModelChoiceField(label='贷款信息', queryset=Loans.objects.all(), disabled=True)
    user = forms.ModelChoiceField(label='客户信息', queryset=BankUser.objects.all(), disabled=True)
    branch = forms.ModelChoiceField(label='所属分行', queryset=BankBranch.objects.all(), disabled=True)
    account = forms.ModelChoiceField(label='账户信息', queryset=UserAccounts.objects.none())
    money = forms.FloatField(label='还款金额', min_value=0.0)

    class Meta:
        model = Loans
        fields = ('loan', 'user', 'branch', 'account', 'money')

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        user = kwargs['initial']['user']
        self.fields['account'].queryset = UserAccounts.objects.filter(user_id=user.id)

class EditForm(forms.ModelForm):
    class Meta:
        model = Loans
        fields = ['money', 'remain_money', 'due_date', 'apply_status', 'status']
        widgets = {
            'apply_status': forms.Select(choices=[('未审批', '未审批'), ('批准', '批准'), ('拒绝', '拒绝')]),
            'status': forms.Select(choices=[('未还清', '未还清'), ('已还清', '已还清')]),
        }

        def __init__(self, *args, **kwargs):
            super().__init__(*args, **kwargs)
            # 格式化日期时间字段以适应datetime-local输入类型
            if self.instance and self.instance.pk:
                self.fields['due_date'].initial = self.instance.due_date.strftime('%Y-%m-%dT%H:%M:%S')