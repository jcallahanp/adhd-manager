-- M1-01: every table has RLS, and user A cannot read or write user B's rows.
begin;
create extension if not exists pgtap with schema extensions;
set search_path = public, extensions;
select plan(38);

-- Two users. Inserting into auth.users fires the profile trigger.
insert into auth.users (id, email, aud, role) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'a@example.test', 'authenticated', 'authenticated'),
  ('bbbbbbbb-0000-0000-0000-000000000002', 'b@example.test', 'authenticated', 'authenticated');

create function pg_temp.act_as(uid uuid) returns void language sql as $$
  select set_config('role', 'authenticated', true),
         set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

-- Schema
select tables_are('public', array['profiles', 'api_keys', 'captures', 'items', 'triage_corrections']);
select is(
  (select count(*)::int from pg_tables where schemaname = 'public' and not rowsecurity), 0,
  'RLS is enabled on every public table');
select is((select count(*)::int from profiles), 2, 'a profile is created for each new user');

-- Rows owned by A, written by the service (worker) as postgres
insert into captures (id, user_id, raw_text) values
  ('cccccccc-0000-0000-0000-00000000000a', 'aaaaaaaa-0000-0000-0000-000000000001', 'call the dentist');
insert into items (id, user_id, capture_id, source_span, title, bucket, confidence, status) values
  ('dddddddd-0000-0000-0000-00000000000a', 'aaaaaaaa-0000-0000-0000-000000000001',
   'cccccccc-0000-0000-0000-00000000000a', 'call the dentist', 'Call the dentist', 'quick_task', 0.9, 'filed');
insert into api_keys (user_id, ciphertext, last4) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'v1:secret-ciphertext', 'wxyz');

-- Items must belong to the same user as their capture
select throws_ok(
  $$ insert into items (user_id, capture_id, source_span, title, bucket, confidence, status)
     values ('bbbbbbbb-0000-0000-0000-000000000002', 'cccccccc-0000-0000-0000-00000000000a', 'x', 'x', 'parked', 0.5, 'filed') $$,
  '23503', null, 'an item cannot point at another user''s capture');

-- Anonymous callers have no access at all
set local role anon;
select throws_ok($$ select id from captures $$, '42501', null, 'anon cannot read captures');
select throws_ok($$ select id from items $$, '42501', null, 'anon cannot read items');
select throws_ok($$ select id from profiles $$, '42501', null, 'anon cannot read profiles');
select throws_ok($$ select last4 from api_keys $$, '42501', null, 'anon cannot read api_keys');
select throws_ok($$ insert into captures (raw_text) values ('x') $$, '42501', null, 'anon cannot insert captures');
reset role;

-- User B
select pg_temp.act_as('bbbbbbbb-0000-0000-0000-000000000002');
select is((select count(*)::int from captures), 0, 'B reads none of A''s captures');
select is((select count(*)::int from items), 0, 'B reads none of A''s items');
select is((select count(*)::int from api_keys), 0, 'B reads none of A''s key rows');
select is((select count(*)::int from profiles), 1, 'B reads only B''s profile');
select throws_ok(
  $$ insert into captures (user_id, raw_text) values ('aaaaaaaa-0000-0000-0000-000000000001', 'x') $$,
  '42501', null, 'B cannot insert a capture as A');
select throws_ok(
  $$ insert into api_keys (user_id, ciphertext, last4) values ('aaaaaaaa-0000-0000-0000-000000000001', 'v1:x', 'abcd') $$,
  '42501', null, 'B cannot write A''s key');
select throws_ok(
  $$ insert into triage_corrections (user_id, item_id, from_bucket, to_bucket)
     values ('aaaaaaaa-0000-0000-0000-000000000001', 'dddddddd-0000-0000-0000-00000000000a', 'quick_task', 'parked') $$,
  '42501', null, 'B cannot write a correction as A');
select throws_ok(
  $$ insert into triage_corrections (item_id, from_bucket, to_bucket)
     values ('dddddddd-0000-0000-0000-00000000000a', 'quick_task', 'parked') $$,
  '23503', null, 'B cannot write a correction on A''s item');
