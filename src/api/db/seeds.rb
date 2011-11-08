puts "Seeding architectures table..."
# NOTE: armvXel is actually obsolete (because it never exist as official platform), but kept for compatibility reasons
["armv4l", "armv5l", "armv6l", "armv7l", "armv5el", "armv6el", "armv7el", "armv8el", "hppa", "i586", "i686", "ia64", "local", "mips", "mips32", "mips64", "ppc", "ppc64", "s390", "s390x", "sparc", "sparc64", "sparc64v", "sparcv8", "sparcv9", "sparcv9v", "x86_64"].each do |arch_name|
  Architecture.find_or_create_by_name :name => arch_name
end

puts "Seeding roles table..."
admin_role      = Role.find_or_create_by_title :title => "Admin", :global => true
user_role       = Role.find_or_create_by_title :title => "User", :global => true
maintainer_role = Role.find_or_create_by_title :title => "maintainer"
downloader_role = Role.find_or_create_by_title :title => 'downloader'
reader_role     = Role.find_or_create_by_title :title => 'reader'
Role.find_or_create_by_title :title => 'bugowner'
Role.find_or_create_by_title :title => 'reviewer'

puts "Seeding users table..."
admin  = User.find_or_create_by_login_and_email_and_realname :login => 'Admin', :email => "root@localhost", :realname => "OBS Instance Superuser", :state => "2", :password => "opensuse", :password_confirmation => "opensuse"
nobody = User.find_or_create_by_login_and_email_and_realname :login => "_nobody_", :email => "nobody@localhost", :realname => "Anonymous User", :state => "3", :password => "123456", :password_confirmation => "123456"

puts "Seeding roles_users table..."
RolesUser.find_or_create_by_user_id_and_role_id :user_id => admin.id, :role_id => admin_role.id
RolesUser.find_or_create_by_user_id_and_role_id :user_id => admin.id, :role_id => user_role.id

puts "Seeding static_permissions table..."
["status_message_create", "set_download_counters", "download_binaries", "source_access", "access", "global_change_project", "global_create_project", "global_change_package", "global_create_package", "change_project", "create_project", "change_package", "create_package"].each do |sp_title|
  StaticPermission.find_or_create_by_title :title => sp_title
end

puts "Seeding static permissions for admin role in roles_static_permissions table..."
StaticPermission.find(:all).each do |sp|
  admin_role.static_permissions << sp unless admin_role.static_permissions.find_by_id(sp.id)
end

puts "Seeding static permissions for maintainer role in roles_static_permissions table..."
["change_project", "create_project", "change_package", "create_package"].each do |sp_title|
  sp = StaticPermission.find_by_title(sp_title)
  maintainer_role.static_permissions << sp unless maintainer_role.static_permissions.find_by_id(sp.id)
end

puts "Seeding static permissions for reader role in roles_static_permissions table..."
["access", "source_access"].each do |sp_title|
  sp = StaticPermission.find_by_title(sp_title)
  reader_role.static_permissions << sp unless reader_role.static_permissions.find_by_id(sp.id)
end

puts "Seeding static permissions for downloader role in roles_static_permissions table..."
["download_binaries"].each do |sp_title|
  sp = StaticPermission.find_by_title(sp_title)
  downloader_role.static_permissions << sp unless downloader_role.static_permissions.find_by_id(sp.id)
end

puts "Seeding attrib_namespaces table..."
ans = AttribNamespace.find_or_create_by_name :name => "OBS"
ans.attrib_namespace_modifiable_bies.find_or_create_by_bs_user_id(admin.id)

puts "Seeding attrib_types table..."
at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "VeryImportantProject", :value_count => 0)
at.attrib_type_modifiable_bies.find_or_create_by_bs_user_id(admin.id)
at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "UpdateProject", :value_count => 1)
at.attrib_type_modifiable_bies.find_or_create_by_bs_user_id(admin.id)
at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "RejectRequests", :value_count => 1)
at.attrib_type_modifiable_bies.find_or_create_by_bs_user_id(admin.id)
at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "ApprovedRequestSource", :value_count => 0)
at.attrib_type_modifiable_bies.find_or_create_by_bs_user_id(admin.id)
at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "Maintained", :value_count => 0)
at.attrib_type_modifiable_bies.find_or_create_by_bs_user_id(admin.id)
at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "MaintenanceProject", :value_count => 0)
at.attrib_type_modifiable_bies.find_or_create_by_bs_user_id(admin.id)
at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "MaintenanceIdTemplate", :value_count => 1)
at.attrib_type_modifiable_bies.find_or_create_by_bs_user_id(admin.id)
at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "ScreenShots")
at.attrib_type_modifiable_bies.find_or_create_by_bs_user_id(admin.id)

at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "RequestCloned", :value_count => 1)
at.attrib_type_modifiable_bies.find_or_create_by_bs_role_id(maintainer_role.id)
at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "ProjectStatusPackageFailComment", :value_count => 1)
at.attrib_type_modifiable_bies.find_or_create_by_bs_role_id(maintainer_role.id)
at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "InitializeDevelPackage", :value_count => 0)
at.attrib_type_modifiable_bies.find_or_create_by_bs_role_id(maintainer_role.id)

at = AttribType.find_or_create_by_attrib_namespace_id_and_name(:attrib_namespace => ans, :name => "QualityCategory", :value_count => 1)
at.attrib_type_modifiable_bies.find_or_create_by_bs_role_id(maintainer_role.id)
at.allowed_values << AttribAllowedValue.new( :value => "Stable" )
at.allowed_values << AttribAllowedValue.new( :value => "Testing" )
at.allowed_values << AttribAllowedValue.new( :value => "Development" )
at.allowed_values << AttribAllowedValue.new( :value => "Private" )


puts "Seeding db_project_type table by loading test fixtures"
DbProjectType.find_or_create_by_name("standard")
DbProjectType.find_or_create_by_name("maintenance")
DbProjectType.find_or_create_by_name("maintenance_incident")

# default repository to link when original one got removed
d = DbProject.find_or_create_by_name("deleted")
r = Repository.new( :name => "deleted", :db_project => d )
d.repositories << r
d.save

# set default configuration settings
Configuration.create(:title => "Open Build Service", :description => <<-EOT
  <p class="description">
    The <a href="http://openbuildservice.org">Open Build Service (OBS)</a>
    is an open and complete distribution development platform that provides a transparent infrastructure for development of Linux distributions, used by openSUSE, MeeGo and other distributions.
    Supporting also Fedora, Debian, Ubuntu, RedHat and other Linux distributions.
  </p>
  <p class="description">
    The OBS is developed under the umbrella of the <a href="http://www.opensuse.org">openSUSE project</a>. Please find further informations on the <a href="http://wiki.opensuse.org/openSUSE:Build_Service">openSUSE Project wiki pages</a>.
  </p>

  <p class="description">
    The Open Build Service developer team is greeting you. In case you use your OBS productive in your facility, please do us a favor and add yourself at <a href="http://wiki.opensuse.org/openSUSE:Build_Service_installations">this wiki page</a>. Have fun and fast build times!
  </p>
EOT
)

