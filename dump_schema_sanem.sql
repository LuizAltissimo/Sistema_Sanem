

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."user_role_enum" AS ENUM (
    'superadmin',
    'admin',
    'voluntario'
);


ALTER TYPE "public"."user_role_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."audit_users_changes"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM public.log_audit_event('users', 'INSERT', NULL, to_jsonb(NEW), NEW.id);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        PERFORM public.log_audit_event('users', 'UPDATE', to_jsonb(OLD), to_jsonb(NEW), NEW.id);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM public.log_audit_event('users', 'DELETE', to_jsonb(OLD), NULL, OLD.id);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."audit_users_changes"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_user_dependencies"("user_id_param" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    dependencies jsonb := '{}';
    count_val integer;
BEGIN
    -- Verificar benefici├írios criados pelo usu├írio
    SELECT COUNT(*) INTO count_val FROM public.beneficiarios WHERE created_by = user_id_param;
    IF count_val > 0 THEN
        dependencies := jsonb_set(dependencies, '{beneficiarios}', to_jsonb(count_val));
    END IF;
    
    -- Verificar doa├º├Áes criadas pelo usu├írio
    SELECT COUNT(*) INTO count_val FROM public.doacoes WHERE created_by = user_id_param;
    IF count_val > 0 THEN
        dependencies := jsonb_set(dependencies, '{doacoes}', to_jsonb(count_val));
    END IF;
    
    -- Verificar distribui├º├Áes criadas pelo usu├írio
    SELECT COUNT(*) INTO count_val FROM public.distribuicoes WHERE created_by = user_id_param;
    IF count_val > 0 THEN
        dependencies := jsonb_set(dependencies, '{distribuicoes}', to_jsonb(count_val));
    END IF;
    
    -- Verificar movimenta├º├Áes de estoque criadas pelo usu├írio
    SELECT COUNT(*) INTO count_val FROM public.movimentacoes_estoque WHERE created_by = user_id_param;
    IF count_val > 0 THEN
        dependencies := jsonb_set(dependencies, '{movimentacoes_estoque}', to_jsonb(count_val));
    END IF;
    
    RETURN dependencies;
END;
$$;


ALTER FUNCTION "public"."check_user_dependencies"("user_id_param" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_audit_event"("p_table_name" "text", "p_operation" "text", "p_old_data" "jsonb" DEFAULT NULL::"jsonb", "p_new_data" "jsonb" DEFAULT NULL::"jsonb", "p_user_id" "uuid" DEFAULT NULL::"uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    INSERT INTO public.audit_logs (
        table_name,
        operation,
        old_data,
        new_data,
        user_id,
        timestamp
    ) VALUES (
        p_table_name,
        p_operation,
        p_old_data,
        p_new_data,
        COALESCE(p_user_id, auth.uid()),
        NOW()
    );
END;
$$;


ALTER FUNCTION "public"."log_audit_event"("p_table_name" "text", "p_operation" "text", "p_old_data" "jsonb", "p_new_data" "jsonb", "p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_user_deletion"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
    INSERT INTO public.audit_logs (
        table_name,
        operation,
        old_data,
        user_id,
        timestamp
    ) VALUES (
        'users',
        'DELETE',
        to_jsonb(OLD),
        OLD.id,
        NOW()
    );
    RETURN OLD;
END;
$$;


ALTER FUNCTION "public"."log_user_deletion"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."safe_delete_user"("user_id_param" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    dependencies jsonb;
    result jsonb;
BEGIN
    -- Verificar depend├¬ncias
    dependencies := public.check_user_dependencies(user_id_param);
    
    -- Se houver depend├¬ncias, retornar erro
    IF dependencies != '{}' THEN
        result := jsonb_build_object(
            'success', false,
            'message', 'Usu├írio possui depend├¬ncias que impedem a exclus├úo',
            'dependencies', dependencies
        );
        RETURN result;
    END IF;
    
    -- Se n├úo houver depend├¬ncias, deletar o usu├írio
    DELETE FROM public.users WHERE id = user_id_param;
    
    -- Retornar sucesso
    result := jsonb_build_object(
        'success', true,
        'message', 'Usu├írio exclu├¡do com sucesso'
    );
    RETURN result;
END;
$$;


ALTER FUNCTION "public"."safe_delete_user"("user_id_param" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_configuracoes_updated_by_name"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    NEW.updated_by_name := (
        SELECT nome_completo 
        FROM public.users 
        WHERE id = NEW.updated_by
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_configuracoes_updated_by_name"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_created_by_name"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    NEW.created_by_name := (
        SELECT nome_completo 
        FROM public.users 
        WHERE id = NEW.created_by
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_created_by_name"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."atividades_sistema" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "acao" character varying(255) NOT NULL,
    "recurso" character varying(100) NOT NULL,
    "recurso_id" "uuid",
    "detalhes" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."atividades_sistema" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."audit_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "action" "text" NOT NULL,
    "resource" "text" NOT NULL,
    "resource_id" "text",
    "timestamp" timestamp with time zone DEFAULT "now"(),
    "ip_address" "inet",
    "user_agent" "text",
    "details" "jsonb"
);


ALTER TABLE "public"."audit_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."beneficiarios" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" character varying(255) NOT NULL,
    "cpf" character varying(11) NOT NULL,
    "telefone" character varying(20),
    "email" character varying(255),
    "endereco" "text",
    "data_nascimento" "date",
    "numero_dependentes" integer DEFAULT 0,
    "status" character varying(50) DEFAULT 'Ativo'::character varying,
    "limite_mensal_real" numeric(10,2) DEFAULT 10.00,
    "limite_usado_atual" numeric(10,2) DEFAULT 0.00,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "created_by_name" character varying(255),
    CONSTRAINT "beneficiarios_status_check" CHECK ((("status")::"text" = ANY (ARRAY[('Ativo'::character varying)::"text", ('Inativo'::character varying)::"text", ('Limite Atingido'::character varying)::"text"])))
);


ALTER TABLE "public"."beneficiarios" OWNER TO "postgres";


COMMENT ON COLUMN "public"."beneficiarios"."limite_mensal_real" IS 'Limite mensal de itens que o benefici├írio pode retirar (quantidade)';



COMMENT ON COLUMN "public"."beneficiarios"."limite_usado_atual" IS 'Quantidade de itens j├í retirados no m├¬s atual';



CREATE TABLE IF NOT EXISTS "public"."categorias_produtos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" character varying(100) NOT NULL,
    "descricao" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."categorias_produtos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."configuracoes_sistema" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "chave" character varying(100) NOT NULL,
    "valor" "text" NOT NULL,
    "descricao" "text",
    "tipo" character varying(50) DEFAULT 'text'::character varying,
    "categoria" character varying(50) DEFAULT 'geral'::character varying,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by_name" character varying(255),
    CONSTRAINT "configuracoes_sistema_tipo_check" CHECK ((("tipo")::"text" = ANY (ARRAY[('text'::character varying)::"text", ('number'::character varying)::"text", ('boolean'::character varying)::"text", ('json'::character varying)::"text"])))
);


ALTER TABLE "public"."configuracoes_sistema" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."dependentes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "beneficiario_id" "uuid",
    "nome" character varying(255) NOT NULL,
    "data_nascimento" "date",
    "parentesco" character varying(100),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."dependentes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."distribuicoes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "beneficiario_id" "uuid",
    "data_distribuicao" "date" NOT NULL,
    "valor_total" numeric(10,2),
    "status" character varying(50) DEFAULT 'Pendente'::character varying,
    "observacoes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "created_by_name" character varying(255),
    CONSTRAINT "distribuicoes_status_check" CHECK ((("status")::"text" = ANY (ARRAY[('Pendente'::character varying)::"text", ('Conclu├¡da'::character varying)::"text", ('Cancelada'::character varying)::"text"])))
);


ALTER TABLE "public"."distribuicoes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."doacoes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "doador_id" "uuid",
    "data_doacao" "date" NOT NULL,
    "valor_total" numeric(10,2),
    "tipo_doacao" character varying(50),
    "status" character varying(50) DEFAULT 'Pendente'::character varying,
    "observacoes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "created_by_name" character varying(255),
    CONSTRAINT "doacoes_status_check" CHECK ((("status")::"text" = ANY (ARRAY[('Pendente'::character varying)::"text", ('Processada'::character varying)::"text", ('Cancelada'::character varying)::"text"]))),
    CONSTRAINT "doacoes_tipo_doacao_check" CHECK ((("tipo_doacao")::"text" = ANY (ARRAY[('Dinheiro'::character varying)::"text", ('Produtos'::character varying)::"text", ('Mista'::character varying)::"text"])))
);


ALTER TABLE "public"."doacoes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."doadores" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" character varying(255) NOT NULL,
    "tipo" character varying(50),
    "cpf_cnpj" character varying(18),
    "telefone" character varying(20),
    "email" character varying(255),
    "endereco" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "doadores_tipo_check" CHECK ((("tipo")::"text" = ANY (ARRAY[('Pessoa F├¡sica'::character varying)::"text", ('Pessoa Jur├¡dica'::character varying)::"text", ('Empresa'::character varying)::"text", ('Organiza├º├úo'::character varying)::"text"])))
);


