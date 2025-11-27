import firebase_admin
from firebase_admin import credentials, firestore
import datetime

# -------------------------
# INIT FIREBASE
# -------------------------
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# -------------------------
# FULL KARATE TECHNIQUES LIST
# -------------------------

techniques = [

    # ------------------------
    # STANCES
    # ------------------------
    {
        "id": "zenkutsu_dachi",
        "name": "Zenkutsu Dachi (Front Stance)",
        "category": "stance",
        "level": "white",
        "steps": ["Long stance", "Front knee bent", "Back leg straight"]
    },
    {
        "id": "kokutsu_dachi",
        "name": "Kokutsu Dachi (Back Stance)",
        "category": "stance",
        "level": "yellow",
        "steps": ["Weight shifted back", "Front foot light", "Knees bent"]
    },
    {
        "id": "kiba_dachi",
        "name": "Kiba Dachi (Horse Stance)",
        "category": "stance",
        "level": "white",
        "steps": ["Feet wide", "Knees bent outward", "Back straight"]
    },
    {
        "id": "neko_ashi_dachi",
        "name": "Neko Ashi Dachi (Cat Stance)",
        "category": "stance",
        "level": "green",
        "steps": ["80% weight on back leg", "Front foot light", "Heels aligned"]
    },
    {
        "id": "fudo_dachi",
        "name": "Fudo Dachi (Immovable Stance)",
        "category": "stance",
        "level": "blue",
        "steps": ["Stable stance", "Feet wide", "Hips square"]
    },

    # ------------------------
    # BLOCKS
    # ------------------------
    {
        "id": "gedan_barai",
        "name": "Gedan Barai (Downward Block)",
        "category": "block",
        "level": "white",
        "steps": ["Chamber high", "Sweep down", "Palm inward"]
    },
    {
        "id": "age_uke",
        "name": "Age Uke (Rising Block)",
        "category": "block",
        "level": "white",
        "steps": ["Lift arm upward", "Angle block", "Protect head"]
    },
    {
        "id": "soto_uke",
        "name": "Soto Uke (Outside Block)",
        "category": "block",
        "level": "yellow",
        "steps": ["Chamber to ear", "Sweep outward", "Forearm across body"]
    },
    {
        "id": "uchi_uke",
        "name": "Uchi Uke (Inside Block)",
        "category": "block",
        "level": "yellow",
        "steps": ["Start from outside", "Sweep inward", "Protect centerline"]
    },
    {
        "id": "shuto_uke",
        "name": "Shuto Uke (Knifehand Block)",
        "category": "block",
        "level": "green",
        "steps": ["Knifehand shape", "Pull opposite hand to hip"]
    },
    {
        "id": "morote_uke",
        "name": "Morote Uke (Reinforced Block)",
        "category": "block",
        "level": "blue",
        "steps": ["Support forearm", "Strong stance", "Push forward"]
    },

    # ------------------------
    # STRIKES
    # ------------------------
    {
        "id": "oi_zuki",
        "name": "Oi Zuki (Lunge Punch)",
        "category": "strike",
        "level": "white",
        "steps": ["Step forward", "Punch same-side arm", "Rotate punch"]
    },
    {
        "id": "gyaku_zuki",
        "name": "Gyaku Zuki (Reverse Punch)",
        "category": "strike",
        "level": "yellow",
        "steps": ["Punch opposite arm", "Hip rotation", "Exhale at impact"]
    },
    {
        "id": "kizami_zuki",
        "name": "Kizami Zuki (Jab Punch)",
        "category": "strike",
        "level": "green",
        "steps": ["Punch front arm", "Quick snap", "Small hip rotation"]
    },
    {
        "id": "uraken_uchi",
        "name": "Uraken Uchi (Backfist Strike)",
        "category": "strike",
        "level": "blue",
        "steps": ["Whip-like motion", "Strike with back of fist"]
    },
    {
        "id": "shuto_uchi",
        "name": "Shuto Uchi (Knifehand Strike)",
        "category": "strike",
        "level": "brown",
        "steps": ["Strike with knifehand", "Rotate hips"]
    },
    {
        "id": "empi_uchi",
        "name": "Empi Uchi (Elbow Strike)",
        "category": "strike",
        "level": "brown",
        "steps": ["Close distance", "Use elbow point", "Drive with hips"]
    },

    # ------------------------
    # KICKS
    # ------------------------
    {
        "id": "mae_geri",
        "name": "Mae Geri (Front Kick)",
        "category": "kick",
        "level": "white",
        "steps": ["Chamber knee", "Snap kick", "Retract"]
    },
    {
        "id": "yoko_geri_keage",
        "name": "Yoko Geri Keage (Side Snap Kick)",
        "category": "kick",
        "level": "yellow",
        "steps": ["Chamber side", "Snap sideways"]
    },
    {
        "id": "yoko_geri_kekomi",
        "name": "Yoko Geri Kekomi (Side Thrust Kick)",
        "category": "kick",
        "level": "green",
        "steps": ["Chamber", "Drive heel forward", "Push motion"]
    },
    {
        "id": "mawashi_geri",
        "name": "Mawashi Geri (Roundhouse Kick)",
        "category": "kick",
        "level": "green",
        "steps": ["Pivot support foot", "Turn hips", "Snap kick"]
    },
    {
        "id": "ushiro_geri",
        "name": "Ushiro Geri (Back Kick)",
        "category": "kick",
        "level": "blue",
        "steps": ["Turn body", "Kick straight backward"]
    },
    {
        "id": "tobi_mae_geri",
        "name": "Tobi Mae Geri (Jump Front Kick)",
        "category": "kick",
        "level": "brown",
        "steps": ["Jump", "Chamber in air", "Snap kick"]
    },
    {
        "id": "tobi_mawashi_geri",
        "name": "Tobi Mawashi Geri (Jump Roundhouse)",
        "category": "kick",
        "level": "brown",
        "steps": ["Jump", "Turn hips", "Kick mid-air"]
    },

    # ------------------------
    # FORMS (KATA)
    # ------------------------
    {"id": "heian_shodan", "name": "Heian Shodan", "category": "form", "level": "yellow"},
    {"id": "heian_nidan", "name": "Heian Nidan", "category": "form", "level": "yellow"},
    {"id": "heian_sandan", "name": "Heian Sandan", "category": "form", "level": "green"},
    {"id": "heian_yondan", "name": "Heian Yondan", "category": "form", "level": "green"},
    {"id": "heian_godan", "name": "Heian Godan", "category": "form", "level": "blue"},
    {"id": "tekki_shodan", "name": "Tekki Shodan", "category": "form", "level": "brown"},
    {"id": "bassai_dai", "name": "Bassai Dai", "category": "form", "level": "brown"},
    {"id": "kanku_dai", "name": "Kanku Dai", "category": "form", "level": "black"},
    {"id": "empy", "name": "Empi", "category": "form", "level": "black"},
    {"id": "jion", "name": "Jion", "category": "form", "level": "black"},
]

