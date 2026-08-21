from django.db import migrations, models
from django.db.models import F, Q


class Migration(migrations.Migration):
    dependencies = [("bookings", "0005_cancellationrequest_review_message")]

    operations = [
        migrations.RemoveConstraint(model_name="booking", name="booking_end_after_start"),
        migrations.AddField(model_name="booking", name="end_date", field=models.DateField(blank=True, null=True, verbose_name="date de fin")),
        migrations.RunSQL("UPDATE bookings SET end_date = event_date WHERE end_date IS NULL", migrations.RunSQL.noop),
        migrations.AddConstraint(
            model_name="booking",
            constraint=models.CheckConstraint(
                condition=Q(end_date__gt=F("event_date")) | Q(end_date=F("event_date"), end_time__gt=F("start_time")) | Q(end_date__isnull=True, end_time__gt=F("start_time")),
                name="booking_end_after_start",
            ),
        ),
    ]
