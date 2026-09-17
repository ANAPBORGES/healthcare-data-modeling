# Data dictionary

Thirty tables, grouped by subject. Every table states its **grain** — what exactly one row represents. When the grain is not a single clear sentence, the table is doing two jobs at once and needs to be split.

Column-level notes live in `clinic_oltp.dbml` and are carried into the generated DDL as `COMMENT ON COLUMN`. Brazilian business terms are mapped in `glossary.md`.

---

## Clinic structure

| Table | One row is | Notes |
|---|---|---|
| `facility` | one clinic site | Three sites; `city` matters because one of them is in another city |
| `room` | one physical room inside a site | Room names are unique per site, not globally. Appointments reach the site through the room |
| `provider` | one person who treats patients | `license_number` (CRM, CRN, CREFITO, CRP, COREN) is the natural key |
| `specialty` | one specialty | A lookup the clinic maintains |
| `provider_specialty` | the fact that a provider holds a specialty | Resolves the many-to-many; a provider with two specialties has two rows |
| `provider_schedule` | one weekly block: provider, site, weekday, time window | The only place that says where a provider works. Carries a validity period because schedules change |
| `provider_revenue_share` | one revenue-share percentage valid for a period | May's payout uses the percentage in force in May, not today's |

## Services and prices

| Table | One row is | Notes |
|---|---|---|
| `service` | one catalogue item | `service_type` separates consultation, follow-up, exam, session and assessment. Duration lives here, not on the type, because exams differ from each other |
| `service_price` | the self-pay price of a service, at a site, for a period | List prices change about once a year |
| `payer` | one health insurer | Invoices are issued per payer, which is why it is separate from the plan |
| `payer_plan` | one plan of a payer | Plan names are unique within their payer |
| `payer_contract_price` | what a plan pays for a service, at a site, for a period | Splits the amount into `payer_amount` and `copay_amount`. No row means the plan does not cover that service |

## Patients

| Table | One row is | Notes |
|---|---|---|
| `acquisition_channel` | one way of hearing about the clinic | A table rather than free text, so "Instagram" and "instagram" do not become two channels |
| `patient` | one registered person | Address split into components; `tax_id` is unique; date of birth stored instead of age |
| `patient_coverage` | one period in which the patient held a plan | Self-pay means no active row on that date. `member_number` is required on payer invoices — a typo here is a common denial reason |

## Scheduling and visits

| Table | One row is | Notes |
|---|---|---|
| `encounter` | one visit: the patient coming to the clinic on a given day | Holds the patient and the coverage that applied, freezing them against later changes |
| `appointment` | one scheduled procedure: provider, service, room, time slot | Carries the status, including no-shows and cancellations. Points at the original appointment when it is a reschedule |
| `session_package` | one prepaid package sold to a patient | Ten physiotherapy sessions consumed over weeks. The expiry date is frozen at sale |
| `waitlist` | one request to be fitted in | Holds no slot; the link to an appointment appears only when the patient is fitted into a cancellation |
| `internal_referral` | one provider referring the patient to another | The target appointment stays empty until the patient books, which is how referral conversion is measured |

## Money

| Table | One row is | Notes |
|---|---|---|
| `charge` | one amount owed by one payer | A copay produces two rows for the same procedure: one for the insurer, one for the patient. The amount is frozen when charged |
| `payment` | one patient transaction: a transfer, a card swipe | Method and amount only; what it settles is in the next table |
| `payment_allocation` | how much of a payment settled a given charge | One swipe can settle two charges, and one charge can be split across two methods |
| `installment` | one receivable from a payment | Credit instalments, up to six. An empty `settled_on` means it has not cleared yet |
| `payer_invoice` | the monthly invoice sent to a payer by a site | One invoice per payer, site and month. Totals are not stored — they are the sum of the lines |
| `invoice_line` | one payer charge inside an invoice | Holds the denied amount and its reason. A charge can only be invoiced once |
| `denial_reason` | one reason a payer refused to pay | Missing authorisation, service not covered, mistyped code — an open list the clinic extends |

## Clinical records — restricted access

These three tables are the only ones holding health data (LGPD art. 11). They belong in a separate schema, with access limited to healthcare professionals; every other table can be exposed to reception and finance without leaking a diagnosis.

| Table | One row is | Notes |
|---|---|---|
| `clinical_note` | the clinical record of one completed procedure | Per procedure rather than per visit, because each provider writes and signs their own |
| `icd10` | one ICD-10 code | The official code is the primary key: stable and externally defined |
| `clinical_note_diagnosis` | one diagnosis recorded in a note | A note with two diagnoses has two rows; `diagnosis_type` marks the primary one |
