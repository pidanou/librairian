

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "vector" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."match_item_by_captions"("query_embedding" "extensions"."vector", "match_threshold" double precision, "match_count" integer, "owner_id" "uuid") RETURNS TABLE("item_id" "uuid", "similarity" double precision)
    LANGUAGE "sql" STABLE
    AS $$
SELECT DISTINCT ON (attachment.item_id) 
    attachment.item_id AS item_id,
    1 - (captions_embeddings <=> query_embedding) AS similarity
FROM attachment
WHERE captions_embeddings <=> query_embedding <= 1 - match_threshold 
  AND attachment.user_id = owner_id
ORDER BY attachment.item_id, captions_embeddings <=> query_embedding
LIMIT 2*match_count;
$$;


ALTER FUNCTION "public"."match_item_by_captions"("query_embedding" "extensions"."vector", "match_threshold" double precision, "match_count" integer, "owner_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."match_item_by_description"("query_embedding" "extensions"."vector", "match_threshold" double precision, "match_count" integer, "owner_id" "uuid") RETURNS TABLE("item_id" "uuid", "similarity" double precision)
    LANGUAGE "sql" STABLE
    AS $$
  select
      item.id as item_id,
      1 - (description_embeddings <=> query_embedding) as similarity
    from item
    where description_embeddings <=> query_embedding <= 1 - match_threshold AND item.user_id = owner_id
    order by description_embeddings <=> query_embedding
    limit 2*match_count;
  $$;


ALTER FUNCTION "public"."match_item_by_description"("query_embedding" "extensions"."vector", "match_threshold" double precision, "match_count" integer, "owner_id" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."attachment" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "item_id" "uuid",
    "path" "text",
    "captions" "text" DEFAULT ''::"text",
    "captions_embeddings" "extensions"."vector",
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid",
    "size" bigint
);


ALTER TABLE "public"."attachment" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."item" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "description_embeddings" "extensions"."vector"
);


ALTER TABLE "public"."item" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."location" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "storage_id" "uuid" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "picked" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."location" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."storage" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "alias" "text" DEFAULT ''::"text" NOT NULL,
    "user_id" "uuid" NOT NULL
);


ALTER TABLE "public"."storage" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subscription" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "user_id" "uuid" NOT NULL,
    "subscription_start" timestamp with time zone NOT NULL,
    "subscription_end" timestamp with time zone NOT NULL
);


ALTER TABLE "public"."subscription" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."token_usage" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "user_id" "uuid",
    "amount" bigint,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."token_usage" OWNER TO "postgres";


ALTER TABLE ONLY "public"."attachment"
    ADD CONSTRAINT "attachment_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."item"
    ADD CONSTRAINT "file_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."storage"
    ADD CONSTRAINT "file_storage_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."location"
    ADD CONSTRAINT "storage_location_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscription"
    ADD CONSTRAINT "subscription_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscription"
    ADD CONSTRAINT "subscription_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."token_usage"
    ADD CONSTRAINT "token_usage_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."attachment"
    ADD CONSTRAINT "attachment_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."item"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."attachment"
    ADD CONSTRAINT "attachment_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."item"
    ADD CONSTRAINT "file_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."location"
    ADD CONSTRAINT "storage_location_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."item"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."location"
    ADD CONSTRAINT "storage_location_storage_id_fkey" FOREIGN KEY ("storage_id") REFERENCES "public"."storage"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."location"
    ADD CONSTRAINT "storage_location_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."storage"
    ADD CONSTRAINT "storage_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subscription"
    ADD CONSTRAINT "subscription_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."token_usage"
    ADD CONSTRAINT "usage_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



CREATE POLICY "Allow all for owner" ON "public"."item" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Allow all for owner" ON "public"."location" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Allow all for owner" ON "public"."storage" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



ALTER TABLE "public"."attachment" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."item" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."location" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."storage" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subscription" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."token_usage" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";











































































































































































































































































































































































































































































































































































GRANT ALL ON TABLE "public"."attachment" TO "anon";
GRANT ALL ON TABLE "public"."attachment" TO "authenticated";
GRANT ALL ON TABLE "public"."attachment" TO "service_role";



GRANT ALL ON TABLE "public"."item" TO "anon";
GRANT ALL ON TABLE "public"."item" TO "authenticated";
GRANT ALL ON TABLE "public"."item" TO "service_role";



GRANT ALL ON TABLE "public"."location" TO "anon";
GRANT ALL ON TABLE "public"."location" TO "authenticated";
GRANT ALL ON TABLE "public"."location" TO "service_role";



GRANT ALL ON TABLE "public"."storage" TO "anon";
GRANT ALL ON TABLE "public"."storage" TO "authenticated";
GRANT ALL ON TABLE "public"."storage" TO "service_role";



GRANT ALL ON TABLE "public"."subscription" TO "anon";
GRANT ALL ON TABLE "public"."subscription" TO "authenticated";
GRANT ALL ON TABLE "public"."subscription" TO "service_role";



GRANT ALL ON TABLE "public"."token_usage" TO "anon";
GRANT ALL ON TABLE "public"."token_usage" TO "authenticated";
GRANT ALL ON TABLE "public"."token_usage" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
