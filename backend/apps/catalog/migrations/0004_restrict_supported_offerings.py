from django.db import migrations


ALLOWED_EVENT_TYPES = (
    ("Anniversaire enfant", False),
    ("Anniversaire adulte", False),
    ("Mariage", True),
    ("Soirée privée", False),
)

OUT_OF_SCOPE_PACKAGES = ("Entreprise", "Festival local", "Étudiant", "Lounge")


def restrict_supported_offerings(apps, schema_editor):
    EventType = apps.get_model("catalog", "EventType")
    Package = apps.get_model("catalog", "Package")

    for name, requires_meeting in ALLOWED_EVENT_TYPES:
        EventType.objects.update_or_create(
            name=name,
            defaults={"requires_preparatory_meeting": requires_meeting},
        )

    Package.objects.filter(name__in=OUT_OF_SCOPE_PACKAGES).update(is_active=False)


class Migration(migrations.Migration):
    dependencies = [
        ("catalog", "0003_distinguish_adult_and_child_birthdays"),
    ]

    operations = [
        migrations.RunPython(restrict_supported_offerings, migrations.RunPython.noop),
    ]
