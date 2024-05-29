from django.shortcuts import render, redirect, get_object_or_404
from .models import Staff, Manager
from django.core.paginator import Paginator
from .forms import StaffEditForm, StaffCreateForm
from department.models import BranchDepartments
from django.contrib import messages
from django.contrib.auth.decorators import login_required


# Create your views here.
@login_required
def staffs(request):
    user = request.user

    if user.is_superuser:
        if user.username == 'admin':
            staffs_lists = Staff.objects.all()
        else:
            staffs_lists = Staff.objects.filter(department__branch_id=user.username)
    else:
        messages.warning(request, '你没有权限查看员工信息')
        return render(request, 'frontend/error.html')

    paginator = Paginator(staffs_lists, 4)
    page = request.GET.get('page')
    staffs_list = paginator.get_page(page)

    context = {'staffs': staffs_list}
    return render(request, 'staffs/staffs.html', context)

@login_required
def create_staff(request, department_id):
    name = None
    if request.user.is_superuser:
        name = request.user.username
    branch = BranchDepartments.objects.get(department_id=department_id).branch_id
    if not (name and name == branch or name == 'admin'):
        messages.warning(request, '你没有权限操作该部门')
        return render(request, 'frontend/error.html')
    # judge if user is superuser
    if not request.user.is_superuser:
        messages.warning(request, '你没有权限创建员工')
        return render(request, 'frontend/error.html')
    department = BranchDepartments.objects.get(department_id=department_id)
    if request.method != 'POST':
        form = StaffCreateForm(initial={'department': department})
    else:
        form = StaffCreateForm(initial={'department': department}, data=request.POST, files=request.FILES)
        if form.is_valid():
            name = form.cleaned_data.get("name")
            tel = form.cleaned_data.get("tel")
            address = form.cleaned_data.get("address")
            staff = Staff.objects.create(department=department, name=name, tel=tel, address=address)
            if 'photo' in request.FILES:
                staff.photo = form.cleaned_data.get("photo")
            staff.save()
            return redirect('staffs:staffs')
    context = {'form': form, 'department': department}
    return render(request, 'staffs/create_staff.html', context)

@login_required
def edit_staff(request, staff_id):
    staff = get_object_or_404(Staff, staff_id=staff_id)
    old_department = staff.department
    user = request.user

    if user.is_superuser:
        if user.username != 'admin' and staff.department.branch_id != user.username:
            messages.warning(request, '你没有权限修改该支行的员工信息')
            return render(request, 'frontend/error.html')
    else:
        messages.warning(request, '你没有权限修改员工信息')
        return render(request, 'frontend/error.html')

    if request.method != 'POST':
        form = StaffEditForm(instance=staff)
    else:
        form = StaffEditForm(instance=staff, data=request.POST, files=request.FILES)
        if form.is_valid():
            new_department = form.cleaned_data.get("department")
            if old_department != new_department:
                if user.username != 'admin' and old_department.branch_id != new_department.branch_id:
                    messages.warning(request, '你不能在不同支行之间调动员工')
                    return render(request, 'frontend/error.html')

            staff.department = new_department

            if old_department != new_department and Manager.objects.filter(department=old_department, staff=staff).exists():
                manager = Manager.objects.get(staff=staff, department=old_department)
                manager.delete()

            form.cleaned_data.get("name")
            staff.tel = form.cleaned_data.get("tel")
            staff.address = form.cleaned_data.get("address")
            if 'photo' in request.FILES:
                # if old photo is not default photo, then delete old photo
                if staff.photo and staff.photo.name != 'photos/default.jpg':
                    staff.photo.delete()
                staff.photo = form.cleaned_data.get("photo")
            staff.save()
            return redirect('staffs:staffs')

    context = {'form': form, 'staff': staff}
    return render(request, 'staffs/edit_staff.html', context)

@login_required
def delete_staff(request, staff_id):
    staff = get_object_or_404(Staff, staff_id=staff_id)
    user = request.user

    if user.is_superuser:
        if user.username != 'admin' and staff.department.branch_id != user.username:
            messages.warning(request, '你没有权限删除该支行的员工信息')
            return render(request, 'frontend/error.html')
    else:
        messages.warning(request, '你没有权限删除员工')
        return render(request, 'frontend/error.html')

    if Manager.objects.filter(staff=staff).exists():
        manager = Manager.objects.get(staff=staff)
        manager.delete()

    if staff.photo and staff.photo.name != 'photos/default.jpg':
        staff.photo.delete()

    staff.delete()
    return redirect('staffs:staffs')

@login_required
def set_manager(request, staff_id, department_id):
    name = None
    if request.user.is_superuser:
        name = request.user.username
    branch = BranchDepartments.objects.get(department_id=department_id).branch_id
    if not (name and name == branch or name == 'admin'):
        messages.warning(request, '你没有权限操作该部门')
        return render(request, 'frontend/error.html')
    # judge if user is superuser
    if not request.user.is_superuser:
        messages.warning(request, '你没有权限设置经理')
        return render(request, 'frontend/error.html')
    staff = Staff.objects.get(staff_id=staff_id)
    department = BranchDepartments.objects.get(department_id=department_id)

    if staff.department != department:
        messages.warning(request, '员工不在该部门, 不能设置为经理')
        return render(request, 'frontend/error.html')

    # if there is a manager in this department, delete it
    if Manager.objects.filter(department=department):
        manager = Manager.objects.get(department=department)
        manager.delete()
    # create a new manager
    manager = Manager.objects.create(department=department, staff=staff)
    manager.save()
    return redirect('departments:departments')

@login_required
def delete_manager(request, department_id):
    # judge if user is superuser
    if not request.user.is_superuser:
        messages.warning(request, '你没有权限删除经理')
        return render(request, 'frontend/error.html')
    department = BranchDepartments.objects.get(department_id=department_id)
    # if there is a manager in this department, delete it
    if Manager.objects.filter(department=department):
        manager = Manager.objects.get(department=department)
        manager.delete()
    return redirect('departments:departments')
