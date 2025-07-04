create table
  public.shared_fortunes (
    id bigint generated by default as identity,
    created_at timestamp with time zone not null default now(),
    group_key text not null,
    fortune_type text not null,
    date date not null,
    fortune_data jsonb not null,
    constraint shared_fortunes_pkey primary key (id),
    constraint shared_fortunes_group_key_fortune_type_date_key unique (group_key, fortune_type, date)
  ) tablespace pg_default; 