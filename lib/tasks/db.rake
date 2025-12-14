namespace :db do
  namespace :prepare do
    desc "Prepare all databases (primary, queue, cache, cable)"
    task all: :environment do
      ActiveRecord::Tasks::DatabaseTasks.prepare_all
    end
  end
end
