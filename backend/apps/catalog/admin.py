from django.contrib import admin

from .models import EventType, MusicStyle, Package, ServiceOption


admin.site.register(EventType)
admin.site.register(MusicStyle)
admin.site.register(Package)
admin.site.register(ServiceOption)