ALTER TABLE "public"."doadores" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."itens_distribuicao" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "distribuicao_id" "uuid",
    "produto_id" "uuid",
    "quantidade" integer NOT NULL,
    "valor_unitario" numeric(10,2),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."itens_distribuicao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."itens_doacao" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "doacao_id" "uuid",
    "produto_id" "uuid",
    "quantidade" integer NOT NULL,
    "valor_unitario" numeric(10,2),
    "observacoes" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."itens_doacao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."movimentacoes_estoque" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "produto_id" "uuid",
    "tipo_movimentacao" character varying(50),
    "quantidade" integer NOT NULL,
    "quantidade_anterior" integer,
    "quantidade_nova" integer,
    "motivo" character varying(100),
    "referencia_id" "uuid",
    "referencia_tipo" character varying(50),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "created_by_name" character varying(255),
    CONSTRAINT "movimentacoes_estoque_tipo_movimentacao_check" CHECK ((("tipo_movimentacao")::"text" = ANY (ARRAY[('Entrada'::character varying)::"text", ('Sa├¡da'::character varying)::"text", ('Ajuste'::character varying)::"text"])))
);


ALTER TABLE "public"."movimentacoes_estoque" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notificacoes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "titulo" character varying(255) NOT NULL,
    "mensagem" "text" NOT NULL,
    "tipo" character varying(50) DEFAULT 'info'::character varying,
    "lida" boolean DEFAULT false,
    "url_acao" character varying(255),
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "notificacoes_tipo_check" CHECK ((("tipo")::"text" = ANY (ARRAY[('info'::character varying)::"text", ('warning'::character varying)::"text", ('error'::character varying)::"text", ('success'::character varying)::"text"])))
);


