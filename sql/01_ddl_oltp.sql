-- SQL dump generated using DBML (dbml.dbdiagram.io)
-- Database: PostgreSQL
-- Generated at: 2026-09-17T19:51:38.687Z

CREATE TABLE "unidade" (
  "id_unidade" int PRIMARY KEY,
  "nome_unidade" varchar(50) UNIQUE NOT NULL,
  "endereco_unidade" varchar(150) NOT NULL,
  "bairro_unidade" varchar(50) NOT NULL,
  "cidade_unidade" varchar(50) NOT NULL
);

CREATE TABLE "sala" (
  "id_sala" int PRIMARY KEY,
  "id_unidade" int NOT NULL,
  "nome_sala" varchar(50) NOT NULL
);

CREATE TABLE "profissional" (
  "id_profissional" int PRIMARY KEY,
  "nome_profissional" varchar(150) NOT NULL,
  "formacao" varchar(50) NOT NULL,
  "numero_registro" varchar(20) UNIQUE NOT NULL
);

CREATE TABLE "especialidade" (
  "id_especialidade" int PRIMARY KEY,
  "nome_especialidade" varchar(80) UNIQUE NOT NULL
);

CREATE TABLE "profissional_especialidade" (
  "id_profissional" int NOT NULL,
  "id_especialidade" int NOT NULL,
  PRIMARY KEY ("id_especialidade", "id_profissional")
);

CREATE TABLE "agenda_profissional" (
  "id_agenda" int PRIMARY KEY,
  "id_profissional" int NOT NULL,
  "id_unidade" int NOT NULL,
  "dia_da_semana" int NOT NULL,
  "hora_inicio" time NOT NULL,
  "hora_fim" time NOT NULL,
  "vigencia_inicio" date NOT NULL,
  "vigencia_fim" date
);

CREATE TABLE "repasse_profissional" (
  "id_repasse" int PRIMARY KEY,
  "id_profissional" int NOT NULL,
  "percentual" decimal(5,2) NOT NULL CHECK (percentual between 0 and 100),
  "vigencia_inicio" date NOT NULL,
  "vigencia_fim" date
);

CREATE TABLE "servico" (
  "id_servico" int PRIMARY KEY,
  "nome_servico" varchar(50) UNIQUE NOT NULL,
  "tipo_servico" varchar(50) NOT NULL,
  "id_especialidade" int,
  "duracao_padrao_min" int NOT NULL
);

CREATE TABLE "preco_servico" (
  "id_preco_servico" int PRIMARY KEY,
  "id_servico" int NOT NULL,
  "id_unidade" int NOT NULL,
  "valor" decimal(10,2) NOT NULL,
  "vigencia_inicio" date NOT NULL,
  "vigencia_fim" date
);

