from django.urls import path, include
from . import views

app_name = 'loans'

urlpatterns = [
    path('apply_loan/<int:user_id>/', views.apply_loan, name="apply_loan"),
    path('loans/<int:user_id>/', views.loans, name="loans"),
    path('delete_loan/<int:loan_id>/', views.delete_loan, name="delete_loan"),
    path('pay_loan/<int:loan_id>/', views.pay_loan, name="pay_loan"),
    path('branch_loans/', views.branch_loans, name='branch_loans'),
    path('approve_loan/<int:loan_id>/', views.approve_loan, name='approve_loan'),
    path('edit_loan/<int:loan_id>/', views.edit_loan, name='edit_loan'),
]