ALTER TABLE "public"."notificacoes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."periodos_mensais" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ano" integer NOT NULL,
    "mes" integer NOT NULL,
    "status" character varying(50) DEFAULT 'ativo'::character varying,
    "limite_global_default" numeric(10,2) DEFAULT 200.00,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "periodos_mensais_mes_check" CHECK ((("mes" >= 1) AND ("mes" <= 12))),
    CONSTRAINT "periodos_mensais_status_check" CHECK ((("status")::"text" = ANY (ARRAY[('ativo'::character varying)::"text", ('fechado'::character varying)::"text"])))
);


ALTER TABLE "public"."periodos_mensais" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."produtos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "categoria_id" "uuid",
    "nome" character varying(255) NOT NULL,
    "descricao" "text",
    "tamanho" character varying(20),
    "cor" character varying(50),
    "condicao" character varying(50) DEFAULT 'Bom'::character varying,
    "quantidade_estoque" integer DEFAULT 0,
    "quantidade_minima" integer DEFAULT 5,
    "valor_estimado" numeric(10,2),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "produtos_condicao_check" CHECK ((("condicao")::"text" = ANY (ARRAY[('├ôtimo'::character varying)::"text", ('Bom'::character varying)::"text", ('Regular'::character varying)::"text", ('Ruim'::character varying)::"text"])))
);


