alter table "public"."user_event"
  add constraint "user_event_event_id_fkey"
  foreign key ("event_id")
  references "public"."event"
  ("event_id") on update restrict on delete restrict;
