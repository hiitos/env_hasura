alter table "public"."payment_detail"
  add constraint "payment_detail_payment_id_fkey"
  foreign key ("payment_id")
  references "public"."payment_summary"
  ("payment_id") on update restrict on delete restrict;