# ---------------------------------------
# HELPERS
# ---------------------------------------

belt_order = ["white", "yellow", "green", "blue", "brown", "black"]

def techs_up_to_level(level):
    idx = belt_order.index(level)
    allowed_levels = belt_order[:idx+1]
    return [t for t in techniques if t["level"] in allowed_levels]

def filter_by_category(category):
    return [t for t in techniques if t["category"] == category]

def convert_to_exercise_format(techs):
    return [
        {"id": t["id"], "sets": 3, "reps": 10, "timing_sec": 0}
        for t in techs
    ]

def upload_routine(doc_id, name, exercises, meta={}):
    data = {
        "userId": "system",
        "art": "karate",
        "is_default": True,
        "name": name,
        "created_at": datetime.datetime.utcnow().isoformat(),
        "exercises": exercises
    }
    data.update(meta)
    db.collection("routines").document(doc_id).set(data)
    print("Uploaded:", doc_id)


# ---------------------------------------
# 1️⃣ BELT-BASED ROUTINES (CUMULATIVE)
# ---------------------------------------
for level in belt_order:
    techs = techs_up_to_level(level)
    exercises = convert_to_exercise_format(techs)

    doc_id = f"karate_{level}_belt_routine"
    name = f"{level.capitalize()} Belt Full Routine (Cumulative)"

    upload_routine(doc_id, name, exercises, meta={"belt": level, "focus": "full_cumulative"})


# ---------------------------------------
# 2️⃣ FOCUS-BASED ROUTINES
# ---------------------------------------
focus_categories = {
    "stances": "stance",
    "blocks": "block",
    "hand_techniques": "strike",
    "kicks": "kick",
    "kata": "form"
}

for focus_name, category in focus_categories.items():
    techs = filter_by_category(category)
    exercises = convert_to_exercise_format(techs)

    doc_id = f"karate_focus_{focus_name}"
    name = f"{focus_name.replace('_', ' ').title()} Routine"

    upload_routine(doc_id, name, exercises, meta={"focus": focus_name, "belt": "all"})


# ---------------------------------------
# 3️⃣ KATA ROUTINES (CUMULATIVE)
# ---------------------------------------
kata_belts = ["yellow", "green", "blue", "brown", "black"]

for level in kata_belts:
    idx = belt_order.index(level)
    allowed_levels = belt_order[:idx+1]

    techs = [
        t for t in techniques
        if t["category"] == "form" and t["level"] in allowed_levels
    ]

    exercises = [{"id": t["id"], "sets": 1, "reps": 0, "timing_sec": 120} for t in techs]

    doc_id = f"karate_kata_{level}"
    name = f"{level.capitalize()} Belt Kata Routine (Cumulative)"

    upload_routine(doc_id, name, exercises, meta={"focus": "kata", "belt": level})
