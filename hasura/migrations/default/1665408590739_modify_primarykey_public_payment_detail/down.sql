alter table "public"."payment_detail"
    add constraint "payment_detail_pkey"
    primary key ("user_id", "payment_id");