ALTER TABLE "public"."produtos" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."security_status_summary" WITH ("security_invoker"='on') AS
 SELECT 'RLS Status'::"text" AS "category",
    "count"(*) AS "total_items",
    "sum"(
        CASE
            WHEN "c"."relrowsecurity" THEN 1
            ELSE 0
        END) AS "secure_items",
    "round"(((("sum"(
        CASE
            WHEN "c"."relrowsecurity" THEN 1
            ELSE 0
        END))::numeric / ("count"(*))::numeric) * (100)::numeric), 2) AS "security_percentage"
   FROM (("information_schema"."tables" "t"
     JOIN "pg_class" "c" ON (("c"."relname" = ("t"."table_name")::"name")))
     JOIN "pg_namespace" "n" ON (("n"."oid" = "c"."relnamespace")))
  WHERE ((("t"."table_schema")::"name" = 'public'::"name") AND (("t"."table_type")::"text" = 'BASE TABLE'::"text") AND ("n"."nspname" = 'public'::"name"))
UNION ALL
 SELECT 'Function Security'::"text" AS "category",
    "count"(*) AS "total_items",
    "sum"(
        CASE
            WHEN (("p"."prosecdef" = false) AND ("p"."proacl" IS NULL)) THEN 1
            ELSE 0
        END) AS "secure_items",
    "round"(((("sum"(
        CASE
            WHEN (("p"."prosecdef" = false) AND ("p"."proacl" IS NULL)) THEN 1
            ELSE 0
        END))::numeric / ("count"(*))::numeric) * (100)::numeric), 2) AS "security_percentage"
   FROM ("pg_proc" "p"
     JOIN "pg_namespace" "n" ON (("p"."pronamespace" = "n"."oid")))
  WHERE (("n"."nspname" = 'public'::"name") AND ("p"."prokind" = 'f'::"char"));


ALTER VIEW "public"."security_status_summary" OWNER TO "postgres";


COMMENT ON VIEW "public"."security_status_summary" IS 'View para monitoramento do status de seguran├ºa do sistema. Criada sem SECURITY DEFINER para evitar problemas de seguran├ºa.';



