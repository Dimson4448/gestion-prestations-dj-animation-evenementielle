from django.db import migrations, models


def convert_planned_appointments(apps, schema_editor):
    appointment = apps.get_model("bookings", "PreparatoryAppointment")
    appointment.objects.filter(status="planned").update(status="accepted")


class Migration(migrations.Migration):
    dependencies = [("bookings", "0007_add_dj_quote_decision")]

    operations = [
        migrations.AddField(
            model_name="preparatoryappointment",
            name="response_message",
            field=models.TextField(blank=True, verbose_name="motif ou message de réponse"),
        ),
        migrations.AlterField(
            model_name="preparatoryappointment",
            name="status",
            field=models.CharField(
                choices=[
                    ("proposed", "Proposé au DJ"),
                    ("counter_proposed", "Contre-proposition du DJ"),
                    ("accepted", "Accepté par les deux parties"),
                    ("refused", "Refusé"),
                    ("done", "Réalisé"),
                    ("cancelled", "Annulé"),
                ],
                default="proposed",
                max_length=20,
                verbose_name="statut",
            ),
        ),
        migrations.RunPython(convert_planned_appointments, migrations.RunPython.noop),
    ]
