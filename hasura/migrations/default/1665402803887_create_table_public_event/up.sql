CREATE TABLE "public"."event" ("event_id" integer NOT NULL, "date" timestamptz NOT NULL DEFAULT now(), "event_name" text NOT NULL, "hash" text NOT NULL, PRIMARY KEY ("event_id") );
