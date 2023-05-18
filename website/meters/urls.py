from django.urls import path

from . import views

urlpatterns = [
    path("", views.index, name="index"),
    path('button_clicked/', views.button_clicked, name='button_clicked'),
    path('logout/', views.user_logout, name='logout'),
]