from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.core.paginator import Paginator
from django.contrib.auth.decorators import login_required
from .models import Loans
from .forms import LoanForm, PayForm, EditForm
from users.models import BankUser
from branch.models import BankBranch
from accounts.models import UserAccounts
from bills.models import AccountBills
from datetime import datetime, timedelta
from django.utils import timezone

@login_required
def apply_loan(request, user_id):
    user = BankUser.objects.get(user_id=user_id)
    if request.user.id != user_id:
        messages.warning(request, '无法为他人创建账户')
        return render(request, 'frontend/error.html')
    branch = BankBranch.objects.get(name=user.branch_id)
    if request.method != 'POST':
        form = LoanForm(initial={'user': user, 'branch': branch})
    else:
        form = LoanForm(initial={'user': user, 'branch': branch}, data=request.POST)
        if form.is_valid():
            money = form.cleaned_data.get("money")
            due_date = form.cleaned_data.get("due_date")
            
            # Check if due_date is at least one month from now
            now = timezone.now()
            if due_date <= now + timedelta(days=30):
                messages.warning(request, '还款期限必须至少比申请时间长1个月')
                return render(request, 'frontend/error.html')
            else:
                loan = Loans.objects.create(user=user, branch=branch, money=money, remain_money=money, due_date=due_date)
                loan.save()
                user.status = False
                user.save()
                return redirect('loans:loans', user_id=user_id)
    context = {'form': form}
    return render(request, 'loans/apply_loan.html', context)


@login_required
def delete_loan(request, loan_id):
    loan = Loans.objects.get(loan_id=loan_id)
    user = BankUser.objects.get(id=loan.user_id)
    if request.user.is_superuser:
        loan.delete()
        messages.success(request, '贷款已删除')
        return redirect('loans:branch_loans')
    elif request.user.is_staff:
        if request.user.branch_id == loan.branch.branch_id:
            loan.delete()
            messages.success(request, '贷款已删除')
            return redirect('loans:branch_loans')
        else:
            messages.warning(request, '无权删除此贷款')
            return render(request, 'frontend/error.html')
    else:
        if request.user.id != user.user_id:
            messages.warning(request, '无法删除他人贷款')
            return render(request, 'frontend/error.html')
        if loan.apply_status == '未审批':
            loan.delete()
            messages.success(request, '贷款已删除')
            return redirect('loans:loans', user_id=user.user_id)
        elif loan.status == '未还清':
            messages.warning(request, '贷款未还清，无法删除')
            return redirect('loans:loans', user_id=user.user_id)
        if loan.status == '已还清':
            loan.delete()
            messages.success(request, '贷款已删除')
            return redirect('loans:loans', user_id=user.user_id)
        


@login_required
def pay_loan(request, loan_id):
    loan = Loans.objects.get(loan_id=loan_id)
    user = BankUser.objects.get(id=loan.user_id)
    branch = BankBranch.objects.get(name=user.branch_id)
    if request.user.id != user.user_id:
        messages.warning(request, '无法为他人还款')
        return render(request, 'frontend/error.html')
    if request.method != 'POST':
        form = PayForm(initial={'loan': loan, 'user': user, 'branch': branch})
    else:
        form = PayForm(initial={'loan': loan, 'user': user, 'branch': branch}, data=request.POST)
        if form.is_valid():
            money = form.cleaned_data.get("money")
            account = form.cleaned_data.get("account")
            if account.money < money:
                messages.warning(request, '账户余额不足')
                return render(request, 'frontend/error.html')
            loan.remain_money -= money
            if loan.remain_money < 0:
                messages.warning(request, '还款金额超过贷款金额')
                return render(request, 'frontend/error.html')
            if loan.remain_money == 0:
                loan.status = '已还清'
            loan.save()
            account.money -= money
            account.save()
            remark = "还款" + str(loan.loan_id) + "号贷款"
            bill = AccountBills.objects.create(account=account, changes=-money, type='支出', remark=remark, money=account.money)
            bill.save()
            return redirect('loans:loans', user_id=user.user_id)
    context = {'form': form, 'loan': loan}
    return render(request, 'loans/pay_loan.html', context)

@login_required
def loans(request, user_id):
    user = BankUser.objects.get(user_id=user_id)
    if request.user.id != user_id:
        messages.warning(request, '无法查看他人贷款信息')
        return render(request, 'frontend/error.html')
    loans_lists = Loans.objects.filter(user_id=user.id)
    paginator = Paginator(loans_lists, 4)
    page = request.GET.get('page')
    loans_list = paginator.get_page(page)
    context = {'loans': loans_list, 'loan_user': user}
    return render(request, 'loans/loans.html', context)

@login_required
def branch_loans(request):
    if request.user.is_staff or request.user.is_superuser:
        if request.user.is_superuser and request.user.username == 'admin':
            loans_lists = Loans.objects.all()
        elif request.user.is_superuser:
            loans_lists = Loans.objects.filter(branch=request.user.username)
        else:
            loans_lists = Loans.objects.filter(branch=request.user.branch)
        paginator = Paginator(loans_lists, 4)
        page = request.GET.get('page')
        loans_page = paginator.get_page(page)
        context = {'loans': loans_page}
        return render(request, 'loans/branch_loans.html', context)
    else:
        messages.warning(request, '无法查看信息')
        return render(request, 'frontend/error.html')

@login_required
def approve_loan(request, loan_id):
    loan = Loans.objects.get(loan_id=loan_id)
    if request.user.is_staff or request.user.is_superuser:
        if request.method == 'POST':
            apply_status = request.POST.get('apply_status')
            if apply_status in ['批准', '拒绝']:
                loan.apply_status = apply_status
                loan.save()
                messages.success(request, '贷款审批成功')
                return redirect('loans:branch_loans')
            else:
                messages.warning(request, '无效的审批状态')
        return render(request, 'loans/approve_loan.html', {'loan': loan})
    else:
        messages.warning(request, '无权限审批贷款')
        return render(request, 'frontend/error.html')

@login_required
def edit_loan(request, loan_id):
    loan = get_object_or_404(Loans, loan_id=loan_id)
    
    if not request.user.is_superuser and request.user.branch_id != loan.branch.branch_id:
        messages.warning(request, '无权编辑此贷款信息')
        return redirect('loans:branch_loans')

    if request.method == 'POST':
        form = EditForm(request.POST, instance=loan)
        if form.is_valid():
            form.save()
            messages.success(request, '贷款信息已更新')
            return redirect('loans:branch_loans')
    else:
        form = EditForm(instance=loan)

    context = {
        'form': form,
        'loan': loan
    }
    return render(request, 'loans/edit_loan.html', context)