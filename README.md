# Healthcare Data Modeling (OLTP)

> A **transactional data model for a multi-site health clinic** — 30 tables in DBML covering scheduling and no-shows, payer billing with claim denials, copays, prepaid session packages and access-restricted clinical records. Designed from a written business brief, not reverse-engineered from an existing schema.

[![DBML](https://img.shields.io/badge/DBML-dbdiagram.io-3B82F6?style=flat)](https://dbml.dbdiagram.io/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-DDL-4169E1?style=flat&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Tables](https://img.shields.io/badge/Tables-30-0C6857?style=flat)]()
[![Case](https://img.shields.io/badge/Case-fictional%20·%20no%20real%20data-34A853?style=flat)]()

---

## What this is

A database designed from scratch for a fictional multi-professional clinic with three sites. The starting point was a business brief in prose — 21 rules describing how the clinic works — and the deliverable is the relational model that supports its operation.

The model is written in **DBML**: version-controlled text that renders as a diagram and generates SQL.

The case is Brazilian, so the business rules include monthly billing to health insurers, partial refusals of those invoices (*glosa*, i.e. claim denials), copays, and the health-data restrictions of the Brazilian data protection law. `docs/glossary.md` maps every one of those terms to its Portuguese original.

> **Scope:** this is design work. No database has been deployed and no data has been loaded. The SQL in `sql/` is the DDL generated from the model.

## The business problem

The clinic runs on a third-party scheduling system, and the board follows results through spreadsheets exported by reception every Monday. Nobody trusts the numbers. The board wants to answer, among others:

- What is the **no-show rate** by provider, site, weekday and time slot, and is it rising?
- **Billed vs. received vs. denied** revenue by payer, month and site?
- How many **prepaid package sessions** were sold and never used?
- How much revenue starts as an **internal referral**?

None of those survive a single flat spreadsheet where patient, provider, service and payment data repeat on every line — which is what this model replaces.

## Model at a glance

```
CLINIC STRUCTURE (7)    facility · room · provider · specialty
                        provider_specialty · provider_schedule
                        provider_revenue_share

SERVICES & PRICES (5)   service · service_price · payer
                        payer_plan · payer_contract_price

PATIENTS (3)            acquisition_channel · patient · patient_coverage

SCHEDULING (5)          encounter · appointment · session_package
                        waitlist · internal_referral

MONEY (7)               charge · payment · payment_allocation · installment
                        payer_invoice · invoice_line · denial_reason

CLINICAL (3)            clinical_note · icd10 · clinical_note_diagnosis   🔒 restricted
```

Every table declares its grain as a note (`1 row = ...`), which is the first thing to read when opening the diagram.

## Modeling decisions

Each decision lists the alternative that was rejected, because that is what makes a model a choice instead of luck.

**1. A visit and a procedure are different tables.**
`encounter` is one visit; `appointment` is each procedure inside it. A patient who sees the endocrinologist and then has blood drawn and a thyroid ultrasound on the same day produces **one encounter and three appointments**, with two different providers.
*Rejected:* one row per appointment only, which repeats the patient and the coverage on every procedure and makes "how many visits?" unanswerable.

**2. Anything that changes over time carries a validity period.**
Prices, contracted payer rates, the patient's coverage, weekly schedules and provider revenue shares all have `valid_from` / `valid_to`. An empty end date means "still current".
*Rejected:* overwriting the current value, which silently rewrites history — February's report would show March's price.

**3. Money always flows through a charge.**
`charge` records who owes what. A covered consultation with a copay produces **two charges**: the payer's share and the patient's. The patient side is settled through `payment_allocation` — one card swipe can settle two charges, and one charge can be split across two methods — while the payer side goes into `invoice_line`.
*Rejected:* a payment column on the appointment, which cannot express copays, split payments, or a package paid upfront and consumed months later.

**4. Sums are not stored.**
`payer_invoice` keeps no billed or denied totals: both are the sum of their lines. `amount_received` **is** stored, because a bank deposit is a fact, not a calculation.
*Rejected:* totals next to the lines, which creates two places holding the same number and no rule for which one wins.

**5. Clinical data is isolated.**
Complaint, treatment plan and ICD-10 codes exist only in `clinical_note` and `clinical_note_diagnosis`. No other table holds clinical information, so reception and finance can be granted access to everything else without seeing a diagnosis — which is what the Brazilian data protection law requires for health data (LGPD art. 11).
*Rejected:* a diagnosis column on the appointment, which forces column-level permissions on the busiest table in the system.

**6. Surrogate keys as PK, natural keys as UNIQUE.**
`patient_id` identifies the row; the taxpayer ID is `UNIQUE` and blocks duplicates. A mistyped document has to be fixable, and primary keys should not change.
*Rejected:* the taxpayer ID as the primary key, which propagates every correction to all child tables.

## Stress tests

The model was checked against concrete scenarios rather than by reading it back:

| Scenario | Where it lives |
|---|---|
| A provider works at two sites and holds two specialties | 1 row in `provider`, 2 in `provider_specialty`, 2 in `provider_schedule` |
| A patient switches insurer twice in a year | Two periods in `patient_coverage`; each encounter freezes the one that applied |
| Booked → confirmed → rescheduled → no-show | The new appointment points at the original through `rescheduled_from_id` |
| The payer pays less than billed | `invoice_line.denied_amount` plus `denial_reason_id`, per procedure |
| 7 of 10 package sessions used | Package size minus completed appointments carrying that `package_id` |
| Reception opens the schedule without seeing diagnoses | Diagnoses exist only in the restricted tables |

## Repository structure

```
clinic_oltp.dbml          the model — the source of truth
sql/01_ddl_oltp.sql       PostgreSQL DDL generated from the model
docs/data_dictionary.md   grain and purpose of each of the 30 tables
docs/glossary.md          Brazilian clinic vocabulary mapped to English
diagrams/er_model.png     rendered ER diagram
```

## Reproducing the SQL

The DDL is generated from the model with the official DBML CLI:

```bash
npx -p @dbml/cli dbml2sql clinic_oltp.dbml -o sql/01_ddl_oltp.sql
```

It carries primary and foreign keys, unique constraints, the two `CHECK` constraints and the column comments written in the model.

## Limitations

- The clinic, its sites, providers and patients are **fictional**. No real patient or client data appears anywhere in this repository.
- The model has **not been deployed**: no database created, no data loaded, no query run against it.
- The generated DDL is a starting point. Hand-written refinements — `CHECK` constraints for the status and payment-method domains, indexes for the reporting access paths, referential actions on delete, and `GRANT`s implementing the clinical-data separation — are the next step and are not in this repository yet.

## Next

The analytical counterpart: a dimensional model (star schema) answering the board's ten questions from the same business case.
