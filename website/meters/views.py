from django.shortcuts import render
from django.contrib.auth import logout
from django.http import HttpResponse
from django.http import JsonResponse
from django.shortcuts import render
from django.conf import settings
import os
import csv
from datetime import date
import pandas as pd
from django.http import HttpResponseRedirect
from django.contrib.auth.decorators import login_required
from .scripts.weekly_update import main as weekly_update
from .scripts.init_data import main as init_data



@login_required
def index(request):
    csv_file_path = os.path.join(settings.BASE_DIR, 'meters/data', 'flow_meters.csv')

    
    df = pd.read_csv(csv_file_path)
    last_date = df.iloc[-1]['date']
    return render(request, 'meters/index.html', {'last_date':last_date})
@login_required
def weekly_update_run(request):
    weekly_update(start = date(2020,1,1))
    return JsonResponse({'message': 'Data updated'})
@login_required
def init_data_run(request):
    init_data()
    return JsonResponse({'message': 'Data initial download succesfull.'})
def user_logout(request):
    logout(request)
    return HttpResponseRedirect('/accounts/login')

def button_clicked(request):
    response_data = {'message': 'Data updated'}
    return JsonResponse(response_data)
