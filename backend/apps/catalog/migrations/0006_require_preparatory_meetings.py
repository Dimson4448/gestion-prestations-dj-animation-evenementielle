from django.db import migrations, models


SUPPORTED_EVENT_TYPES = (
    "Anniversaire enfant",
    "Anniversaire adulte",
    "Mariage",
    "Soirée privée",
)


def require_meetings_for_supported_events(apps, schema_editor):
    event_type = apps.get_model("catalog", "EventType")
    event_type.objects.filter(name__in=SUPPORTED_EVENT_TYPES).update(
        requires_preparatory_meeting=True,
    )


class Migration(migrations.Migration):
    dependencies = [("catalog", "0005_package_event_types")]

    operations = [
        migrations.RunPython(
            require_meetings_for_supported_events,
            migrations.RunPython.noop,
        ),
        migrations.AlterField(
            model_name="eventtype",
            name="requires_preparatory_meeting",
            field=models.BooleanField(
                default=True,
                verbose_name="rendez-vous préparatoire requis",
            ),
        ),
    ]
