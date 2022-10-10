alter table "public"."user_group"
  add constraint "user_group_line_group_id_fkey"
  foreign key ("line_group_id")
  references "public"."group"
  ("line_group_id") on update restrict on delete restrict;
