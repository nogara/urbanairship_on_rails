require 'rails/generators/migration'
require 'rails/generators/active_record'

class ApnMigrationsGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  
  source_root File.expand_path('../apn_migrations/templates', __FILE__)
  
  def self.next_migration_number(path)
    ActiveRecord::Generators::Base.next_migration_number(path)
  end
  
  def setup_urban_airship_initializer
    initializer "urban_airship.rb" do
      configs = ""
      configs << "UA::Config.app_key = 'YOUR APP KEY'\n"
      configs << "UA::Config.app_secret = 'YOUR APP SECRET'\n"
      configs << "UA::Config.push_secret = 'YOUR PUSH SECRET'\n"
      configs << "UA::Config.push_host = 'go.urbanairship.com'\n"
      configs << "UA::Config.push_port = '443'\n"
      
      configs
    end
  end
  
  def create_migrations # :nodoc:    
    Dir.glob(File.join(File.dirname(__FILE__), 'templates', '*.rb')).sort.each_with_index do |f, i|
      _migration = File.basename(f).gsub(/^(\d+_)/, '')
      migration_template File.basename(f), "db/migrate/#{ _migration }"
    end
  end
end
