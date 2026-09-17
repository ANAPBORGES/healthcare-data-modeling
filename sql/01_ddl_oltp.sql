-- SQL dump generated using DBML (dbml.dbdiagram.io)
-- Database: PostgreSQL
-- Generated at: 2026-09-17T20:28:52.834Z

CREATE TABLE "facility" (
  "facility_id" int PRIMARY KEY,
  "facility_name" varchar(50) UNIQUE NOT NULL,
  "street_address" varchar(150) NOT NULL,
  "district" varchar(50) NOT NULL,
  "city" varchar(50) NOT NULL
);

CREATE TABLE "room" (
  "room_id" int PRIMARY KEY,
  "facility_id" int NOT NULL,
  "room_name" varchar(50) NOT NULL
);

CREATE TABLE "provider" (
  "provider_id" int PRIMARY KEY,
  "provider_name" varchar(150) NOT NULL,
  "profession" varchar(50) NOT NULL,
  "license_number" varchar(20) UNIQUE NOT NULL
);

CREATE TABLE "specialty" (
  "specialty_id" int PRIMARY KEY,
  "specialty_name" varchar(80) UNIQUE NOT NULL
);

CREATE TABLE "provider_specialty" (
  "provider_id" int NOT NULL,
  "specialty_id" int NOT NULL,
  PRIMARY KEY ("specialty_id", "provider_id")
);

CREATE TABLE "provider_schedule" (
  "schedule_id" int PRIMARY KEY,
  "provider_id" int NOT NULL,
  "facility_id" int NOT NULL,
  "weekday" int NOT NULL,
  "start_time" time NOT NULL,
  "end_time" time NOT NULL,
  "valid_from" date NOT NULL,
  "valid_to" date
);

CREATE TABLE "provider_revenue_share" (
  "revenue_share_id" int PRIMARY KEY,
  "provider_id" int NOT NULL,
  "share_pct" decimal(5,2) NOT NULL CHECK (share_pct between 0 and 100),
  "valid_from" date NOT NULL,
  "valid_to" date
);

CREATE TABLE "service" (
  "service_id" int PRIMARY KEY,
  "service_name" varchar(50) UNIQUE NOT NULL,
  "service_type" varchar(50) NOT NULL,
  "specialty_id" int,
  "default_duration_min" int NOT NULL
);

CREATE TABLE "service_price" (
  "service_price_id" int PRIMARY KEY,
  "service_id" int NOT NULL,
  "facility_id" int NOT NULL,
  "amount" decimal(10,2) NOT NULL,
  "valid_from" date NOT NULL,
  "valid_to" date
);

