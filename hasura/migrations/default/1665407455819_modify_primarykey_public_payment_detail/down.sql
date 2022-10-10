alter table "public"."payment_detail" drop constraint "payment_detail_pkey";
alter table "public"."payment_detail"
    add constraint "payment_detail_pkey"
    primary key ("payment_id");
