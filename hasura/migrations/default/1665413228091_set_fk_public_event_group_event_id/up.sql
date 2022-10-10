alter table "public"."event_group"
  add constraint "event_group_event_id_fkey"
  foreign key ("event_id")
  references "public"."event"
  ("event_id") on update restrict on delete restrict;