CREATE TABLE IF NOT EXISTS "public"."system_configuration_notes" (
    "id" integer NOT NULL,
    "component" character varying(100) NOT NULL,
    "setting_name" character varying(100) NOT NULL,
    "recommended_value" "text" NOT NULL,
    "current_issue" "text" NOT NULL,
    "resolution_method" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."system_configuration_notes" OWNER TO "postgres";


COMMENT ON TABLE "public"."system_configuration_notes" IS 'Tabela para documentar configura├º├Áes do sistema que precisam de ajustes manuais no dashboard do Supabase';



CREATE SEQUENCE IF NOT EXISTS "public"."system_configuration_notes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."system_configuration_notes_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."system_configuration_notes_id_seq" OWNED BY "public"."system_configuration_notes"."id";



CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "email" "text" NOT NULL,
    "password_hash" "text" NOT NULL,
    "role" "public"."user_role_enum" DEFAULT 'voluntario'::"public"."user_role_enum" NOT NULL,
    "status" "text" DEFAULT 'ativo'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "last_login" timestamp with time zone,
    CONSTRAINT "users_status_check" CHECK (("status" = ANY (ARRAY['ativo'::"text", 'inativo'::"text"])))
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."system_configuration_notes" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."system_configuration_notes_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."atividades_sistema"
    ADD CONSTRAINT "atividades_sistema_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."beneficiarios"
    ADD CONSTRAINT "beneficiarios_cpf_key" UNIQUE ("cpf");



ALTER TABLE ONLY "public"."beneficiarios"
    ADD CONSTRAINT "beneficiarios_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."categorias_produtos"
    ADD CONSTRAINT "categorias_produtos_nome_key" UNIQUE ("nome");



ALTER TABLE ONLY "public"."categorias_produtos"
    ADD CONSTRAINT "categorias_produtos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."configuracoes_sistema"
    ADD CONSTRAINT "configuracoes_sistema_chave_key" UNIQUE ("chave");



ALTER TABLE ONLY "public"."configuracoes_sistema"
    ADD CONSTRAINT "configuracoes_sistema_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dependentes"
    ADD CONSTRAINT "dependentes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."distribuicoes"
    ADD CONSTRAINT "distribuicoes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."doacoes"
    ADD CONSTRAINT "doacoes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."doadores"
    ADD CONSTRAINT "doadores_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."itens_distribuicao"
    ADD CONSTRAINT "itens_distribuicao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."itens_doacao"
    ADD CONSTRAINT "itens_doacao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."movimentacoes_estoque"
    ADD CONSTRAINT "movimentacoes_estoque_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notificacoes"
    ADD CONSTRAINT "notificacoes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."periodos_mensais"
    ADD CONSTRAINT "periodos_mensais_ano_mes_key" UNIQUE ("ano", "mes");



ALTER TABLE ONLY "public"."periodos_mensais"
    ADD CONSTRAINT "periodos_mensais_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."produtos"
    ADD CONSTRAINT "produtos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."system_configuration_notes"
    ADD CONSTRAINT "system_configuration_notes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_beneficiarios_status" ON "public"."beneficiarios" USING "btree" ("status");



CREATE INDEX "idx_doacoes_status" ON "public"."doacoes" USING "btree" ("status");



CREATE INDEX "idx_produtos_categoria" ON "public"."produtos" USING "btree" ("categoria_id");



CREATE INDEX "idx_users_email" ON "public"."users" USING "btree" ("email");



CREATE OR REPLACE TRIGGER "audit_users_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."audit_users_changes"();



CREATE OR REPLACE TRIGGER "log_user_deletion_trigger" BEFORE DELETE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."log_user_deletion"();



CREATE OR REPLACE TRIGGER "update_configuracoes_updated_by_name" BEFORE UPDATE ON "public"."configuracoes_sistema" FOR EACH ROW EXECUTE FUNCTION "public"."update_configuracoes_updated_by_name"();



CREATE OR REPLACE TRIGGER "update_created_by_name_trigger" BEFORE INSERT OR UPDATE ON "public"."beneficiarios" FOR EACH ROW EXECUTE FUNCTION "public"."update_created_by_name"();



CREATE OR REPLACE TRIGGER "update_created_by_name_trigger" BEFORE INSERT OR UPDATE ON "public"."distribuicoes" FOR EACH ROW EXECUTE FUNCTION "public"."update_created_by_name"();



CREATE OR REPLACE TRIGGER "update_created_by_name_trigger" BEFORE INSERT OR UPDATE ON "public"."doacoes" FOR EACH ROW EXECUTE FUNCTION "public"."update_created_by_name"();



CREATE OR REPLACE TRIGGER "update_created_by_name_trigger" BEFORE INSERT OR UPDATE ON "public"."movimentacoes_estoque" FOR EACH ROW EXECUTE FUNCTION "public"."update_created_by_name"();



CREATE OR REPLACE TRIGGER "update_updated_at_trigger" BEFORE UPDATE ON "public"."beneficiarios" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_updated_at_trigger" BEFORE UPDATE ON "public"."configuracoes_sistema" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_updated_at_trigger" BEFORE UPDATE ON "public"."distribuicoes" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_updated_at_trigger" BEFORE UPDATE ON "public"."doacoes" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_updated_at_trigger" BEFORE UPDATE ON "public"."doadores" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_updated_at_trigger" BEFORE UPDATE ON "public"."produtos" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_updated_at_trigger" BEFORE UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."atividades_sistema"
    ADD CONSTRAINT "atividades_sistema_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."beneficiarios"
    ADD CONSTRAINT "beneficiarios_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."configuracoes_sistema"
    ADD CONSTRAINT "configuracoes_sistema_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."dependentes"
    ADD CONSTRAINT "dependentes_beneficiario_id_fkey" FOREIGN KEY ("beneficiario_id") REFERENCES "public"."beneficiarios"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."distribuicoes"
    ADD CONSTRAINT "distribuicoes_beneficiario_id_fkey" FOREIGN KEY ("beneficiario_id") REFERENCES "public"."beneficiarios"("id");



ALTER TABLE ONLY "public"."distribuicoes"
    ADD CONSTRAINT "distribuicoes_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."doacoes"
    ADD CONSTRAINT "doacoes_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."doacoes"
    ADD CONSTRAINT "doacoes_doador_id_fkey" FOREIGN KEY ("doador_id") REFERENCES "public"."doadores"("id");



ALTER TABLE ONLY "public"."itens_distribuicao"
    ADD CONSTRAINT "itens_distribuicao_distribuicao_id_fkey" FOREIGN KEY ("distribuicao_id") REFERENCES "public"."distribuicoes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."itens_distribuicao"
    ADD CONSTRAINT "itens_distribuicao_produto_id_fkey" FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id");



ALTER TABLE ONLY "public"."itens_doacao"
    ADD CONSTRAINT "itens_doacao_doacao_id_fkey" FOREIGN KEY ("doacao_id") REFERENCES "public"."doacoes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."itens_doacao"
    ADD CONSTRAINT "itens_doacao_produto_id_fkey" FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id");



ALTER TABLE ONLY "public"."movimentacoes_estoque"
    ADD CONSTRAINT "movimentacoes_estoque_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."movimentacoes_estoque"
    ADD CONSTRAINT "movimentacoes_estoque_produto_id_fkey" FOREIGN KEY ("produto_id") REFERENCES "public"."produtos"("id");



ALTER TABLE ONLY "public"."notificacoes"
    ADD CONSTRAINT "notificacoes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."produtos"
    ADD CONSTRAINT "produtos_categoria_id_fkey" FOREIGN KEY ("categoria_id") REFERENCES "public"."categorias_produtos"("id");



CREATE POLICY "Administradores podem ver notas de configura├º├úo" ON "public"."system_configuration_notes" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Admins can view audit logs" ON "public"."audit_logs" FOR SELECT USING (true);



CREATE POLICY "Allow authenticated users to read users" ON "public"."users" FOR SELECT USING (true);



CREATE POLICY "Apenas administradores podem atualizar atividades" ON "public"."atividades_sistema" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar benefici├írios" ON "public"."beneficiarios" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar categorias" ON "public"."categorias_produtos" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar configura├º├Áes" ON "public"."configuracoes_sistema" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar dependentes" ON "public"."dependentes" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar distribui├º├Áes" ON "public"."distribuicoes" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar doadores" ON "public"."doadores" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar doa├º├Áes" ON "public"."doacoes" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar itens de distribui├º├úo" ON "public"."itens_distribuicao" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar itens de doa├º├úo" ON "public"."itens_doacao" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar movimenta├º├Áes de estoq" ON "public"."movimentacoes_estoque" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar per├¡odos mensais" ON "public"."periodos_mensais" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem atualizar produtos" ON "public"."produtos" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar atividades" ON "public"."atividades_sistema" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar benefici├írios" ON "public"."beneficiarios" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar categorias" ON "public"."categorias_produtos" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar configura├º├Áes" ON "public"."configuracoes_sistema" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar dependentes" ON "public"."dependentes" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar distribui├º├Áes" ON "public"."distribuicoes" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar doadores" ON "public"."doadores" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar doa├º├Áes" ON "public"."doacoes" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar itens de distribui├º├úo" ON "public"."itens_distribuicao" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar itens de doa├º├úo" ON "public"."itens_doacao" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar movimenta├º├Áes de estoque" ON "public"."movimentacoes_estoque" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar notifica├º├Áes" ON "public"."notificacoes" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar per├¡odos mensais" ON "public"."periodos_mensais" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem deletar produtos" ON "public"."produtos" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem inserir benefici├írios" ON "public"."beneficiarios" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem inserir categorias" ON "public"."categorias_produtos" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem inserir configura├º├Áes" ON "public"."configuracoes_sistema" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem inserir dependentes" ON "public"."dependentes" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem inserir doadores" ON "public"."doadores" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem inserir notifica├º├Áes" ON "public"."notificacoes" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem inserir per├¡odos mensais" ON "public"."periodos_mensais" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Apenas administradores podem inserir produtos" ON "public"."produtos" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND ("users"."role" = 'admin'::"public"."user_role_enum")))));



