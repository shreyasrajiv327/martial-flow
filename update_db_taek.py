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
# PASTE YOUR FULL TECHNIQUES LIST HERE
# -------------------------
techniques = [
    # ------------------
    # BASIC STANCES
    # ------------------
    {
        "id": "juchum_seogi",
        "name": "Juchum Seogi (Horse Stance)",
        "category": "stance",
        "level": "white",
        "steps": ["Feet wider than shoulders", "Bend knees", "Keep back straight"]
    },
    {
        "id": "ap_seogi",
        "name": "Ap Seogi (Walking Stance)",
        "category": "stance",
        "level": "white",
        "steps": ["Step forward", "Keep feet shoulder-width apart"]
    },
    {
        "id": "ap_gubi",
        "name": "Ap Gubi (Front Stance)",
        "category": "stance",
        "level": "white",
        "steps": ["Long stance", "Front knee bent", "Rear leg straight"]
    },

    # ------------------
    # BASIC BLOCKS
    # ------------------
    {
        "id": "are_makki",
        "name": "Are Makki (Low Block)",
        "category": "block",
        "level": "white",
        "steps": ["Chamber high", "Sweep downward", "Block low"]
    },
    {
        "id": "olgul_makki",
        "name": "Olgul Makki (High Block)",
        "category": "block",
        "level": "white",
        "steps": ["Raise forearm", "Angle 45°", "Protect head"]
    },
    {
        "id": "momtong_makki",
        "name": "Momtong Makki (Middle Block)",
        "category": "block",
        "level": "yellow",
        "steps": ["Chamber to shoulder", "Sweep outward", "Block midsection"]
    },
    {
        "id": "goduro_makki",
        "name": "Goduro Makki (Supported Block)",
        "category": "block",
        "level": "green",
        "steps": ["One hand reinforces the other"]
    },
    {
        "id": "sonnal_makki",
        "name": "Sonnal Makki (Knife Hand Block)",
        "category": "block",
        "level": "blue",
        "steps": ["Form knife hand", "Block sideways"]
    },

    # ------------------
    # BASIC STRIKES
    # ------------------
    {
        "id": "ap_jireugi",
        "name": "Ap Jireugi (Front Punch)",
        "category": "strike",
        "level": "white",
        "steps": ["Extend fist forward", "Rotate at impact"]
    },
    {
        "id": "dubeon_jireugi",
        "name": "Dubeon Jireugi (Double Punch)",
        "category": "strike",
        "level": "yellow",
        "steps": ["Punch twice quickly"]
    },
    {
        "id": "palmok_chigi",
        "name": "Palmok Chigi (Forearm Strike)",
        "category": "strike",
        "level": "green",
    },
    {
        "id": "sonnal_chigi",
        "name": "Sonnal Chigi (Knifehand Strike)",
        "category": "strike",
        "level": "blue",
    },

    # ------------------
    # BASIC KICKS
    # ------------------
    {
        "id": "ap_chagi",
        "name": "Ap Chagi (Front Kick)",
        "category": "kick",
        "level": "yellow",
        "steps": ["Chamber knee", "Kick forward", "Retract"]
    },
    {
        "id": "dollyo_chagi",
        "name": "Dollyo Chagi (Roundhouse Kick)",
        "category": "kick",
        "level": "yellow",
        "steps": ["Pivot foot", "Turn hips", "Kick round"]
    },
    {
        "id": "yop_chagi",
        "name": "Yop Chagi (Side Kick)",
        "category": "kick",
        "level": "green",
        "steps": ["Chamber side", "Extend sideways"]
    },
    {
        "id": "naeryo_chagi",
        "name": "Naeryo Chagi (Axe Kick)",
        "category": "kick",
        "level": "green",
        "steps": ["Lift leg high", "Drop down forcefully"]
    },
    {
        "id": "bita_chagi",
        "name": "Bita Chagi (Diagonal Kick)",
        "category": "kick",
        "level": "blue",
    },
    {
        "id": "tora_chagi",
        "name": "Tora Chagi (Turning Kick)",
        "category": "kick",
        "level": "blue",
    },

    # ------------------
    # ADVANCED KICKS
    # ------------------
    {
        "id": "twio_ap_chagi",
        "name": "Twio Ap Chagi (Jump Front Kick)",
        "category": "kick",
        "level": "red",
    },
    {
        "id": "twio_dollyo_chagi",
        "name": "Twio Dollyo Chagi (Jump Roundhouse)",
        "category": "kick",
        "level": "red",
    },
    {
        "id": "twio_yop_chagi",
        "name": "Twio Yop Chagi (Jump Side Kick)",
        "category": "kick",
        "level": "red",
    },
    {
        "id": "naeryo_chagi_jump",
        "name": "Twio Naeryo Chagi (Jump Axe Kick)",
        "category": "kick",
        "level": "red",
    },
    {
        "id": "bandal_chagi",
        "name": "Bandal Chagi (45° Kick)",
        "category": "kick",
        "level": "green",
    },
    {
        "id": "dwitchagi",
        "name": "Dwi Chagi (Back Kick)",
        "category": "kick",
        "level": "blue",
    },
    {
        "id": "dwi_dollyo_chagi",
        "name": "Dwi Dollyo Chagi (Spinning Back Kick)",
        "category": "kick",
        "level": "brown",
    },
    {
        "id": "narae_chagi",
        "name": "Narae Chagi (Double Spinning Kick)",
        "category": "kick",
        "level": "black",
    },
    {
        "id": "chetdari_chagi",
        "name": "Chetdari Chagi (Hook Kick)",
        "category": "kick",
        "level": "blue",
    },

    # ------------------
    # SPECIAL TECHNIQUES & SELF-DEFENSE
    # ------------------
    {
        "id": "hwalgae_chigi",
        "name": "Hwalgae Chigi (Ridgehand Strike)",
        "category": "strike",
        "level": "brown",
    },
    {
        "id": "jireugi_dwi",
        "name": "Dwi Jireugi (Back Fist Punch)",
        "category": "strike",
        "level": "yellow",
    },
    {
        "id": "pyojeok_chigi",
        "name": "Pyojeok Chigi (Target Strike)",
        "category": "strike",
        "level": "green",
    },
    {
        "id": "sonkut_sewo_chigi",
        "name": "Sonkut Sewo Chigi (Vertical Spearhand)",
        "category": "strike",
        "level": "blue",
    },
    {
        "id": "sonkut_arae_chigi",
        "name": "Sonkut Arae Chigi (Low Spearhand)",
        "category": "strike",
        "level": "brown",
    },

    # ------------------
    # POOMSAE (Forms)
    # ------------------
    {
        "id": "taegeuk_1",
        "name": "Taegeuk Il Jang",
        "category": "form",
        "level": "yellow",
    },
    {
        "id": "taegeuk_2",
        "name": "Taegeuk Yi Jang",
        "category": "form",
        "level": "yellow",
    },
    {
        "id": "taegeuk_3",
        "name": "Taegeuk Sam Jang",
        "category": "form",
        "level": "green",
    },
    {
        "id": "taegeuk_4",
        "name": "Taegeuk Sa Jang",
        "category": "form",
        "level": "green",
    },
    {
        "id": "taegeuk_5",
        "name": "Taegeuk Oh Jang",
        "category": "form",
        "level": "blue",
    },
    {
        "id": "taegeuk_6",
        "name": "Taegeuk Yuk Jang",
        "category": "form",
        "level": "blue",
    },
    {
        "id": "taegeuk_7",
        "name": "Taegeuk Chil Jang",
        "category": "form",
        "level": "red",
    },
    {
        "id": "taegeuk_8",
        "name": "Taegeuk Pal Jang",
        "category": "form",
        "level": "red",
    }
]


