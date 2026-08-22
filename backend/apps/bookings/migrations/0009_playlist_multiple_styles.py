from django.db import migrations, models


def copy_main_style_to_styles(apps, schema_editor):
    playlist = apps.get_model("bookings", "Playlist")
    through = playlist.styles.through
    through.objects.bulk_create(
        [through(playlist_id=item.pk, musicstyle_id=item.main_style_id) for item in playlist.objects.all()],
        ignore_conflicts=True,
    )


class Migration(migrations.Migration):
    dependencies = [("bookings", "0008_appointment_negotiation")]

    operations = [
        migrations.AddField(
            model_name="playlist",
            name="styles",
            field=models.ManyToManyField(
                related_name="playlists",
                to="catalog.musicstyle",
                verbose_name="styles musicaux",
            ),
        ),
        migrations.RunPython(copy_main_style_to_styles, migrations.RunPython.noop),
    ]
