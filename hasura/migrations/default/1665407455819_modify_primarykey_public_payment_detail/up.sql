BEGIN TRANSACTION;
ALTER TABLE "public"."payment_detail" DROP CONSTRAINT "payment_detail_pkey";

ALTER TABLE "public"."payment_detail"
    ADD CONSTRAINT "payment_detail_pkey" PRIMARY KEY ("payment_id", "user_id");
COMMIT TRANSACTION;
