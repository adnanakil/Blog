require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'new'" do
    
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    
    it "should have the right title" do
      get 'new'
      response.should have_selector("title", :content => "Sign up")
    end
    
  end
  
  describe "GET 'show'" do

    before(:each) do
      attr = {
        :name => "Example User",
        :email => "user@example.com",
        :password => "foobar",
        :password_confirmation => "foobar"
      }
      @user = User.create!(attr)
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => "Profile")
    end

    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
    
  end
  
  describe "GET 'new'" do

    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign up")
    end
    
    it "should have a name field" do
      get :new
      response.should have_selector("input[name='user[name]'][type='text']")
    end
    
  end
  
  describe "POST 'create'" do

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", 
          :password => "", :password_confirmation => "" }
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
      
    end
    
    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com", 
          :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(root_path)
      end   
      
      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /Wlecome to you're Microblog, New User!/i
      end
      
      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
      
    end
    
  end
  
  describe "GET 'edit'" do

    before(:each) do
      @user = User.create!(:name => "Example User", :email => "user@example.com",
        :password => "foobar", :password_confirmation => "foobar")
      controller.sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end

    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url, :content => "change")
    end
    
  end
  
  describe "PUT 'update'" do

    before(:each) do
      @user = User.create!(:name => "Example User", :email => "user@example.com",
        :password => "foobar", :password_confirmation => "foobar")
      controller.sign_in(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = { :email => "", :name => "", 
          :password => "", :password_confirmation => "" }
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
          :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should  == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(edit_user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
      
    end
    
  end
  
  describe "authentication of edit/update pages" do

    before(:each) do
      @user = User.create!(:name => "Example User", :email => "user@example.com",
        :password => "foobar", :password_confirmation => "foobar")
    end

    describe "for non-signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
      
    end
    
    describe "for signed-in users" do

      before(:each) do
        wrong_user = User.create!(:name => "Example User", :email => "user@example.net",
        :password => "foobar", :password_confirmation => "foobar")
        controller.sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
      
    end
    
  end
  
  describe "GET 'index'" do

    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    describe "for signed-in users" do

      before(:each) do
        data = {
          :name => "Example User", :email => "user@example.com",
          :password => "foobar", :password_confirmation => "foobar"
        }
        user = User.create!(data)
        @user = controller.sign_in(user)
        second = User.create!(data.merge(:email => "another@example.com"))
        third  = User.create!(data.merge(:email => "another@example.net"))

        @users = [@user, second, third]
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        @users.each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end
      
    end
    
  end
  
  describe "DELETE 'destroy'" do

    before(:each) do
      @user = User.create!(:name => "Example User", :email => "user@example.com",
        :password => "foobar", :password_confirmation => "foobar")
    end

    describe "as a non-admin user" do
      it "should protect the page" do
        controller.sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "as an admin user" do

      before(:each) do
        admin = User.create!(:name => "Admin", :email => "admin@example.com",
          :password => "foobar", :password_confirmation => "foobar")
        admin.toggle!(:admin)
        controller.sign_in(admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
      
    end
    
  end
  
end