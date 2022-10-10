alter table "public"."payment_detail"
    add constraint "payment_detail_pkey"
    primary key ("payment_id", "user_id");
