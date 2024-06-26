from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect
from .forms import AccountBillsForm
from .models import AccountBills
from accounts.models import UserAccounts
from django.core.paginator import Paginator
from django.contrib import messages
from users.models import BankUser
from django.db import transaction


@login_required
def create_bill(request, account_id):
    account = UserAccounts.objects.get(account_id=account_id)
    user_id = BankUser.objects.get(id=account.user_id).user_id
    if request.user.id != user_id:
        messages.warning(request, '无法为他人账户创建账单')
        return render(request, 'frontend/error.html')
    
    if request.method != 'POST':
        form = AccountBillsForm(initial={'account': account})
    else:
        form = AccountBillsForm(initial={'account': account}, data=request.POST)
        if form.is_valid():
            changes = form.cleaned_data.get("changes")
            bill_type = form.cleaned_data.get("type")
            
            # 验证账单类型和金额
            if bill_type == '收入' and changes <= 0:
                messages.warning(request, '收入类型的账单金额必须大于0')
            elif bill_type == '支出' and changes >= 0:
                messages.warning(request, '支出类型的账单金额必须小于0')
            else:
                old_money = account.money
                new_money = old_money + changes
                if new_money < 0:
                    messages.warning(request, '余额不足')
                    return render(request, 'frontend/error.html')
                
                try:
                    with transaction.atomic():
                        bill = AccountBills.objects.create(
                            account=account, changes=changes,
                            type=bill_type, remark=form.cleaned_data.get("remark"), money=new_money
                        )
                        bill.save()
                        account.money = new_money
                        account.save()
                    return redirect('bills:bills', account_id=account.account_id)
                except Exception as e:
                    messages.error(request, f'操作失败: {str(e)}')
                    return render(request, 'frontend/error.html')
    
    context = {'form': form, 'account': account}
    return render(request, 'bills/create_bill.html', context)


@login_required
def bills(request, account_id):
    account = UserAccounts.objects.get(account_id=account_id)
    user_id = BankUser.objects.get(id=account.user_id).user_id
    if request.user.id != user_id:
        messages.warning(request, '无法查看他人账单')
        return render(request, 'frontend/error.html')
    bills_lists = AccountBills.objects.filter(account_id=account_id)
    paginator = Paginator(bills_lists, 4)
    page = request.GET.get('page')
    bills_list = paginator.get_page(page)
    context = {'bills': bills_list, 'account': account}
    return render(request, 'bills/bills.html', context)
