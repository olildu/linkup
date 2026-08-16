import argparse
import random
import string
import requests
from faker import Faker
from datetime import date, timedelta
import re
import json
from typing import Optional

fake = Faker()

# --- Constants / Allowed Choices (match your Pydantic Literals) ---
GENDERS = ["Male", "Female"]
STAYING_OPTIONS = ["Campus Hostel", "PG", "Home", "Flat", "Other"]
RELIGIONS = ["Islam", "Sikhism", "Jainism", "Christianity", "Hinduism", "Buddhism", "Others"]
SMOKING_OPTIONS = ["Yes", "Trying to quit", "Occasionally", "No", "No, prefer non-smokers"]
DRINKING_OPTIONS = ["Yes", "Trying to quit", "Occasionally", "No", "No, prefer non-drinkers"]
LOOKING_FOR_OPTIONS = ["Casual", "Open to anything", "Serious", "Friends", "Not sure yet"]

BASE_URL = "http://127.0.0.1:8000"
BASE_URL = "https://linkup.olildu.dpdns.org/api/v1"
TIMEOUT = 15  # seconds

# Tag all seed-generated accounts with this email domain so cleanup_seed_data.py
# can find and delete them later without touching real user data.
SEED_EMAIL_DOMAIN = "linkupseedtest.com"
SEED_RECORD_FILE = "seed_profiles.jsonl"


# --- Helpers to generate valid data ---
def generate_strong_password() -> str:
    while True:
        password = (
            random.choice(string.ascii_uppercase) +
            random.choice(string.ascii_lowercase) +
            random.choice(string.digits) +
            random.choice('!@#$%^&*(),.?":{}|<>') +
            ''.join(random.choices(string.ascii_letters + string.digits + '!@#$%^&*(),.?":{}|<>', k=8))
        )
        if (
            len(password) >= 12 and
            re.search(r'[A-Z]', password) and
            re.search(r'[a-z]', password) and
            re.search(r'[0-9]', password) and
            re.search(r'[!@#$%^&*(),.?":{}|<>]', password)
        ):
            return password


def generate_seed_email() -> str:
    # Tagged domain (not fake.email()'s default @example.*) so seed accounts
    # are trivially identifiable and never collide with real user emails.
    return f"{fake.user_name()}{random.randint(1000, 9999)}@{SEED_EMAIL_DOMAIN}"


def record_seed_profile(record: dict):
    with open(SEED_RECORD_FILE, "a") as f:
        f.write(json.dumps(record) + "\n")


def rand_date_between(min_age: int = 18, max_age: int = 30) -> date:
    today = date.today()
    latest = today - timedelta(days=min_age * 365)
    earliest = today - timedelta(days=max_age * 365)
    # Faker returns datetime.date when using date_between
    return fake.date_between(start_date=earliest, end_date=latest)


def generate_fake_photos() -> list[dict]:
    return [
        {
            "file_key": "/media/4/a8725fe2-a0dc-4c89-b962-8e4e422814fa_d6LvcDCk9.jpg",
            "blurhash": "|aKKi[D%.S-:r=WENGRjj[^*RkoeogWCt6a}R*ay0MxtMwRjX9axt7t7WB-;t7ofjFR*M|j?t7ofxuayRjRkWBofRjayofaKofIpfQxuofoLjtWBxufRofWAayofj[WVa|NHWBjYWXWBxaR+WBs:V@fka#t7t7WCofjZWB"
        },
        {
            "file_key": "/media/4/130dda9f-3e41-48ac-b49d-92b994d8e536_gz-dasXy52.webp",
            "blurhash": "|rIi~N.5x@t6WDj[j[odWC~pRUV^kAj@j@agjbkB.6RjRkV[afj[oeoejuR*RjaxkBoej[ayafafRQoyofoMjbayayayf$aet6kCj@ayayf8j[juWoahagbEaykAjujbazo{f6afWCa|fij[j@a{oMbFkBj[j[f8a|bFj@"
        },
        {
            "file_key": "/media/4/7341e939-4f7f-473d-b997-fd8f227c3f7d_LeSiv-ZOES.webp",
            "blurhash": "|sIi]9.5x@tQa#j[juoxkB~pRUV]j@jtkAazf8a|-:RjRjV[WCayj@kBjbS2V[axkBoxofj@ayafRRoyofoMjba#ayayf$V[oyj[ayWCafafa{j[W-e=afbYa{k9j[jbf8o{jHjbafj[juj[kBfjoMWoj@jbjuf8azayay"
        }
    ]



def generate_fake_profile_picture() -> dict:
    return {
        "file_key": "/profile_pictures/4/pfp_pzPX0OZ1kj.webp",
        "blurhash": "|PKS;E0h5m^*XTxuN{bb-o=sMx9a9ZE2xCIVWBj@Nx-:o#kDt7NG?GRkjYRP$$Ion~NbRkS3xtt7?GRkIpxaoeIpRjWBWBf+R*NHxZs:kCs.bIt7Naofs:WBj[o0WBWBR*xGR*R*s:WDj@s:NHj[NHoeofR*j?oeaejsR*"
    }