CREATE TABLE "convenio" (
  "id_convenio" int PRIMARY KEY,
  "nome_convenio" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "plano_convenio" (
  "id_convenio" int NOT NULL,
  "id_plano" int PRIMARY KEY,
  "nome_plano" varchar(50) NOT NULL
);

CREATE TABLE "preco_convenio" (
  "id_preco_convenio" int PRIMARY KEY,
  "id_plano" int NOT NULL,
  "id_servico" int NOT NULL,
  "id_unidade" int NOT NULL,
  "valor_convenio" decimal(10,2) NOT NULL,
  "valor_coparticipacao" decimal(10,2) NOT NULL,
  "vigencia_inicio" date NOT NULL,
  "vigencia_fim" date
);

CREATE TABLE "canal_captacao" (
  "id_canal_captacao" int PRIMARY KEY,
  "nome_canal" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "paciente" (
  "id_paciente" int PRIMARY KEY,
  "nome_paciente" varchar(150) NOT NULL,
  "logradouro" varchar(150) NOT NULL,
  "numero" varchar(10) NOT NULL,
  "complemento" varchar(50),
  "cep" char(8) NOT NULL,
  "bairro" varchar(50),
  "cidade" varchar(50) NOT NULL,
  "uf" char(2) NOT NULL,
  "data_nascimento_paciente" date NOT NULL,
  "cpf" char(11) UNIQUE NOT NULL,
  "sexo" varchar(15) NOT NULL,
  "email" varchar(50),
  "telefone" varchar(20) NOT NULL,
  "id_canal_captacao" int NOT NULL,
  "data_cadastro" date NOT NULL
);

CREATE TABLE "paciente_plano" (
  "id_paciente_plano" int PRIMARY KEY,
  "id_paciente" int NOT NULL,
  "id_plano" int NOT NULL,
  "numero_carteirinha" varchar(30) NOT NULL,
  "data_inicio" date NOT NULL,
  "data_fim" date
);

CREATE TABLE "atendimento" (
  "id_atendimento" int PRIMARY KEY,
  "id_paciente_plano" int,
  "id_paciente" int NOT NULL,
  "data_atendimento" date NOT NULL
);

CREATE TABLE "pacote" (
  "id_pacote" int PRIMARY KEY,
  "id_paciente" int NOT NULL,
  "id_servico" int NOT NULL,
  "quantidade_sessoes" int NOT NULL,
  "valor_total_pago" decimal(10,2) NOT NULL,
  "data_compra" date NOT NULL,
  "data_expiracao" date NOT NULL
);

CREATE TABLE "agendamento" (
  "id_agendamento" int PRIMARY KEY,
  "id_atendimento" int NOT NULL,
  "id_profissional" int NOT NULL,
  "id_servico" int NOT NULL,
  "id_sala" int NOT NULL,
  "status" varchar(20) NOT NULL,
  "id_pacote" int,
  "id_agendamento_origem" int,
  "hora_inicio" time NOT NULL,
  "hora_fim" time NOT NULL,
  "data_marcacao" timestamp NOT NULL
);

CREATE TABLE "lista_espera" (
  "id_lista_espera" int PRIMARY KEY,
  "id_paciente" int NOT NULL,
  "id_servico" int NOT NULL,
  "id_unidade" int NOT NULL,
  "id_profissional" int,
  "data_inclusao_lista_espera" timestamp NOT NULL,
  "situacao" varchar(50) NOT NULL,
  "id_agendamento_gerado" int
);

CREATE TABLE "encaminhamento" (
  "id_encaminhamento" int PRIMARY KEY,
  "id_agendamento_origem" int NOT NULL,
  "id_profissional_destino" int NOT NULL,
  "id_agendamento_destino" int,
  "data_encaminhamento" timestamp NOT NULL
);

CREATE TABLE "cobranca" (
  "id_cobranca" int PRIMARY KEY,
  "id_agendamento" int,
  "id_pacote" int,
  "tipo_pagador" varchar(50) NOT NULL,
  "valor" decimal(10,2) NOT NULL,
  "data_cobranca" date NOT NULL
);

CREATE TABLE "pagamento" (
  "id_pagamento" int PRIMARY KEY,
  "forma_pagamento" varchar(15) NOT NULL,
  "valor" decimal(10,2) NOT NULL,
  "data_pagamento" date NOT NULL
);

CREATE TABLE "pagamento_cobranca" (
  "id_pagamento" int NOT NULL,
  "id_cobranca" int NOT NULL,
  "valor_aplicado" decimal(10,2) NOT NULL,
  PRIMARY KEY ("id_cobranca", "id_pagamento")
);

CREATE TABLE "parcela" (
  "id_parcela" int PRIMARY KEY,
  "id_pagamento" int NOT NULL,
  "valor_parcela" decimal(10,2) NOT NULL,
  "numero_parcela" int NOT NULL CHECK (numero_parcela between 1 and 6),
  "data_vencimento_parcela" date NOT NULL,
  "data_recebimento" date
);

CREATE TABLE "fatura_convenio" (
  "id_fatura" int PRIMARY KEY,
  "id_convenio" int NOT NULL,
  "id_unidade" int NOT NULL,
  "competencia" date NOT NULL,
  "data_envio" date NOT NULL,
  "data_recebimento" date,
  "valor_recebido" decimal(10,2)
);

CREATE TABLE "motivo_glosa" (
  "id_motivo_glosa" int PRIMARY KEY,
  "descricao_motivo" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "fatura_item" (
  "id_fatura_item" int PRIMARY KEY,
  "id_fatura" int NOT NULL,
  "id_cobranca" int UNIQUE NOT NULL,
  "valor_glosado" decimal(10,2) NOT NULL DEFAULT 0,
  "id_motivo_glosa" int
);

CREATE TABLE "prontuario" (
  "id_prontuario" int PRIMARY KEY,
  "id_agendamento" int UNIQUE NOT NULL,
  "queixa" varchar(150) NOT NULL,
  "conduta" varchar(150) NOT NULL,
  "data_registro" timestamp NOT NULL
);

CREATE TABLE "cid" (
  "codigo_cid" varchar(10) PRIMARY KEY,
  "descricao_cid" varchar(150) NOT NULL
);

CREATE TABLE "prontuario_cid" (
  "id_prontuario" int NOT NULL,
  "codigo_cid" varchar(10) NOT NULL,
  "tipo_diagnostico" varchar(50) NOT NULL,
  PRIMARY KEY ("id_prontuario", "codigo_cid")
);

CREATE UNIQUE INDEX ON "sala" ("id_unidade", "nome_sala");

CREATE UNIQUE INDEX ON "plano_convenio" ("id_convenio", "nome_plano");

CREATE UNIQUE INDEX ON "parcela" ("id_pagamento", "numero_parcela");

CREATE UNIQUE INDEX ON "fatura_convenio" ("id_convenio", "id_unidade", "competencia");

COMMENT ON TABLE "unidade" IS '1 linha = Uma unidade da clínica';

COMMENT ON TABLE "sala" IS '1 linha = Uma sala da clínica';

COMMENT ON TABLE "profissional" IS '1 linha = Uma pessoa que atende na clínica';

COMMENT ON TABLE "especialidade" IS '1 linha = Uma especialidade';

COMMENT ON TABLE "profissional_especialidade" IS '1 linha = O profissional tem uma especialidade. Se tiver mais de uma, aparecerá mais vezes';

COMMENT ON TABLE "agenda_profissional" IS '1 linha = Um bloco fixo: profissional, unidade, dia e horário';

COMMENT ON COLUMN "agenda_profissional"."dia_da_semana" IS '1=segunda ... 7=domingo';

COMMENT ON TABLE "repasse_profissional" IS '1 linha = Um percentual de repasse';

COMMENT ON COLUMN "repasse_profissional"."vigencia_fim" IS 'Vazio = vigente';

COMMENT ON TABLE "servico" IS '1 linha = Um item do catálogo de serviços';

COMMENT ON TABLE "preco_servico" IS '1 linha = Preço particular de um serviço, em uma unidade, em um período';

COMMENT ON COLUMN "preco_servico"."vigencia_fim" IS 'Vazio = preço atual';

COMMENT ON TABLE "convenio" IS '1 linha = Uma operadora';

COMMENT ON TABLE "plano_convenio" IS '1 linha = Um plano de um convênio';

COMMENT ON TABLE "preco_convenio" IS '1 linha = Quanto um plano paga por um serviço, em uma unidade, em um período';

COMMENT ON COLUMN "preco_convenio"."vigencia_fim" IS 'Vazio = valor atual';

COMMENT ON TABLE "canal_captacao" IS '1 linha = Uma forma de conhecer a clínica';

COMMENT ON TABLE "paciente" IS '1 linha = Uma pessoa cadastrada';

COMMENT ON TABLE "paciente_plano" IS '1 linha = Um período que o paciente teve um plano';

COMMENT ON COLUMN "paciente_plano"."data_fim" IS 'Vazio = plano ativo';

COMMENT ON TABLE "atendimento" IS '1 linha = Uma ida do paciente na clinica, a visita';

COMMENT ON TABLE "pacote" IS '1 linha = Um pacote de serviços vendido, por exemplo 10 sessões de fisioterapia';

COMMENT ON TABLE "agendamento" IS '1 linha = Um procedimento marcado';

COMMENT ON TABLE "lista_espera" IS '1 linha = Um pedido de encaixe';

COMMENT ON TABLE "encaminhamento" IS '1 linha = Um profissional indicado para o paciente';

COMMENT ON TABLE "cobranca" IS '1 linha = Um valor devido por um pagador';

COMMENT ON TABLE "pagamento" IS '1 linha = Uma transação';

COMMENT ON TABLE "pagamento_cobranca" IS '1 linha = Quanto do pagamento quitou a cobrança';

COMMENT ON TABLE "parcela" IS '1 linha = Valor a receber';

COMMENT ON TABLE "fatura_convenio" IS '1 linha = A conta mensal enviada a um convenio por uma unidade';

COMMENT ON TABLE "motivo_glosa" IS '1 linha = Um motivo de recusa do convênio';

COMMENT ON TABLE "fatura_item" IS '1 linha = Cobrança do convênio dentro de uma fatura';

COMMENT ON TABLE "prontuario" IS 'Acesso restrito. 1 linha = Registro clínico';

COMMENT ON TABLE "cid" IS '1 linha = Código do CID-10';

COMMENT ON TABLE "prontuario_cid" IS 'Acesso restrito. 1 linha = Diagnóstico registrado no prontuário';

ALTER TABLE "sala" ADD FOREIGN KEY ("id_unidade") REFERENCES "unidade" ("id_unidade") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "profissional_especialidade" ADD FOREIGN KEY ("id_profissional") REFERENCES "profissional" ("id_profissional") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "profissional_especialidade" ADD FOREIGN KEY ("id_especialidade") REFERENCES "especialidade" ("id_especialidade") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "agenda_profissional" ADD FOREIGN KEY ("id_profissional") REFERENCES "profissional" ("id_profissional") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "agenda_profissional" ADD FOREIGN KEY ("id_unidade") REFERENCES "unidade" ("id_unidade") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "repasse_profissional" ADD FOREIGN KEY ("id_profissional") REFERENCES "profissional" ("id_profissional") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "servico" ADD FOREIGN KEY ("id_especialidade") REFERENCES "especialidade" ("id_especialidade") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "preco_servico" ADD FOREIGN KEY ("id_servico") REFERENCES "servico" ("id_servico") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "preco_servico" ADD FOREIGN KEY ("id_unidade") REFERENCES "unidade" ("id_unidade") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "plano_convenio" ADD FOREIGN KEY ("id_convenio") REFERENCES "convenio" ("id_convenio") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "preco_convenio" ADD FOREIGN KEY ("id_plano") REFERENCES "plano_convenio" ("id_plano") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "preco_convenio" ADD FOREIGN KEY ("id_servico") REFERENCES "servico" ("id_servico") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "preco_convenio" ADD FOREIGN KEY ("id_unidade") REFERENCES "unidade" ("id_unidade") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "paciente" ADD FOREIGN KEY ("id_canal_captacao") REFERENCES "canal_captacao" ("id_canal_captacao") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "paciente_plano" ADD FOREIGN KEY ("id_paciente") REFERENCES "paciente" ("id_paciente") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "paciente_plano" ADD FOREIGN KEY ("id_plano") REFERENCES "plano_convenio" ("id_plano") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "atendimento" ADD FOREIGN KEY ("id_paciente_plano") REFERENCES "paciente_plano" ("id_paciente_plano") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "atendimento" ADD FOREIGN KEY ("id_paciente") REFERENCES "paciente" ("id_paciente") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "pacote" ADD FOREIGN KEY ("id_paciente") REFERENCES "paciente" ("id_paciente") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "pacote" ADD FOREIGN KEY ("id_servico") REFERENCES "servico" ("id_servico") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "agendamento" ADD FOREIGN KEY ("id_atendimento") REFERENCES "atendimento" ("id_atendimento") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "agendamento" ADD FOREIGN KEY ("id_profissional") REFERENCES "profissional" ("id_profissional") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "agendamento" ADD FOREIGN KEY ("id_servico") REFERENCES "servico" ("id_servico") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "agendamento" ADD FOREIGN KEY ("id_sala") REFERENCES "sala" ("id_sala") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "agendamento" ADD FOREIGN KEY ("id_pacote") REFERENCES "pacote" ("id_pacote") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "agendamento" ADD FOREIGN KEY ("id_agendamento_origem") REFERENCES "agendamento" ("id_agendamento") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "lista_espera" ADD FOREIGN KEY ("id_paciente") REFERENCES "paciente" ("id_paciente") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "lista_espera" ADD FOREIGN KEY ("id_servico") REFERENCES "servico" ("id_servico") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "lista_espera" ADD FOREIGN KEY ("id_unidade") REFERENCES "unidade" ("id_unidade") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "lista_espera" ADD FOREIGN KEY ("id_profissional") REFERENCES "profissional" ("id_profissional") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "lista_espera" ADD FOREIGN KEY ("id_agendamento_gerado") REFERENCES "agendamento" ("id_agendamento") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "encaminhamento" ADD FOREIGN KEY ("id_agendamento_origem") REFERENCES "agendamento" ("id_agendamento") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "encaminhamento" ADD FOREIGN KEY ("id_profissional_destino") REFERENCES "profissional" ("id_profissional") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "encaminhamento" ADD FOREIGN KEY ("id_agendamento_destino") REFERENCES "agendamento" ("id_agendamento") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "cobranca" ADD FOREIGN KEY ("id_agendamento") REFERENCES "agendamento" ("id_agendamento") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "cobranca" ADD FOREIGN KEY ("id_pacote") REFERENCES "pacote" ("id_pacote") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "pagamento_cobranca" ADD FOREIGN KEY ("id_pagamento") REFERENCES "pagamento" ("id_pagamento") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "pagamento_cobranca" ADD FOREIGN KEY ("id_cobranca") REFERENCES "cobranca" ("id_cobranca") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "parcela" ADD FOREIGN KEY ("id_pagamento") REFERENCES "pagamento" ("id_pagamento") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fatura_convenio" ADD FOREIGN KEY ("id_convenio") REFERENCES "convenio" ("id_convenio") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fatura_convenio" ADD FOREIGN KEY ("id_unidade") REFERENCES "unidade" ("id_unidade") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fatura_item" ADD FOREIGN KEY ("id_fatura") REFERENCES "fatura_convenio" ("id_fatura") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fatura_item" ADD FOREIGN KEY ("id_cobranca") REFERENCES "cobranca" ("id_cobranca") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "fatura_item" ADD FOREIGN KEY ("id_motivo_glosa") REFERENCES "motivo_glosa" ("id_motivo_glosa") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "prontuario" ADD FOREIGN KEY ("id_agendamento") REFERENCES "agendamento" ("id_agendamento") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "prontuario_cid" ADD FOREIGN KEY ("id_prontuario") REFERENCES "prontuario" ("id_prontuario") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "prontuario_cid" ADD FOREIGN KEY ("codigo_cid") REFERENCES "cid" ("codigo_cid") DEFERRABLE INITIALLY IMMEDIATE;
