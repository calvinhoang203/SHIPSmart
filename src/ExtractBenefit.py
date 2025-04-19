#!/usr/bin/env python3
import os, re
import pdfplumber
import pandas as pd
from sqlalchemy import create_engine

# Locate PDF in project root
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PDF_PATH = os.path.join(SCRIPT_DIR, "UCD-Anthem-Benefit-Book.pdf")

def extract_parameters(pdf_path):
    text = ""
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            text += (page.extract_text() or "") + "\n"

    # Deductibles
    ded = re.search(
        r"Deductible – Plan Year[\s\S]*?Per Member\s*\$([0-9,]+)\s*\$([0-9,]+)",
        text
    )
    deductible, family_deductible = (float(ded.group(i).replace(",", "")) for i in (1,2)) if ded else (None, None)

    # ER Copay
    er = re.search(r"Emergency Room Facility Charge\s*\$([0-9,]+)", text)
    er_copay = float(er.group(1).replace(",", "")) if er else None

    # Imaging Copay
    img = re.search(r"Advanced Diagnostic Imaging.*?\$([0-9,]+)", text)
    imaging_copay = float(img.group(1).replace(",", "")) if img else None

    # Primary-Care Copay (Network)
    m = re.search(r"Primary Care Physician[\s\S]*?\$([0-9,]+)\s*Copayment", text)
    primary_care_copay = float(m.group(1).replace(",", "")) if m else None

    # Coinsurance %
    coinsurance_pct = None
    m = re.search(r"Coinsurance[\s\S]*?Plan Pays\s*([0-9]{1,3})%", text)
    if m:
        coinsurance_pct = float(m.group(1))

    # Out-of-Pocket Limits
    oop = re.search(
        r"Out-of-Pocket Limit[\s\S]*?Per Member\s*\$([0-9,]+)\s*\$([0-9,]+)",
        text
    )
    oop_per_member, oop_per_family = (float(oop.group(i).replace(",", "")) for i in (1,2)) if oop else (None, None)

    return {
        "plan_year":           "2024-25",
        "effective_date":      "2024-09-16",
        "deductible":          deductible,
        "family_deductible":   family_deductible,
        "er_copay":            er_copay,
        "imaging_copay":       imaging_copay,
        "primary_care_copay":  primary_care_copay,
        "coinsurance_pct":     coinsurance_pct,
        "oop_per_member":      oop_per_member,
        "oop_per_family":      oop_per_family
    }

def main():
    params = extract_parameters(PDF_PATH)
    df = pd.DataFrame([params])
    print("Extracted Benefit Parameters:")
    print(df.to_string(index=False))

    db_url = os.getenv("DB_URL")
    if db_url:
        engine = create_engine(db_url)
        df.to_sql("policy_parameters", engine, if_exists="append", index=False)
        print("✔ Loaded into policy_parameters table.")
    else:
        print("⚠ DB_URL not set; skipping DB load.")

if __name__ == "__main__":
    main()
