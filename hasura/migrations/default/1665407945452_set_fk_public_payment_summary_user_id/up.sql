alter table "public"."payment_summary"
  add constraint "payment_summary_user_id_fkey"
  foreign key ("user_id")
  references "public"."user"
  ("user_id") on update restrict on delete restrict;
