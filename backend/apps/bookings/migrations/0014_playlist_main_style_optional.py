from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [("bookings", "0013_review_moderation")]

    operations = [
        migrations.AlterField(
            model_name="playlist",
            name="main_style",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=models.PROTECT,
                to="catalog.musicstyle",
                verbose_name="style principal",
            ),
        ),
    ]
