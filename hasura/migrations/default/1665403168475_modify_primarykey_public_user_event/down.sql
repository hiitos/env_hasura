alter table "public"."user_event" drop constraint "user_event_pkey";
alter table "public"."user_event"
    add constraint "user_event_pkey"
    primary key ("user_id");