update items set bucket = 'parked' where id = 'dddddddd-0000-0000-0000-00000000000a';
update profiles set display_name = 'hacked' where id = 'aaaaaaaa-0000-0000-0000-000000000001';
update api_keys set last4 = 'hack' where user_id = 'aaaaaaaa-0000-0000-0000-000000000001';
select throws_ok(
  $$ delete from captures where id = 'cccccccc-0000-0000-0000-00000000000a' $$,
  '42501', null, 'clients cannot delete captures');
delete from api_keys where user_id = 'aaaaaaaa-0000-0000-0000-000000000001';
-- B's own capture works; client-made id is kept
select lives_ok(
  $$ insert into captures (id, raw_text) values ('cccccccc-0000-0000-0000-00000000000b', 'buy milk') $$,
  'B can insert a capture with a client-made id');
reset role;

select is((select bucket::text from items where id = 'dddddddd-0000-0000-0000-00000000000a'), 'quick_task', 'B''s update of A''s item changed nothing');
select is((select display_name from profiles where id = 'aaaaaaaa-0000-0000-0000-000000000001'), null, 'B''s update of A''s profile changed nothing');
select is((select last4 from api_keys where user_id = 'aaaaaaaa-0000-0000-0000-000000000001'), 'wxyz', 'B''s update of A''s key changed nothing');
select is((select count(*)::int from captures where id = 'cccccccc-0000-0000-0000-00000000000a'), 1, 'B''s delete of A''s capture changed nothing');
select is((select count(*)::int from api_keys), 1, 'B''s delete of A''s key changed nothing');
select is((select user_id from captures where id = 'cccccccc-0000-0000-0000-00000000000b'), 'bbbbbbbb-0000-0000-0000-000000000002'::uuid, 'a capture''s owner defaults to the caller');

-- User A
select pg_temp.act_as('aaaaaaaa-0000-0000-0000-000000000001');
select is((select count(*)::int from captures), 1, 'A reads only A''s capture');
select is((select count(*)::int from items), 1, 'A reads A''s item');
select is((select last4 from api_keys), 'wxyz', 'A reads the last 4 of A''s key');
select throws_ok($$ select ciphertext from api_keys $$, '42501', null, 'A cannot read even A''s own key ciphertext');
select throws_ok(
  $$ insert into captures (raw_text, status) values ('x', 'done') $$,
  '42501', null, 'a client cannot insert a capture that is already done');
select throws_ok(
  $$ update captures set raw_text = 'changed' $$,
  '42501', null, 'a client cannot change the original text');
select throws_ok(
  $$ insert into items (capture_id, source_span, title, bucket, confidence, status)
     values ('cccccccc-0000-0000-0000-00000000000a', 'x', 'x', 'parked', 0.5, 'filed') $$,
  '42501', null, 'a client cannot create items (the worker does)');
select lives_ok(
  $$ update items set bucket = 'parked' where id = 'dddddddd-0000-0000-0000-00000000000a' $$,
  'A can move A''s item');
select lives_ok(
  $$ insert into triage_corrections (item_id, from_bucket, to_bucket)
     values ('dddddddd-0000-0000-0000-00000000000a', 'quick_task', 'parked') $$,
  'A can record a correction on A''s item');
select lives_ok(
  $$ update api_keys set ciphertext = 'v1:new', last4 = 'abcd' $$,
  'A can replace A''s key');
select is((select count(*)::int from triage_corrections), 1, 'A reads A''s correction');
reset role;

select pg_temp.act_as('bbbbbbbb-0000-0000-0000-000000000002');
select is((select count(*)::int from triage_corrections), 0, 'B reads none of A''s corrections');
reset role;

-- Values are constrained
select throws_ok(
  $$ insert into items (user_id, capture_id, source_span, title, bucket, confidence, status)
     values ('aaaaaaaa-0000-0000-0000-000000000001', 'cccccccc-0000-0000-0000-00000000000a', 'x', 'x', 'parked', 1.5, 'filed') $$,
  '23514', null, 'confidence must be between 0 and 1');

select * from finish();
rollback;
