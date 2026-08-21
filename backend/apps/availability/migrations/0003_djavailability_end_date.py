from django.db import migrations, models
from django.db.models import F, Q


class Migration(migrations.Migration):
    dependencies = [("availability", "0002_alter_djavailability_options_and_more")]

    operations = [
        migrations.RemoveConstraint(model_name="djavailability", name="availability_end_after_start"),
        migrations.AddField(model_name="djavailability", name="end_date", field=models.DateField(blank=True, null=True, verbose_name="date de fin")),
        migrations.RunSQL("UPDATE dj_availabilities SET end_date = available_date WHERE end_date IS NULL", migrations.RunSQL.noop),
        migrations.AddConstraint(
            model_name="djavailability",
            constraint=models.CheckConstraint(
                condition=Q(end_date__gt=F("available_date")) | Q(end_date=F("available_date"), end_time__gt=F("start_time")) | Q(end_date__isnull=True, end_time__gt=F("start_time")),
                name="availability_end_after_start",
            ),
        ),
    ]
