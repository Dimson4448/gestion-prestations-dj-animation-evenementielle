from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [("bookings", "0009_playlist_multiple_styles")]

    operations = [
        migrations.AddField(
            model_name="playlist",
            name="is_public",
            field=models.BooleanField(default=True, verbose_name="visible dans le catalogue public"),
        ),
    ]
