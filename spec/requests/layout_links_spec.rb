require 'spec_helper'

describe "LayoutLinks" do

  it "should have a Home page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end
  
  it "should have a signup page at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => "Sign up")
  end
  
  it "should have a signin page at '/signin'" do
    get '/signin'
    response.should have_selector('title', :content => "Sign in")
  end
  
  it "should have the right links on the layout" do
    visit root_path
    click_link "Home"
    response.should have_selector('title', :content => "Home")
    click_link "Sign up now!"
    response.should have_selector('title', :content => "Sign up")
    click_link "Sign in"
    response.should have_selector('title', :content => "Sign in")
  end
  
  describe "when not signed in" do
    
    it "should have a signin link" do
      visit root_path
      response.should have_selector("a", :href => signin_path, :content => "Sign in")
    end
    
  end
  
  describe "when signed in" do

    before(:each) do
      @user = User.create!(:name => "Example User", :email => "user@example.com",
        :password => "foobar", :password_confirmation => "foobar")
      visit signin_path
      fill_in :email,    :with => @user.email
      fill_in :password, :with => @user.password
      click_button
    end

    it "should have a signout link" do
      visit root_path
      response.should have_selector("a", :href => signout_path, :content => "Sign out")
    end

    it "should have a profile link" do
      visit root_path
      response.should have_selector("a", :href => user_path(@user), :content => "Profile")
    end
    
  end

end
