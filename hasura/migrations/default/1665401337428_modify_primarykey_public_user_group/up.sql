BEGIN TRANSACTION;
ALTER TABLE "public"."user_group" DROP CONSTRAINT "user_group_pkey";

ALTER TABLE "public"."user_group"
    ADD CONSTRAINT "user_group_pkey" PRIMARY KEY ("user_id", "line_group_id");
COMMIT TRANSACTION;
