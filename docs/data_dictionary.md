# Data dictionary

Thirty tables, grouped by subject. Identifiers are in Portuguese because they follow the vocabulary of the business case; the descriptions are in English.

Every table states its **grain** — what exactly one row represents. When the grain is not a single clear sentence, the table is doing two jobs at once and needs to be split.

Column-level notes live in `modelo_oltp.dbml` and are carried into the generated DDL as `COMMENT ON COLUMN`.

---

## Clinic structure

| Table | One row is | Notes |
|---|---|---|
| `unidade` | one clinic site | Three sites; `cidade_unidade` matters because one of them is in another city |
| `sala` | one physical room inside a site | Room names are unique per site, not globally. Appointments reach the site through the room |
| `profissional` | one person who treats patients | `numero_registro` (CRM, CRN, CREFITO, CRP, COREN) is the natural key |
| `especialidade` | one medical specialty | A lookup the clinic maintains |
| `profissional_especialidade` | the fact that a professional holds a specialty | Resolves the many-to-many; a professional with two specialties has two rows |
| `agenda_profissional` | one weekly block: professional, site, weekday, time window | The only place that says where a professional works. Carries a validity period because schedules change |
| `repasse_profissional` | one revenue-share percentage valid for a period | May's payout uses the percentage in force in May, not today's |

## Services and prices

| Table | One row is | Notes |
|---|---|---|
| `servico` | one catalogue item | `tipo_servico` separates consultation, follow-up, exam, session and assessment. Duration lives here, not on the type, because exams differ from each other |
| `preco_servico` | the private-pay price of a service, at a site, for a period | List prices change about once a year |
| `convenio` | one health insurer | Invoices are issued per insurer, which is why it is separate from the plan |
| `plano_convenio` | one plan of an insurer | Plan names are unique within their insurer |
| `preco_convenio` | what a plan pays for a service, at a site, for a period | Splits the amount into `valor_convenio` and `valor_coparticipacao`. No row means the plan does not cover that service |

## Patients

| Table | One row is | Notes |
|---|---|---|
| `canal_captacao` | one way of hearing about the clinic | A table rather than free text, so "Instagram" and "instagram" do not become two channels |
| `paciente` | one registered person | Address is split into components; `cpf` is unique; date of birth is stored instead of age |
| `paciente_plano` | one period in which the patient held a plan | Private-pay means no active row on that date. `numero_carteirinha` is required on insurer invoices — a typo here is a common rejection reason |

## Scheduling and visits

| Table | One row is | Notes |
|---|---|---|
| `atendimento` | one visit: the patient coming to the clinic on a given day | Holds the patient and the plan that applied, freezing them against later changes |
| `agendamento` | one scheduled procedure: professional, service, room, time slot | Carries the status, including no-shows and cancellations. Points at the original appointment when it is a reschedule |
| `pacote` | one prepaid package sold to a patient | Ten physiotherapy sessions, consumed over weeks. The expiry date is frozen at sale |
| `lista_espera` | one request to be slotted in | Does not occupy the schedule; the link to it appears only when the patient is fitted in |
| `encaminhamento` | one professional referring the patient to another | The destination appointment stays empty until the patient books, which is how referral conversion is measured |

## Money

| Table | One row is | Notes |
|---|---|---|
| `cobranca` | one amount owed by one payer | Co-payment produces two rows for the same procedure: one for the insurer, one for the patient. The amount is frozen at the time of the charge |
| `pagamento` | one patient transaction: a transfer, a card swipe | Payment method only; what it settles is in the next table |
| `pagamento_cobranca` | how much of a payment settled a given charge | One swipe can settle two charges, and one charge can be split across two methods |
| `parcela` | one receivable from a payment | Credit instalments, up to six. An empty `data_recebimento` means it has not cleared yet |
| `fatura_convenio` | the monthly invoice sent to an insurer by a site | One invoice per insurer, site and month. Totals are not stored — they are the sum of the items |
| `fatura_item` | one insurer charge inside an invoice | Holds the rejected amount and its reason. A charge can only be invoiced once |
| `motivo_glosa` | one rejection reason | Missing authorisation, service not covered, mistyped code — an open list the clinic extends |

## Clinical records — restricted access

These three tables are the only ones holding health data (LGPD art. 11). They are meant to live in a separate schema, with access limited to healthcare professionals; every other table can be exposed to reception and finance without leaking a diagnosis.

| Table | One row is | Notes |
|---|---|---|
| `prontuario` | the clinical record of one completed procedure | Per procedure rather than per visit, because each professional writes and signs their own |
| `cid` | one ICD-10 code | The official code is the primary key: it is stable and externally defined |
| `prontuario_cid` | one diagnosis recorded in a record | A record with two diagnoses has two rows; `tipo_diagnostico` marks the primary one |
