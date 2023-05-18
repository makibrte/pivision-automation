from django.shortcuts import render
from django.contrib.auth import logout
from django.http import HttpResponse
from django.http import JsonResponse
from django.shortcuts import render
from django.conf import settings
import os
import csv
import pandas as pd
from django.http import HttpResponseRedirect
from django.contrib.auth.decorators import login_required


@login_required
def index(request):
    csv_file_path = os.path.join(settings.BASE_DIR, 'meters/data', 'akers_hall_0326W1.csv')

    
    df = pd.read_csv(csv_file_path)
    last_date = df.iloc[-1]['Timestamp'][:19]
    return render(request, 'meters/index.html', {'last_date':last_date})

def user_logout(request):
    logout(request)
    return HttpResponseRedirect('/accounts/login')

def button_clicked(request):
    response_data = {'message': 'Data updated'}
    return JsonResponse(response_data)
