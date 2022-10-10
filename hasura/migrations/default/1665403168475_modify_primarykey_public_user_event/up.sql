BEGIN TRANSACTION;
ALTER TABLE "public"."user_event" DROP CONSTRAINT "user_event_pkey";

ALTER TABLE "public"."user_event"
    ADD CONSTRAINT "user_event_pkey" PRIMARY KEY ("user_id", "event_id");
COMMIT TRANSACTION;
