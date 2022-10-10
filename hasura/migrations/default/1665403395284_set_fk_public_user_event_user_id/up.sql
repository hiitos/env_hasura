alter table "public"."user_event"
  add constraint "user_event_user_id_fkey"
  foreign key ("user_id")
  references "public"."user"
  ("user_id") on update restrict on delete restrict;
