class AddCrossFlag < ActiveRecord::Migration
  def self.up
    execute "alter table flags modify column flag enum('useforbuild','sourceaccess','binarydownload','debuginfo','build','publish','access','lock','cross','power') not null;"
  end

  def self.down
    execute "alter table flags modify column flag enum('useforbuild','sourceaccess','binarydownload','debuginfo','build','publish','access','lock','power') not null;"
  end
end
