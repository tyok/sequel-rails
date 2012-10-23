0.3.8 - dev
===========

0.3.7
=====

* Check migration directory exists before checking if migration are pending

0.3.6
=====

* Ensure some tasks use the right db after setting `Rails.env`:
  - `db:schema:load`
  - `db:schema:dump`
  - `db:force_close_open_connections`
* Add check for pending migrations before running task depending on schema:
  - `db:schema:load`
  - `db:test:prepare`
* Make database task more like what rails is doing:
  - `db:load` do not create the db anymore
  - `db:create` don't create the test db automatically
  - `db:drop` don't drop the test db automatically
  - `db:test:prepare` don't depend on `db:reset` which was loading `db:seed` (Sean Kirby)
* Make `rake db:setup` load schema instead of running migrations (Markus Fenske)
* Depends on `railties` instead of `rails` to not pull `active_record` 
  as dependency (Markus Fenske)

0.3.5
=====

* Fix `rake db:schema:load` (Markus Fenske)

0.3.4
=====

* Make `rake db:schema:dump` generate a schema file which contains foreign_keys
  and uses db types instead of ruby equivalents. This ensure loading the schema
  file will result in a correct db

* Map some Sequel specific exceptions to `ActiveRecord` equivalents, in 
  `config.action_dispatch.rescue_responses`. This allows controllers to behave
  more like `ActiveRecord` when Sequel raises exceptions. (Joshua Hansen)
 
* New Sequel plugin added to all `Sequel::Model` which allows to use 
  `Sequel::Model#find!` which will raise an exception if record does not exists.
  This method is an alias to `Sequel::Model#[]` method. (Joshua Hansen)

0.3.3
=====

* Fix generators and use better model and migration template (Joshua Hansen)

0.3.2
=====
* Ignore environments without `database` key (like ActiveRecord do it), to allow
  shared configurations in `database.yml`.
* Fix db creation commands to let the `system` method escape the arguments
* Fix error when using `mysql2` gem

0.3.1
=====
* Make `db:schema:dump` Rake task depends on Rails `environment` task (Gabor Ratky)

0.3.0
=====
* Update dependency to Rails (~> 3.2.0)

0.2.3
=====
* Set `PGPASSWORD` environment variable before trying to create DB using `createdb`

0.2.2
=====
* Ensure Sequel is disconnected before trying to drop a db

0.2.1
=====
* Make dependency on Sequel more open (~> 3.28)

0.2.0
=====
* Fix deprecation warning for config.generators
* Update dependency to Rails 3.1.1
* Update dependency to Sequel 3.28.0
* Update dependency to RSpec 2.7.0

0.1.4
=====
* Merged in changes to rake tasks and timestamp migrations

0.1.3
=====
* update sequel dependency, configuration change

0.1.2
=====
* fixed log_subscriber bug that 0.1.1 was -supposed- to fix.
* fixed controller_runtime bug

0.1.1
=====
* bug fixes, no additional functionality

0.1.0
=====
* initial release