def generate_register_payload() -> dict:
    username = fake.user_name()  # no spaces; safer for typical username rules
    payload = {
        "username": username,
        "university_year": random.randint(1, 4),
        "profile_picture": generate_fake_profile_picture(),
        "gender": random.choice(GENDERS),

        "dob": rand_date_between(18, 27).isoformat(),  # >= 18
        "interested_gender": random.choice(GENDERS),

        "university_major": fake.job(),  # substitute with a curated list if you prefer
        "photos": generate_fake_photos(),
        "about": fake.sentence(nb_words=12),

        "currently_staying": random.choice(STAYING_OPTIONS),
        "hometown": f"{fake.city()}, {fake.state()}",

        "height": random.randint(150, 195),
        "weight": random.randint(45, 110),

        "religion": random.choice(RELIGIONS + [None]),
        "smoking_info": random.choice(SMOKING_OPTIONS + [None]),
        "drinking_info": random.choice(DRINKING_OPTIONS + [None]),
        "looking_for": random.choice(LOOKING_FOR_OPTIONS + [None]),
    }
    return payload


# --- HTTP utilities ---
def print_debug(prefix: str, resp: requests.Response):
    try:
        txt = resp.text[:800]  # avoid dumping huge bodies
    except Exception:
        txt = "<no text>"
    print(f"{prefix}: HTTP {resp.status_code}\n{txt}\n")


def expect_ok(resp: requests.Response, context: str):
    if not (200 <= resp.status_code < 300):
        print_debug(f"[ERROR] {context}", resp)
        raise RuntimeError(f"{context} failed with status {resp.status_code}")


# --- Flow steps ---
def request_otp(session: requests.Session, email: str):
    resp = session.get(f"{BASE_URL}/verify-email", params={"email": email}, timeout=TIMEOUT)
    expect_ok(resp, "Request OTP")


def verify_otp(session: requests.Session, email: str, otp: int = 123456) -> str:
    resp = session.post(
        f"{BASE_URL}/verify-otp",
        json={"email": email, "otp": otp, "subject": "email_verification"},
        timeout=TIMEOUT,
    )
    expect_ok(resp, "Verify OTP")
    data = resp.json()
    if "email_hash" not in data:
        print_debug("[ERROR] Verify OTP - Missing email_hash", resp)
        raise RuntimeError("verify-otp did not return email_hash")
    return data["email_hash"]


def signup(session: requests.Session, email_hash: str, password: str) -> dict:
    resp = session.post(f"{BASE_URL}/signup", json={"email_hash": email_hash, "password": password}, timeout=TIMEOUT)
    expect_ok(resp, "Signup")
    data = resp.json()
    for key in ("access_token", "refresh_token", "user_id"):
        if key not in data:
            print_debug(f"[ERROR] Signup - Missing {key}", resp)
            raise RuntimeError(f"signup did not return {key}")
    return data


def register_profile(session: requests.Session, access_token: str, payload: dict):
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
    }
    resp = session.post(f"{BASE_URL}/register", headers=headers, json=payload, timeout=TIMEOUT)
    expect_ok(resp, "Register")
    return resp.json() if resp.headers.get("content-type", "").startswith("application/json") else {"raw": resp.text}


# --- One complete user creation ---
def create_one_user() -> Optional[dict]:
    session = requests.Session()

    email = generate_seed_email()
    password = generate_strong_password()

    try:
        # 1) OTP request
        request_otp(session, email)

        # 2) OTP verify -> email_hash
        email_hash = verify_otp(session, email, otp=123456)

        # 3) Signup -> tokens
        signup_data = signup(session, email_hash, password)
        access_token = signup_data["access_token"]
        user_id = signup_data["user_id"]

        # 4) Register -> profile
        profile_payload = generate_register_payload()
        reg_result = register_profile(session, access_token, profile_payload)

        print(f"[OK] user_id={user_id} email={email} username={profile_payload['username']}")
        record_seed_profile({
            "email": email,
            "user_id": user_id,
            "username": profile_payload["username"],
        })
        return {
            "email": email,
            "user_id": user_id,
            "username": profile_payload["username"],
            "access_token": access_token,
            "refresh_token": signup_data["refresh_token"],
            "password": password,
            "register_result": reg_result,
        }

    except Exception as e:
        print(f"[FAIL] email={email} reason={e}")
        return None


# --- Bulk create ---
def main():
    global BASE_URL

    parser = argparse.ArgumentParser(description="Create N fake profiles via the live API.")
    parser.add_argument("n", type=int, help="Number of profiles to create")
    parser.add_argument("--base-url", default=BASE_URL, help=f"API base URL (default: {BASE_URL})")
    args = parser.parse_args()

    BASE_URL = args.base_url
    N = args.n

    results = []
    for i in range(1, N + 1):
        print(f"\n=== Creating user {i}/{N} ===")
        result = create_one_user()
        if result:
            # Keep output short; comment next line if too verbose
            print(json.dumps({k: result[k] for k in ("email", "user_id", "username")}, indent=2))
            results.append(result)

    print(f"\nDone. Success: {len(results)}/{N}")


if __name__ == "__main__":
    main()
