from django.db import migrations, models


MARRIAGE_PACKAGES = ("Mariage Silver", "Mariage Gold")


def assign_compatible_event_types(apps, schema_editor):
    EventType = apps.get_model("catalog", "EventType")
    Package = apps.get_model("catalog", "Package")
    allowed_event_types = EventType.objects.filter(
        name__in=(
            "Anniversaire enfant",
            "Anniversaire adulte",
            "Mariage",
            "Soirée privée",
        )
    )
    marriage = allowed_event_types.filter(name="Mariage")

    for package in Package.objects.filter(is_active=True):
        package.event_types.set(
            marriage if package.name in MARRIAGE_PACKAGES else allowed_event_types
        )


def clear_compatible_event_types(apps, schema_editor):
    Package = apps.get_model("catalog", "Package")
    for package in Package.objects.all():
        package.event_types.clear()


class Migration(migrations.Migration):
    dependencies = [
        ("catalog", "0004_restrict_supported_offerings"),
    ]

    operations = [
        migrations.AddField(
            model_name="package",
            name="event_types",
            field=models.ManyToManyField(
                related_name="packages",
                to="catalog.eventtype",
                verbose_name="prestations compatibles",
            ),
        ),
        migrations.RunPython(assign_compatible_event_types, clear_compatible_event_types),
    ]
