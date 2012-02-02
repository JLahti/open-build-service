class TC18__AddPackageUsers < TestCase


  test :add_package_maintainer do
  depend_on :create_home_project_package_for_user
  
    navigate_to PackageOverviewPage,
      :user => $data[:user1],
      :package => "HomePackage1",
      :project => "home:user1"
    open_tab "Users"
    add_user "user2", "maintainer"
  end
  
  
  test :add_package_bugowner do
  depend_on :create_home_project_package_for_user
  
    navigate_to PackageOverviewPage,
      :user => $data[:user1],
      :package => "HomePackage1",
      :project => "home:user1"
    open_tab "Users"
    add_user "user3", "bugowner"
  end
  
  
  test :add_package_reviewer do
  depend_on :create_home_project_package_for_user
  
    navigate_to PackageOverviewPage,
      :user => $data[:user1],
      :package => "HomePackage1",
      :project => "home:user1"
    open_tab "Users"
    add_user "user4", "reviewer"
  end
  
  
  test :add_package_downloader do
  depend_on :create_home_project_package_for_user
  
    navigate_to PackageOverviewPage,
      :user => $data[:user1],
      :package => "HomePackage1",
      :project => "home:user1"
    open_tab "Users"
    add_user "user5", "downloader"
  end
  
  
  test :add_package_reader do
  depend_on :create_home_project_package_for_user
  
    navigate_to PackageOverviewPage,
      :user => $data[:user1],
      :package => "HomePackage1",
      :project => "home:user1"
    open_tab "Users"
    add_user "user6", "reader"
  end
  
  
  test :add_additional_package_roles_to_a_user do
  depend_on :add_package_reader
  
    navigate_to PackageOverviewPage,
      :user => $data[:user1],
      :package => "HomePackage1",
      :project => "home:user1"
    open_tab "Users"
    add_user "user6", "reviewer"
    add_user "user6", "downloader"
  end
  
  
  test :add_all_package_roles_to_admin do
  depend_on :create_home_project_package_for_user
    
    navigate_to PackageOverviewPage,
      :user => $data[:user1],
      :package => "HomePackage1",
      :project => "home:user1"
    open_tab "Users"
    add_user "king", "maintainer"
    add_user "king", "bugowner"
    add_user "king", "reviewer"
    add_user "king", "downloader"
    add_user "king", "reader"
  end
  
  
  test :add_package_role_to_non_existing_user do
  depend_on :create_home_project_package_for_user
  
    navigate_to PackageOverviewPage,
      :user => $data[:user1],
      :package => "HomePackage1",
      :project => "home:user1"
    open_tab "Users"
    add_user "sadasxsacxsacsa", "reader", :expect => :unknown_user
  end
  
  
  test :add_package_role_with_empty_user_field do
  depend_on :create_home_project_package_for_user
  
    navigate_to PackageOverviewPage,
      :user => $data[:user1],
      :package => "HomePackage1",
      :project => "home:user1"
    open_tab "Users"
    add_user "", "maintainer", :expect => :invalid_username
  end
  
  
  test :add_package_role_to_invalid_username do
  depend_on :create_home_project_package_for_user
  
    navigate_to PackageOverviewPage,
      :user => $data[:user1],
      :package => "HomePackage1",
      :project => "home:user1"
    open_tab "Users"
    add_user '~@$@#%#%@$0-=<m,.,\/\/12`;.{{}}{}', "maintainer", :expect => :invalid_username
  end
  
  
  test :add_package_role_to_username_with_question_sign do
  depend_on :create_home_project_package_for_user
  
    navigate_to PackageOverviewPage,
      :user => $data[:user1],
      :package => "HomePackage1",
      :project => "home:user1"
    open_tab "Users"
    add_user 'still-buggy?', "maintainer", :expect => :invalid_username
  end
  
  
end
