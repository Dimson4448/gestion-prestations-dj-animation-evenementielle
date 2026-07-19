from django.db import migrations


def distinguish_birthdays(apps, schema_editor):
    EventType = apps.get_model("catalog", "EventType")
    EventType.objects.filter(name="Anniversaire").update(name="Anniversaire adulte")
    EventType.objects.get_or_create(
        name="Anniversaire enfant",
        defaults={"requires_preparatory_meeting": False},
    )


def merge_birthdays(apps, schema_editor):
    EventType = apps.get_model("catalog", "EventType")
    EventType.objects.filter(name="Anniversaire enfant").delete()
    EventType.objects.filter(name="Anniversaire adulte").update(name="Anniversaire")


class Migration(migrations.Migration):
    dependencies = [
        ("catalog", "0002_equipment_alter_eventtype_options_and_more"),
    ]

    operations = [
        migrations.RunPython(distinguish_birthdays, merge_birthdays),
    ]