CREATE POLICY "Sistema pode inserir atividades" ON "public"."atividades_sistema" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Superadmins and admins can insert users" ON "public"."users" FOR INSERT WITH CHECK (true);



CREATE POLICY "Superadmins and admins can update users" ON "public"."users" FOR UPDATE USING (true);



CREATE POLICY "Superadmins can delete users" ON "public"."users" FOR DELETE USING (true);



CREATE POLICY "Usu├írios autenticados podem inserir distribui├º├Áes" ON "public"."distribuicoes" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Usu├írios autenticados podem inserir doa├º├Áes" ON "public"."doacoes" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Usu├írios autenticados podem inserir itens de distribui├º├úo" ON "public"."itens_distribuicao" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Usu├írios autenticados podem inserir itens de doa├º├úo" ON "public"."itens_doacao" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Usu├írios autenticados podem inserir movimenta├º├Áes de estoque" ON "public"."movimentacoes_estoque" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Usu├írios autenticados podem ver atividades do sistema" ON "public"."atividades_sistema" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver benefici├írios" ON "public"."beneficiarios" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver categorias" ON "public"."categorias_produtos" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver configura├º├Áes do sistema" ON "public"."configuracoes_sistema" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver dependentes" ON "public"."dependentes" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver distribui├º├Áes" ON "public"."distribuicoes" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver doadores" ON "public"."doadores" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver doa├º├Áes" ON "public"."doacoes" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver itens de distribui├º├úo" ON "public"."itens_distribuicao" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver itens de doa├º├úo" ON "public"."itens_doacao" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver movimenta├º├Áes de estoque" ON "public"."movimentacoes_estoque" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver per├¡odos mensais" ON "public"."periodos_mensais" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios autenticados podem ver produtos" ON "public"."produtos" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Usu├írios podem atualizar suas pr├│prias notifica├º├Áes" ON "public"."notificacoes" FOR UPDATE TO "authenticated" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "Usu├írios podem ver suas pr├│prias notifica├º├Áes" ON "public"."notificacoes" FOR SELECT TO "authenticated" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."atividades_sistema" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."audit_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."beneficiarios" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."categorias_produtos" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."configuracoes_sistema" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."dependentes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."distribuicoes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."doacoes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."doadores" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."itens_distribuicao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."itens_doacao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."movimentacoes_estoque" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notificacoes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."periodos_mensais" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."produtos" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."system_configuration_notes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."audit_users_changes"() TO "anon";
GRANT ALL ON FUNCTION "public"."audit_users_changes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."audit_users_changes"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_user_dependencies"("user_id_param" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_user_dependencies"("user_id_param" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_user_dependencies"("user_id_param" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."log_audit_event"("p_table_name" "text", "p_operation" "text", "p_old_data" "jsonb", "p_new_data" "jsonb", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."log_audit_event"("p_table_name" "text", "p_operation" "text", "p_old_data" "jsonb", "p_new_data" "jsonb", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_audit_event"("p_table_name" "text", "p_operation" "text", "p_old_data" "jsonb", "p_new_data" "jsonb", "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."log_user_deletion"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_user_deletion"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_user_deletion"() TO "service_role";



GRANT ALL ON FUNCTION "public"."safe_delete_user"("user_id_param" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."safe_delete_user"("user_id_param" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."safe_delete_user"("user_id_param" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_configuracoes_updated_by_name"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_configuracoes_updated_by_name"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_configuracoes_updated_by_name"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_created_by_name"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_created_by_name"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_created_by_name"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";


















GRANT ALL ON TABLE "public"."atividades_sistema" TO "anon";
GRANT ALL ON TABLE "public"."atividades_sistema" TO "authenticated";
GRANT ALL ON TABLE "public"."atividades_sistema" TO "service_role";



GRANT ALL ON TABLE "public"."audit_logs" TO "anon";
GRANT ALL ON TABLE "public"."audit_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."audit_logs" TO "service_role";



GRANT ALL ON TABLE "public"."beneficiarios" TO "anon";
GRANT ALL ON TABLE "public"."beneficiarios" TO "authenticated";
GRANT ALL ON TABLE "public"."beneficiarios" TO "service_role";



GRANT ALL ON TABLE "public"."categorias_produtos" TO "anon";
GRANT ALL ON TABLE "public"."categorias_produtos" TO "authenticated";
GRANT ALL ON TABLE "public"."categorias_produtos" TO "service_role";



GRANT ALL ON TABLE "public"."configuracoes_sistema" TO "anon";
GRANT ALL ON TABLE "public"."configuracoes_sistema" TO "authenticated";
GRANT ALL ON TABLE "public"."configuracoes_sistema" TO "service_role";



GRANT ALL ON TABLE "public"."dependentes" TO "anon";
GRANT ALL ON TABLE "public"."dependentes" TO "authenticated";
GRANT ALL ON TABLE "public"."dependentes" TO "service_role";



GRANT ALL ON TABLE "public"."distribuicoes" TO "anon";
GRANT ALL ON TABLE "public"."distribuicoes" TO "authenticated";
GRANT ALL ON TABLE "public"."distribuicoes" TO "service_role";



GRANT ALL ON TABLE "public"."doacoes" TO "anon";
GRANT ALL ON TABLE "public"."doacoes" TO "authenticated";
GRANT ALL ON TABLE "public"."doacoes" TO "service_role";



GRANT ALL ON TABLE "public"."doadores" TO "anon";
GRANT ALL ON TABLE "public"."doadores" TO "authenticated";
GRANT ALL ON TABLE "public"."doadores" TO "service_role";



GRANT ALL ON TABLE "public"."itens_distribuicao" TO "anon";
GRANT ALL ON TABLE "public"."itens_distribuicao" TO "authenticated";
GRANT ALL ON TABLE "public"."itens_distribuicao" TO "service_role";



GRANT ALL ON TABLE "public"."itens_doacao" TO "anon";
GRANT ALL ON TABLE "public"."itens_doacao" TO "authenticated";
GRANT ALL ON TABLE "public"."itens_doacao" TO "service_role";



GRANT ALL ON TABLE "public"."movimentacoes_estoque" TO "anon";
GRANT ALL ON TABLE "public"."movimentacoes_estoque" TO "authenticated";
GRANT ALL ON TABLE "public"."movimentacoes_estoque" TO "service_role";



GRANT ALL ON TABLE "public"."notificacoes" TO "anon";
GRANT ALL ON TABLE "public"."notificacoes" TO "authenticated";
GRANT ALL ON TABLE "public"."notificacoes" TO "service_role";



GRANT ALL ON TABLE "public"."periodos_mensais" TO "anon";
GRANT ALL ON TABLE "public"."periodos_mensais" TO "authenticated";
GRANT ALL ON TABLE "public"."periodos_mensais" TO "service_role";



GRANT ALL ON TABLE "public"."produtos" TO "anon";
GRANT ALL ON TABLE "public"."produtos" TO "authenticated";
GRANT ALL ON TABLE "public"."produtos" TO "service_role";



GRANT ALL ON TABLE "public"."security_status_summary" TO "anon";
GRANT ALL ON TABLE "public"."security_status_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."security_status_summary" TO "service_role";



GRANT ALL ON TABLE "public"."system_configuration_notes" TO "anon";
GRANT ALL ON TABLE "public"."system_configuration_notes" TO "authenticated";
GRANT ALL ON TABLE "public"."system_configuration_notes" TO "service_role";



GRANT ALL ON SEQUENCE "public"."system_configuration_notes_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."system_configuration_notes_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."system_configuration_notes_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























RESET ALL;
