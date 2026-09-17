# Glossary — Brazilian clinic vocabulary in English

The business case is Brazilian: private clinics here bill health insurers monthly, and those insurers routinely refuse part of what was billed. The model is written in English, so this page maps each term to the word the business actually uses in Portuguese — and to the standard term used in healthcare revenue-cycle systems.

## Business terms

| Portuguese | English | What it means |
|---|---|---|
| convênio | payer / health insurer | The company that covers part of the bill. Amil, Bradesco Saúde, SulAmérica |
| plano | plan | A tier inside a payer. Different tiers cover different services at different rates |
| particular | self-pay | The patient pays the full price directly; no payer involved |
| coparticipação | copay | The patient's share of a covered service. The payer covers R$ 120, the patient pays R$ 40 |
| faturamento | billing | Sending the month's covered services to the payer |
| **glosa** | **claim denial** | The part of an invoice the payer refuses to pay: missing authorisation, service not covered, mistyped code. The single most important term in this case |
| repasse | revenue share | The percentage of what a provider produces that is paid to them |
| prontuário | clinical note / medical record | Complaint, treatment plan and diagnoses of a completed procedure |
| CID-10 | ICD-10 | The international classification of diseases. Same standard, translated acronym |
| atendimento | encounter | One visit of a patient to the clinic on a given day |
| agendamento | appointment | One scheduled procedure inside a visit |
| falta / no-show | no-show | The patient did not appear and did not cancel |
| encaixe | fitting in from the waitlist | Filling a slot freed by a cancellation |
| encaminhamento | internal referral | One provider sending the patient to another inside the clinic |
| pacote de sessões | prepaid session package | Ten physiotherapy sessions, paid upfront, consumed over weeks |
| CPF | taxpayer ID | The Brazilian personal tax number, used as the patient's natural key |
| CRM, CRN, CREFITO, CRP, COREN | professional licence numbers | Registration with the council of each profession: physicians, dietitians, physiotherapists, psychologists, nurses |
| LGPD art. 11 | Brazilian data protection law, health data | Health data is a special category; access must be restricted by role |

## Table names

| Portuguese (design draft) | English (this repository) |
|---|---|
| unidade | `facility` |
| sala | `room` |
| profissional | `provider` |
| especialidade | `specialty` |
| profissional_especialidade | `provider_specialty` |
| agenda_profissional | `provider_schedule` |
| repasse_profissional | `provider_revenue_share` |
| servico | `service` |
| preco_servico | `service_price` |
| convenio | `payer` |
| plano_convenio | `payer_plan` |
| preco_convenio | `payer_contract_price` |
| canal_captacao | `acquisition_channel` |
| paciente | `patient` |
| paciente_plano | `patient_coverage` |
| atendimento | `encounter` |
| agendamento | `appointment` |
| pacote | `session_package` |
| lista_espera | `waitlist` |
| encaminhamento | `internal_referral` |
| cobranca | `charge` |
| pagamento | `payment` |
| pagamento_cobranca | `payment_allocation` |
| parcela | `installment` |
| fatura_convenio | `payer_invoice` |
| fatura_item | `invoice_line` |
| motivo_glosa | `denial_reason` |
| prontuario | `clinical_note` |
| cid | `icd10` |
| prontuario_cid | `clinical_note_diagnosis` |

The model was first drafted in Portuguese, against a brief written in Portuguese, and then renamed. The structure did not change in the translation: same 30 tables, same keys, same relationships.
