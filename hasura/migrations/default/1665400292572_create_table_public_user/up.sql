CREATE TABLE "public"."user" ("user_id" integer NOT NULL, "user_name" text NOT NULL, "registered_at" timestamptz NOT NULL DEFAULT now(), "last_seen" timestamptz, PRIMARY KEY ("user_id") );
