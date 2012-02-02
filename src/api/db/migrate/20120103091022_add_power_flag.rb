class AddPowerFlag < ActiveRecord::Migration
  def self.up
    execute "alter table flags modify column flag enum('useforbuild','sourceaccess','binarydownload','debuginfo','build','publish','access','lock','power') not null;"
  end

  def self.down
    execute "alter table flags modify column flag enum('useforbuild','sourceaccess','binarydownload','debuginfo','build','publish','access','lock') not null;"
  end
end
