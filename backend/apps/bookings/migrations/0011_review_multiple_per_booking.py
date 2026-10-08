import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("bookings", "0010_playlist_public_catalogue"),
    ]

    operations = [
        migrations.AlterField(
            model_name="review",
            name="booking",
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="reviews", to="bookings.booking", verbose_name="réservation"),
        ),
    ]
