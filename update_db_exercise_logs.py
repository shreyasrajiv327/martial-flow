# save as: add_random_technique_logs.py
import firebase_admin
from firebase_admin import credentials, firestore
import json
import random
import datetime

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json")
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)
db = firestore.client()

# Load your exported techniques
with open("techniques_backup.json", "r", encoding="utf-8") as f:
    techniques_data = json.load(f)

# Flatten for easy access: {art: list of techniques}
techniques = {
    "taekwondo": techniques_data["taekwondo"],
    "karate": techniques_data["karate"]
}

users = {
    "reethu": "UaBFjNJ5vKP1K1PX8e4kCmdyDBY2",
    "shreyas": "fxGWV2MtaEW6QfIZZeGKPGU0gHx1"
}

start_date = datetime.date(2025, 10, 25)
end_date = datetime.date(2025, 11, 28)

notes_pool = [
    "Felt great today", "Smooth execution", "Working on speed", "Good snap!",
    "Height improving", "Strong hips", "Clean technique", "Tired but happy", ""
]

for username, uid in users.items():
    current = start_date
    while current <= end_date:
        date_str = current.strftime("%Y-%m-%d")

        # 25% chance to skip a day (realistic)
        if random.random() < 0.25:
            current += datetime.timedelta(days=1)
            continue

        # Choose ONE art for the day
        art = random.choice(["taekwondo", "karate"])
        available_techniques = techniques[art]

        # Pick 2–5 random techniques
        num_techs = random.randint(2, 5)
        selected = random.sample(available_techniques, num_techs)

        activities = []
        for tech in selected:
            sets = random.randint(3, 5)
            reps = [random.randint(10, 20) for _ in range(sets)]
            times = [random.randint(55, 95) for _ in range(sets)]

            activities.append({
                "type": "technique",
                "art": art,
                "id": tech["id"],
                "name": tech["name"],
                "sets_done": sets,
                "reps_done": reps,
                "time_sec": times,
                "timestamp": int(datetime.datetime.combine(current, datetime.time(18, random.randint(0,59))).timestamp() * 1000),
                "notes": random.choice(notes_pool) if random.random() < 0.6 else ""
            })

        # Save log
        db.collection("exercise_logs").add({
            "userId": uid,
            "date": date_str,
            "createdAt": firestore.SERVER_TIMESTAMP,
            "arts": [art],                     # only one art per day
            "activities": activities
        })

        print(f"{username.capitalize():8} | {date_str} | {art:10} | {len(activities)} techniques")

        current += datetime.timedelta(days=1)

print("\nAll done! Added beautiful random technique-only logs (one art per day).")