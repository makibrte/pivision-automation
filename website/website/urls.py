from django.contrib import admin
from django.urls import include, path
from filebrowser.sites import site
from django.conf import settings
from django.conf.urls.static import static


urlpatterns = [
    path('admin/filebrowser/', site.urls),
    path("meters/", include("meters.urls")),
    path("admin/", admin.site.urls),
    path('accounts/', include('django.contrib.auth.urls')),
    
    path(r'filer/', include('filer.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)