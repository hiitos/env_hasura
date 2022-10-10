alter table "public"."user"
  add constraint "user_user_id_fkey"
  foreign key ("user_id")
  references "public"."user_group"
  ("user_id") on update restrict on delete restrict;
