# Data dictionary and glossary

Thirty tables, grouped by subject, followed by the Brazilian vocabulary the case is built on.

Every table states its **grain** — what exactly one row represents. When the grain is not a single clear sentence, the table is doing two jobs at once and needs to be split. Column-level notes live in `clinic_oltp.dbml`.

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

---

# Glossary

The case is Brazilian: private clinics here bill health insurers monthly, and those insurers routinely refuse part of what was billed. The model is written in English; this is the vocabulary behind it.

## Business terms

| Portuguese | English | What it means |
|---|---|---|
| convênio | payer / health insurer | The company that covers part of the bill |
| plano | plan | A tier inside a payer. Different tiers cover different services at different rates |
| particular | self-pay | The patient pays the full price directly; no payer involved |
| coparticipação | copay | The patient's share of a covered service: the payer covers R$ 120, the patient pays R$ 40 |
| faturamento | billing | Sending the month's covered services to the payer |
| **glosa** | **claim denial** | The part of an invoice the payer refuses to pay: missing authorisation, service not covered, mistyped code. The central term of this case |
| repasse | revenue share | The percentage of what a provider produces that is paid to them |
| prontuário | clinical note / medical record | Complaint, treatment plan and diagnoses of a completed procedure |
| CID-10 | ICD-10 | The international classification of diseases |
| atendimento | encounter | One visit of a patient to the clinic on a given day |
| agendamento | appointment | One scheduled procedure inside a visit |
| falta | no-show | The patient did not appear and did not cancel |
| encaixe | fitting in from the waitlist | Filling a slot freed by a cancellation |
| encaminhamento | internal referral | One provider sending the patient to another inside the clinic |
| pacote de sessões | prepaid session package | Ten physiotherapy sessions, paid upfront, consumed over weeks |
| CPF | taxpayer ID | The Brazilian personal tax number, used as the patient's natural key |
| CRM, CRN, CREFITO, CRP, COREN | professional licence numbers | Registration with the council of each profession |
| LGPD art. 11 | Brazilian data protection law, health data | Health data is a special category; access must be restricted by role |

## Table names

| Portuguese (design draft) | English (this repository) | | Portuguese (design draft) | English (this repository) |
|---|---|---|---|---|
| unidade | `facility` | | encaminhamento | `internal_referral` |
| sala | `room` | | cobranca | `charge` |
| profissional | `provider` | | pagamento | `payment` |
| especialidade | `specialty` | | pagamento_cobranca | `payment_allocation` |
| profissional_especialidade | `provider_specialty` | | parcela | `installment` |
| agenda_profissional | `provider_schedule` | | fatura_convenio | `payer_invoice` |
| repasse_profissional | `provider_revenue_share` | | fatura_item | `invoice_line` |
| servico | `service` | | motivo_glosa | `denial_reason` |
| preco_servico | `service_price` | | prontuario | `clinical_note` |
| convenio | `payer` | | cid | `icd10` |
| plano_convenio | `payer_plan` | | prontuario_cid | `clinical_note_diagnosis` |
| preco_convenio | `payer_contract_price` | | canal_captacao | `acquisition_channel` |
| paciente | `patient` | | atendimento | `encounter` |
| paciente_plano | `patient_coverage` | | agendamento | `appointment` |
| pacote | `session_package` | | lista_espera | `waitlist` |

The model was drafted in Portuguese against a brief written in Portuguese, then renamed. The structure did not change in the translation: same 30 tables, same keys, same relationships.