CREATE TABLE "payer" (
  "payer_id" int PRIMARY KEY,
  "payer_name" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "payer_plan" (
  "payer_id" int NOT NULL,
  "plan_id" int PRIMARY KEY,
  "plan_name" varchar(50) NOT NULL
);

CREATE TABLE "payer_contract_price" (
  "contract_price_id" int PRIMARY KEY,
  "plan_id" int NOT NULL,
  "service_id" int NOT NULL,
  "facility_id" int NOT NULL,
  "payer_amount" decimal(10,2) NOT NULL,
  "copay_amount" decimal(10,2) NOT NULL,
  "valid_from" date NOT NULL,
  "valid_to" date
);

CREATE TABLE "acquisition_channel" (
  "channel_id" int PRIMARY KEY,
  "channel_name" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "patient" (
  "patient_id" int PRIMARY KEY,
  "patient_name" varchar(150) NOT NULL,
  "street" varchar(150) NOT NULL,
  "street_number" varchar(10) NOT NULL,
  "address_complement" varchar(50),
  "postal_code" char(8) NOT NULL,
  "district" varchar(50),
  "city" varchar(50) NOT NULL,
  "state" char(2) NOT NULL,
  "birth_date" date NOT NULL,
  "tax_id" char(11) UNIQUE NOT NULL,
  "sex" varchar(15) NOT NULL,
  "email" varchar(50),
  "phone" varchar(20) NOT NULL,
  "channel_id" int NOT NULL,
  "registered_at" date NOT NULL
);

CREATE TABLE "patient_coverage" (
  "coverage_id" int PRIMARY KEY,
  "patient_id" int NOT NULL,
  "plan_id" int NOT NULL,
  "member_number" varchar(30) NOT NULL,
  "valid_from" date NOT NULL,
  "valid_to" date
);

CREATE TABLE "encounter" (
  "encounter_id" int PRIMARY KEY,
  "coverage_id" int,
  "patient_id" int NOT NULL,
  "encounter_date" date NOT NULL
);

CREATE TABLE "session_package" (
  "package_id" int PRIMARY KEY,
  "patient_id" int NOT NULL,
  "service_id" int NOT NULL,
  "session_count" int NOT NULL,
  "amount_paid" decimal(10,2) NOT NULL,
  "purchase_date" date NOT NULL,
  "expires_on" date NOT NULL
);

CREATE TABLE "appointment" (
  "appointment_id" int PRIMARY KEY,
  "encounter_id" int NOT NULL,
  "provider_id" int NOT NULL,
  "service_id" int NOT NULL,
  "room_id" int NOT NULL,
  "status" varchar(20) NOT NULL,
  "package_id" int,
  "rescheduled_from_id" int,
  "start_time" time NOT NULL,
  "end_time" time NOT NULL,
  "booked_at" timestamp NOT NULL
);

CREATE TABLE "waitlist" (
  "waitlist_id" int PRIMARY KEY,
  "patient_id" int NOT NULL,
  "service_id" int NOT NULL,
  "facility_id" int NOT NULL,
  "provider_id" int,
  "requested_at" timestamp NOT NULL,
  "status" varchar(50) NOT NULL,
  "fulfilled_appointment_id" int
);

CREATE TABLE "internal_referral" (
  "referral_id" int PRIMARY KEY,
  "source_appointment_id" int NOT NULL,
  "target_provider_id" int NOT NULL,
  "target_appointment_id" int,
  "referred_at" timestamp NOT NULL
);

CREATE TABLE "charge" (
  "charge_id" int PRIMARY KEY,
  "appointment_id" int,
  "package_id" int,
  "payer_type" varchar(50) NOT NULL,
  "amount" decimal(10,2) NOT NULL,
  "charged_on" date NOT NULL
);

CREATE TABLE "payment" (
  "payment_id" int PRIMARY KEY,
  "payment_method" varchar(15) NOT NULL,
  "amount" decimal(10,2) NOT NULL,
  "paid_on" date NOT NULL
);

CREATE TABLE "payment_allocation" (
  "payment_id" int NOT NULL,
  "charge_id" int NOT NULL,
  "allocated_amount" decimal(10,2) NOT NULL,
  PRIMARY KEY ("charge_id", "payment_id")
);

CREATE TABLE "installment" (
  "installment_id" int PRIMARY KEY,
  "payment_id" int NOT NULL,
  "amount" decimal(10,2) NOT NULL,
  "installment_number" int NOT NULL CHECK (installment_number between 1 and 6),
  "due_date" date NOT NULL,
  "settled_on" date
);

CREATE TABLE "payer_invoice" (
  "invoice_id" int PRIMARY KEY,
  "payer_id" int NOT NULL,
  "facility_id" int NOT NULL,
  "billing_period" date NOT NULL,
  "submitted_on" date NOT NULL,
  "paid_on" date,
  "amount_received" decimal(10,2)
);

CREATE TABLE "denial_reason" (
  "denial_reason_id" int PRIMARY KEY,
  "reason_description" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "invoice_line" (
  "invoice_line_id" int PRIMARY KEY,
  "invoice_id" int NOT NULL,
  "charge_id" int UNIQUE NOT NULL,
  "denied_amount" decimal(10,2) NOT NULL DEFAULT 0,
  "denial_reason_id" int
);

CREATE TABLE "clinical_note" (
  "note_id" int PRIMARY KEY,
  "appointment_id" int UNIQUE NOT NULL,
  "chief_complaint" varchar(150) NOT NULL,
  "treatment_plan" varchar(150) NOT NULL,
  "recorded_at" timestamp NOT NULL
);

CREATE TABLE "icd10" (
  "icd10_code" varchar(10) PRIMARY KEY,
  "icd10_description" varchar(150) NOT NULL
);

CREATE TABLE "clinical_note_diagnosis" (
  "note_id" int NOT NULL,
  "icd10_code" varchar(10) NOT NULL,
  "diagnosis_type" varchar(50) NOT NULL,
  PRIMARY KEY ("note_id", "icd10_code")
);

CREATE UNIQUE INDEX ON "room" ("facility_id", "room_name");

CREATE UNIQUE INDEX ON "payer_plan" ("payer_id", "plan_name");

CREATE UNIQUE INDEX ON "installment" ("payment_id", "installment_number");

CREATE UNIQUE INDEX ON "payer_invoice" ("payer_id", "facility_id", "billing_period");

COMMENT ON TABLE "facility" IS '1 row = one clinic site';

COMMENT ON TABLE "room" IS '1 row = one physical room inside a site';

COMMENT ON TABLE "provider" IS '1 row = one person who treats patients';

COMMENT ON COLUMN "provider"."profession" IS 'physician, dietitian, physiotherapist, psychologist, nurse';

COMMENT ON COLUMN "provider"."license_number" IS 'CRM, CRN, CREFITO, CRP, COREN: the natural key';

COMMENT ON TABLE "specialty" IS '1 row = one specialty';

COMMENT ON TABLE "provider_specialty" IS '1 row = this provider holds this specialty. Two specialties, two rows';

COMMENT ON TABLE "provider_schedule" IS '1 row = one weekly block: provider, site, weekday and time window';

COMMENT ON COLUMN "provider_schedule"."facility_id" IS 'The only place that says where a provider works';

COMMENT ON COLUMN "provider_schedule"."weekday" IS '1=Monday ... 7=Sunday';

COMMENT ON COLUMN "provider_schedule"."valid_to" IS 'Empty = still in force';

COMMENT ON TABLE "provider_revenue_share" IS '1 row = one revenue-share percentage valid for a period';

COMMENT ON COLUMN "provider_revenue_share"."valid_from" IS 'May payout uses the share in force in May, not today';

COMMENT ON COLUMN "provider_revenue_share"."valid_to" IS 'Empty = current';

COMMENT ON TABLE "service" IS '1 row = one catalogue item';

COMMENT ON COLUMN "service"."service_type" IS 'consultation, follow_up, exam, session, assessment';

COMMENT ON COLUMN "service"."specialty_id" IS 'Empty for exams, which have no specialty';

COMMENT ON COLUMN "service"."default_duration_min" IS 'Minutes. On the service, not the type: ultrasound and blood work differ';

COMMENT ON TABLE "service_price" IS '1 row = self-pay price of a service, at a site, for a period';

COMMENT ON COLUMN "service_price"."valid_to" IS 'Empty = current price. List prices change about once a year';

COMMENT ON TABLE "payer" IS '1 row = one health insurer. Separate from plan because invoices are issued per payer';

COMMENT ON TABLE "payer_plan" IS '1 row = one plan of a payer';

COMMENT ON TABLE "payer_contract_price" IS '1 row = what a plan pays for a service, at a site, for a period. No row = service not covered';

COMMENT ON COLUMN "payer_contract_price"."payer_amount" IS 'The share the payer covers';

COMMENT ON COLUMN "payer_contract_price"."copay_amount" IS 'The share the patient pays. Zero when the plan has no copay';

COMMENT ON COLUMN "payer_contract_price"."valid_to" IS 'Empty = current';

COMMENT ON TABLE "acquisition_channel" IS '1 row = one way of hearing about the clinic';

COMMENT ON COLUMN "acquisition_channel"."channel_name" IS 'A table, not free text, so Instagram and instagram do not become two channels';

COMMENT ON TABLE "patient" IS '1 row = one registered person. Address split into parts: one value per column';

COMMENT ON COLUMN "patient"."street_number" IS 'Text, not number: 120-A and no-number addresses exist';

COMMENT ON COLUMN "patient"."birth_date" IS 'The date, never the age: age changes every year';

COMMENT ON COLUMN "patient"."tax_id" IS 'CPF, the Brazilian taxpayer ID. Natural key: blocks duplicate registration';

COMMENT ON COLUMN "patient"."registered_at" IS 'First visit. Basis for new vs returning patient';

COMMENT ON TABLE "patient_coverage" IS '1 row = one period in which the patient held a plan. Self-pay = no active row on that date';

COMMENT ON COLUMN "patient_coverage"."coverage_id" IS 'Own key because the same patient may hold the same plan in two separate periods';

COMMENT ON COLUMN "patient_coverage"."member_number" IS 'Required on payer invoices. Mistyped here, it becomes a denial';

COMMENT ON COLUMN "patient_coverage"."valid_to" IS 'Empty = coverage active today';

COMMENT ON TABLE "encounter" IS '1 row = one visit: the patient coming to the clinic on a given day';

COMMENT ON COLUMN "encounter"."coverage_id" IS 'Empty = self-pay. Freezes the plan: a later switch does not rewrite this visit';

COMMENT ON COLUMN "encounter"."patient_id" IS 'The patient lives here, and only here';

COMMENT ON COLUMN "encounter"."encounter_date" IS 'The day of the visit. Every procedure in it happens on this day';

COMMENT ON TABLE "session_package" IS '1 row = one prepaid package sold to a patient';

COMMENT ON COLUMN "session_package"."patient_id" IS 'The package belongs to the patient, not to a visit: it is used across several';

COMMENT ON COLUMN "session_package"."session_count" IS '10 today. A column, not a constant, in case a 5-session package appears';

COMMENT ON COLUMN "session_package"."expires_on" IS 'Purchase + 6 months, frozen at sale: a rule change does not shorten packages already sold';

COMMENT ON TABLE "appointment" IS '1 row = one scheduled procedure: provider, service, room and time slot';

COMMENT ON COLUMN "appointment"."encounter_id" IS 'Consultation + blood work + ultrasound = 3 rows sharing one encounter';

COMMENT ON COLUMN "appointment"."room_id" IS 'The site is reached through the room';

COMMENT ON COLUMN "appointment"."status" IS 'scheduled, confirmed, completed, cancelled_patient, cancelled_clinic, rescheduled, no_show';

COMMENT ON COLUMN "appointment"."package_id" IS 'Set only when the session comes from a package. Balance = sessions minus completed ones';

COMMENT ON COLUMN "appointment"."rescheduled_from_id" IS 'Set when this is a reschedule: points at the original, which carries status rescheduled';

COMMENT ON COLUMN "appointment"."booked_at" IS 'When reception recorded it. Measures the wait between booking and visit';

COMMENT ON TABLE "waitlist" IS '1 row = one request to be fitted in. Holds no slot of its own';

COMMENT ON COLUMN "waitlist"."patient_id" IS 'The patient comes straight in here, because no visit exists yet';

COMMENT ON COLUMN "waitlist"."provider_id" IS 'Empty = any provider will do';

COMMENT ON COLUMN "waitlist"."requested_at" IS 'Sets who gets called first';

COMMENT ON COLUMN "waitlist"."status" IS 'waiting, scheduled, withdrawn';

COMMENT ON COLUMN "waitlist"."fulfilled_appointment_id" IS 'Empty until the patient is fitted into a cancellation';

COMMENT ON TABLE "internal_referral" IS '1 row = one provider referring the patient to another inside the clinic';

COMMENT ON COLUMN "internal_referral"."source_appointment_id" IS 'Where the referral was made. Provider and patient come from it';

COMMENT ON COLUMN "internal_referral"."target_appointment_id" IS 'Empty until the patient books. Filled = the referral converted';

COMMENT ON TABLE "charge" IS '1 row = one amount owed by one payer';

COMMENT ON COLUMN "charge"."package_id" IS 'Exactly one of appointment_id and package_id is filled';

COMMENT ON COLUMN "charge"."payer_type" IS 'patient or payer. Splits the same procedure into the insurer share and the copay: two rows';

COMMENT ON COLUMN "charge"."amount" IS 'The amount actually charged, frozen: price tables change and discounts happen';

COMMENT ON TABLE "payment" IS '1 row = one patient transaction: a transfer, a card swipe';

COMMENT ON COLUMN "payment"."payment_method" IS 'cash, pix, debit, credit';

COMMENT ON TABLE "payment_allocation" IS '1 row = how much of a payment settled a given charge. One swipe can settle two charges, and one charge can be split across methods';

COMMENT ON TABLE "installment" IS '1 row = one receivable. Cash, debit and transfers have a single one';

COMMENT ON COLUMN "installment"."due_date" IS 'When the card processor transfers the money';

COMMENT ON COLUMN "installment"."settled_on" IS 'Empty = has not cleared yet';

COMMENT ON TABLE "payer_invoice" IS '1 row = the monthly invoice sent to a payer by a site';

COMMENT ON COLUMN "payer_invoice"."billing_period" IS 'Reference month, stored as its first day';

COMMENT ON COLUMN "payer_invoice"."paid_on" IS 'Empty = still open. Measures the 30 to 90 day lag';

COMMENT ON COLUMN "payer_invoice"."amount_received" IS 'What actually landed in the account: a bank fact, not a calculation. Billed and denied are the sum of the lines';

COMMENT ON TABLE "denial_reason" IS '1 row = one reason a payer refused to pay';

COMMENT ON COLUMN "denial_reason"."reason_description" IS 'Missing authorisation, service not covered, mistyped code';

COMMENT ON TABLE "invoice_line" IS '1 row = one payer charge inside an invoice';

COMMENT ON COLUMN "invoice_line"."charge_id" IS 'Payer charges only. Unique: a charge cannot be invoiced twice';

COMMENT ON COLUMN "invoice_line"."denied_amount" IS 'Zero = paid in full. The billed amount is the charge amount';

COMMENT ON COLUMN "invoice_line"."denial_reason_id" IS 'Empty when nothing was denied';

COMMENT ON TABLE "clinical_note" IS 'Restricted access. 1 row = the clinical record of one completed procedure';

COMMENT ON COLUMN "clinical_note"."appointment_id" IS 'One note per completed procedure: each provider writes and signs their own';

COMMENT ON COLUMN "clinical_note"."recorded_at" IS 'May be written after the procedure';

COMMENT ON TABLE "icd10" IS '1 row = one ICD-10 code';

COMMENT ON COLUMN "icd10"."icd10_code" IS 'The natural key is the PK: E03.9 is an official, stable code';

COMMENT ON TABLE "clinical_note_diagnosis" IS 'Restricted access. 1 row = one diagnosis recorded in a note';

COMMENT ON COLUMN "clinical_note_diagnosis"."diagnosis_type" IS 'primary or secondary. The text of the diagnosis already lives in icd10';

ALTER TABLE "room" ADD FOREIGN KEY ("facility_id") REFERENCES "facility" ("facility_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "provider_specialty" ADD FOREIGN KEY ("provider_id") REFERENCES "provider" ("provider_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "provider_specialty" ADD FOREIGN KEY ("specialty_id") REFERENCES "specialty" ("specialty_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "provider_schedule" ADD FOREIGN KEY ("provider_id") REFERENCES "provider" ("provider_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "provider_schedule" ADD FOREIGN KEY ("facility_id") REFERENCES "facility" ("facility_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "provider_revenue_share" ADD FOREIGN KEY ("provider_id") REFERENCES "provider" ("provider_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "service" ADD FOREIGN KEY ("specialty_id") REFERENCES "specialty" ("specialty_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "service_price" ADD FOREIGN KEY ("service_id") REFERENCES "service" ("service_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "service_price" ADD FOREIGN KEY ("facility_id") REFERENCES "facility" ("facility_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payer_plan" ADD FOREIGN KEY ("payer_id") REFERENCES "payer" ("payer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payer_contract_price" ADD FOREIGN KEY ("plan_id") REFERENCES "payer_plan" ("plan_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payer_contract_price" ADD FOREIGN KEY ("service_id") REFERENCES "service" ("service_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payer_contract_price" ADD FOREIGN KEY ("facility_id") REFERENCES "facility" ("facility_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "patient" ADD FOREIGN KEY ("channel_id") REFERENCES "acquisition_channel" ("channel_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "patient_coverage" ADD FOREIGN KEY ("patient_id") REFERENCES "patient" ("patient_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "patient_coverage" ADD FOREIGN KEY ("plan_id") REFERENCES "payer_plan" ("plan_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "encounter" ADD FOREIGN KEY ("coverage_id") REFERENCES "patient_coverage" ("coverage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "encounter" ADD FOREIGN KEY ("patient_id") REFERENCES "patient" ("patient_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "session_package" ADD FOREIGN KEY ("patient_id") REFERENCES "patient" ("patient_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "session_package" ADD FOREIGN KEY ("service_id") REFERENCES "service" ("service_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "appointment" ADD FOREIGN KEY ("encounter_id") REFERENCES "encounter" ("encounter_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "appointment" ADD FOREIGN KEY ("provider_id") REFERENCES "provider" ("provider_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "appointment" ADD FOREIGN KEY ("service_id") REFERENCES "service" ("service_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "appointment" ADD FOREIGN KEY ("room_id") REFERENCES "room" ("room_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "appointment" ADD FOREIGN KEY ("package_id") REFERENCES "session_package" ("package_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "appointment" ADD FOREIGN KEY ("rescheduled_from_id") REFERENCES "appointment" ("appointment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "waitlist" ADD FOREIGN KEY ("patient_id") REFERENCES "patient" ("patient_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "waitlist" ADD FOREIGN KEY ("service_id") REFERENCES "service" ("service_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "waitlist" ADD FOREIGN KEY ("facility_id") REFERENCES "facility" ("facility_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "waitlist" ADD FOREIGN KEY ("provider_id") REFERENCES "provider" ("provider_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "waitlist" ADD FOREIGN KEY ("fulfilled_appointment_id") REFERENCES "appointment" ("appointment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "internal_referral" ADD FOREIGN KEY ("source_appointment_id") REFERENCES "appointment" ("appointment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "internal_referral" ADD FOREIGN KEY ("target_provider_id") REFERENCES "provider" ("provider_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "internal_referral" ADD FOREIGN KEY ("target_appointment_id") REFERENCES "appointment" ("appointment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "charge" ADD FOREIGN KEY ("appointment_id") REFERENCES "appointment" ("appointment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "charge" ADD FOREIGN KEY ("package_id") REFERENCES "session_package" ("package_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payment_allocation" ADD FOREIGN KEY ("payment_id") REFERENCES "payment" ("payment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payment_allocation" ADD FOREIGN KEY ("charge_id") REFERENCES "charge" ("charge_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "installment" ADD FOREIGN KEY ("payment_id") REFERENCES "payment" ("payment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payer_invoice" ADD FOREIGN KEY ("payer_id") REFERENCES "payer" ("payer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payer_invoice" ADD FOREIGN KEY ("facility_id") REFERENCES "facility" ("facility_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoice_line" ADD FOREIGN KEY ("invoice_id") REFERENCES "payer_invoice" ("invoice_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoice_line" ADD FOREIGN KEY ("charge_id") REFERENCES "charge" ("charge_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoice_line" ADD FOREIGN KEY ("denial_reason_id") REFERENCES "denial_reason" ("denial_reason_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "clinical_note" ADD FOREIGN KEY ("appointment_id") REFERENCES "appointment" ("appointment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "clinical_note_diagnosis" ADD FOREIGN KEY ("note_id") REFERENCES "clinical_note" ("note_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "clinical_note_diagnosis" ADD FOREIGN KEY ("icd10_code") REFERENCES "icd10" ("icd10_code") DEFERRABLE INITIALLY IMMEDIATE;
