Given /^I am logged in$/ do 
  Given "I am logged in as \"brian_dennehy\""
end

Given /^I am logged in as "([^\"]*)"$/ do |username|
  @user = ensure_account username,username
  
  teardown { User.delete @user if @user }
  
  Then "Login in as #{username} with password #{username}"
  
  assert_not_contain "Invalid user or password"
end

Given /^I am not logged in$/ do
  visit "http://localhost:3000/logout"
  @user = User.anonymous
end

Given /^I am(\snot)? an administrator$/ do |not_an_adminstrator|
  is_admin = not_an_adminstrator.nil? or not_an_adminstrator
  @user.admin = is_admin
  @user.save!
end

Given /^Login in as ([^\"]*) with password ([^\"]*)$/ do |username, password|
  visit "http://localhost:3000/login"
  fill_in "username", :with => username
  fill_in "password", :with => password
  click_button "login"
end

When /^I go to Browse Bettermeans$/ do
  visit "http://localhost:3000/projects"
  @view = BrowseBettermeansView.new webrat_session
end

When /^I go to dash data$/ do
  the_project = projects.last
  visit "http://localhost:3000/projects/#{the_project.id}/new_dashdata?include_subworkstreams=true"
end

When /^I wait until/ do
  @view.wait_until_loaded
end

Then /^I do not see an error screen/ do
  webrat_session.response_body.should_not contain "Action Controller: Exception caught"
end

def ensure_account(username, password)
  result = User.find_by_login(username)
  
  result = create_account(username, password) unless result
  
  result
end

def create_account(username, password)
  new_user = User.new
  new_user.login = username    
  new_user.firstname = username
  new_user.lastname = username
  new_user.password = password 
  new_user.admin = false 
  new_user.mail = "#{username}@xxx.com"

  new_user.save!  
  
  new_user
end