# ---------------------------------------
# HELPERS
# ---------------------------------------

# Get techniques for <= belt level (cumulative)
belt_order = ["white", "yellow", "green", "blue", "red", "brown", "black"]

def techs_up_to_level(level):
    idx = belt_order.index(level)
    allowed_levels = belt_order[:idx+1]
    return [t for t in techniques if t["level"] in allowed_levels]


def filter_by_category(category):
    return [t for t in techniques if t["category"] == category]


def convert_to_exercise_format(techs):
    return [
        {
            "id": t["id"],
            "sets": 3,
            "reps": 10,
            "timing_sec": 0
        }
        for t in techs
    ]


def upload_routine(doc_id, name, exercises, meta={}):
    data = {
        "userId": "system",
        "art": "taekwondo",
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

    doc_id = f"taekwondo_{level}_belt_routine"
    name = f"{level.capitalize()} Belt Full Routine (Cumulative)"

    upload_routine(
        doc_id,
        name,
        exercises,
        meta={"belt": level, "focus": "full_cumulative"}
    )


# ---------------------------------------
# 2️⃣ FOCUS-BASED ROUTINES (Kicks, Strikes, Blocks, Forms, Stances)
# ---------------------------------------
focus_categories = {
    "stances": "stance",
    "blocks": "block",
    "hand_techniques": "strike",
    "kicks": "kick",
    "forms": "form"
}

for focus_name, category in focus_categories.items():
    techs = filter_by_category(category)
    exercises = convert_to_exercise_format(techs)

    doc_id = f"taekwondo_focus_{focus_name}"
    name = f"{focus_name.replace('_', ' ').title()} Routine"

    upload_routine(
        doc_id,
        name,
        exercises,
        meta={"focus": focus_name, "belt": "all"}
    )


# ---------------------------------------
# 3️⃣ POOMSAE ROUTINES FOR EACH BELT (CUMULATIVE)
# ---------------------------------------
poomsae_belts = ["yellow", "green", "blue", "red"]

for level in poomsae_belts:
    idx = belt_order.index(level)
    allowed_levels = belt_order[:idx+1]

    techs = [
        t for t in techniques
        if t["category"] == "form" and t["level"] in allowed_levels
    ]

    exercises = [
        {"id": t["id"], "sets": 1, "reps": 0, "timing_sec": 90}
        for t in techs
    ]

    doc_id = f"taekwondo_poomsae_{level}"
    name = f"{level.capitalize()} Belt Poomsae (Cumulative)"

    upload_routine(
        doc_id,
        name,
        exercises,
        meta={"focus": "poomsae", "belt": level}
    )