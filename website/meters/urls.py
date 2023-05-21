from django.urls import path
from django.conf.urls import handler404
from .views import redirect_to_meters

from . import views

handler404 = 'meters.views.redirect_to_meters'
urlpatterns = [
    path("", views.index, name="index"),
    path('button_clicked/', views.button_clicked, name='button_clicked'),
    path('logout/', views.user_logout, name='logout'),
    path('run_weekly_script/', views.weekly_update_run, name='run_weekly_script'),
    path('run_init_script/', views.init_data_run, name='run_init_script'),
    path('download/', views.file_download, name='file_download'),

]