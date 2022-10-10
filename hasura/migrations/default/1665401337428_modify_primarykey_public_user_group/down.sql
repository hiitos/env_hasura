alter table "public"."user_group" drop constraint "user_group_pkey";
alter table "public"."user_group"
    add constraint "user_group_pkey"
    primary key ("user_id");
