alter table "public"."payment_summary"
  add constraint "payment_summary_event_id_fkey"
  foreign key ("event_id")
  references "public"."event"
  ("event_id") on update restrict on delete restrict;
