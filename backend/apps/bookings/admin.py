from django.contrib import admin

from .models import Booking, Playlist, PlaylistSong, Quote, Venue


admin.site.register(Venue)
admin.site.register(Quote)
admin.site.register(Booking)
admin.site.register(Playlist)
admin.site.register(PlaylistSong)
