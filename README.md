# Healthcare Data Modeling (OLTP)

> A **transactional data model for a multi-site health clinic** — 30 tables in DBML covering scheduling, no-shows, insurance billing with claim rejections (*glosa*), prepaid session packages and LGPD-restricted clinical records. Built from a written business brief, not from an existing schema.

[![DBML](https://img.shields.io/badge/DBML-dbdiagram.io-3B82F6?style=flat)](https://dbml.dbdiagram.io/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-DDL-4169E1?style=flat&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Tables](https://img.shields.io/badge/Tables-30-0C6857?style=flat)]()
[![Data](https://img.shields.io/badge/Case-fictional%20·%20no%20real%20data-34A853?style=flat)]()

---

## What this is

A database designed from scratch for **Clínica Bem-Viver**, a fictional multi-professional clinic with three sites. The starting point was a business brief in prose — 21 rules describing how the clinic works — and the deliverable is the relational model that supports its operation.

The model is written in **DBML**, so it is version-controlled text that renders as a diagram and generates SQL. Table and column names are in **Portuguese**, matching the business vocabulary of the case (*convênio*, *glosa*, *prontuário*, *repasse*); the documentation is in English.

> **Scope:** this is design work. No data has been loaded and no database has been deployed. The SQL in `sql/` is the DDL generated from the model.

## The business problem

The clinic runs on a third-party scheduling system and the board follows results through spreadsheets that reception exports every Monday. Nobody trusts the numbers. The board wants to answer, among others:

- What is the **no-show rate** by professional, site, weekday and time slot, and is it rising?
- **Billed vs. received vs. rejected** revenue by insurer, month and site?
- How many **prepaid package sessions** were sold and never used?
- How much revenue comes from **internal referrals**?

None of those can be answered while patient, professional, service and payment data live flattened in one spreadsheet — which is what this model fixes.

## Model at a glance

```
ESTRUTURA DA CLÍNICA (7)    unidade · sala · profissional · especialidade
                            profissional_especialidade · agenda_profissional
                            repasse_profissional

SERVIÇOS E PREÇOS (5)       servico · preco_servico · convenio
                            plano_convenio · preco_convenio

PACIENTES (3)               canal_captacao · paciente · paciente_plano

AGENDA E VISITAS (5)        atendimento · agendamento · pacote
                            lista_espera · encaminhamento

DINHEIRO (7)                cobranca · pagamento · pagamento_cobranca · parcela
                            fatura_convenio · fatura_item · motivo_glosa

DADOS CLÍNICOS (3)          prontuario · cid · prontuario_cid      🔒 restricted
```

Every table declares its grain as a note (`1 linha = ...`), which is the first thing to read when opening the diagram.

## Modeling decisions

Each decision below lists the alternative that was rejected, because that is what makes a model a choice instead of luck.

**1. A visit and a procedure are different tables.**
`atendimento` is one visit; `agendamento` is each procedure inside it. A patient who sees the endocrinologist and then has blood drawn and a thyroid ultrasound on the same day produces **1 visit and 3 procedures**, with two different professionals.
*Rejected:* one row per appointment, which would repeat the patient and the plan on every procedure and make "how many visits?" impossible to answer without guessing.

**2. Anything that changes over time carries a validity period.**
Prices, insurance values, the patient's plan, weekly schedules and the professional's revenue share all have `vigencia_inicio` / `vigencia_fim`. An empty end date means "still current".
*Rejected:* overwriting the current value, which silently rewrites history — February's report would show March's price.

**3. Money always flows through a charge.**
`cobranca` records who owes what. A consultation with co-payment produces **two charges**: R$ 120 from the insurer and R$ 40 from the patient. The patient's side is settled through `pagamento_cobranca` (a card swipe can settle two charges, and one charge can be split across two payment methods); the insurer's side goes into `fatura_item`.
*Rejected:* a payment column on the appointment, which cannot express co-payment, split payments, or a prepaid package consumed months later.

**4. Sums are not stored.**
`fatura_convenio` does not keep `valor_faturado` or `valor_glosado` — both are the sum of their items. `valor_recebido` **is** stored, because a bank deposit is a fact, not a calculation.
*Rejected:* keeping totals next to the items, which creates two places holding the same number and no rule about which one wins.

**5. Clinical data is isolated.**
Complaint, treatment and ICD-10 codes exist only in `prontuario` and `prontuario_cid`. No other table holds clinical information, so reception and finance can be granted access to everything else without seeing a diagnosis — which is what LGPD art. 11 requires for health data.
*Rejected:* a diagnosis column on the appointment, which would force column-level permissions on the busiest table in the system.

**6. Surrogate keys as PK, natural keys as UNIQUE.**
`id_paciente` identifies the row; `cpf` is `UNIQUE` and prevents duplicates. A CPF typed wrong has to be fixable, and primary keys should not change.
*Rejected:* the CPF as the primary key, which propagates the correction to every child table.

## Stress tests

The model was checked against concrete scenarios rather than by reading it back:

| Scenario | Where it lives |
|---|---|
| A professional works at two sites and holds two specialties | 1 row in `profissional`, 2 in `profissional_especialidade`, 2 in `agenda_profissional` |
| A patient switches insurer twice in a year | Two periods in `paciente_plano`; each visit freezes the plan that applied |
| Booked → confirmed → rescheduled → no-show | The new appointment points at the original through `id_agendamento_origem` |
| The insurer pays less than billed | `fatura_item.valor_glosado` plus `id_motivo_glosa`, per procedure |
| 7 of 10 package sessions used | Package size minus completed appointments carrying that `id_pacote` |
| Reception opens the schedule without seeing diagnoses | Diagnoses only exist in the restricted tables |

## Repository structure

```
modelo_oltp.dbml          the model — the source of truth
sql/01_ddl_oltp.sql       PostgreSQL DDL generated from the model
docs/data_dictionary.md   grain and purpose of each of the 30 tables
diagrams/er_model.png     rendered ER diagram
```

## Reproducing the SQL

The DDL is generated from the model with the official DBML CLI:

```bash
npx -p @dbml/cli dbml2sql modelo_oltp.dbml -o sql/01_ddl_oltp.sql
```

It carries the primary and foreign keys, unique constraints, the two `CHECK` constraints and the column comments written in the model.

## Limitations

- The clinic, its sites, professionals and patients are **fictional**. No real patient or client data is used anywhere in this repository.
- The model has **not been deployed**: no database was created, no data was loaded, no query was run against it.
- The generated DDL is a starting point. Hand-written refinements — `CHECK` constraints for the status and payment-method domains, indexes for the reporting access paths, and `GRANT`s implementing the LGPD separation — are the next step and are not in this repository yet.

## Next

The analytical counterpart: a dimensional model (star schema) answering the board's ten questions from the same business case.
