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
