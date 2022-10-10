alter table "public"."user_event"
    add constraint "user_event_pkey"
    primary key ("event_id", "user_id");
