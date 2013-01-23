echo "Setting up dummy Redmine"
git clone https://github.com/redmine/redmine.git travis
echo "Checking out branch"
cd travis && git checkout origin/2.2-stable
echo "Copying database.yml"
cp ../test/database.travis.yml config/database.yml
echo "Cloning the plugin to dummy Redmine plugins folder"
git clone ../ plugins/redmine_evm
bundle install
echo "Migrating database"
RAILS_ENV=test bundle exec rake db:migrate
RAILS_ENV=development bundle exec rake db:migrate
