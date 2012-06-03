require 'spec_helper'

module Alchemy
  describe Admin::ClipboardController do

    let(:page)            { FactoryGirl.create(:public_page) }
    let(:element)         { FactoryGirl.create(:element, :page => page) }
    let(:another_element) { FactoryGirl.create(:element, :page => page) }

    before(:each) do
      activate_authlogic
      UserSession.create(FactoryGirl.create(:admin_user))
      session[:clipboard] = Clipboard.new
    end

    describe "#insert" do

      it "should hold element ids" do
        post(:insert, {:remarkable_type => :elements, :remarkable_id => element.id, :format => :js})
        session[:clipboard][:elements].should == [{:id => element.id, :action => 'copy'}]
      end

      it "should not have the same element twice" do
        session[:clipboard][:elements] = {:id => element.id, :action => 'copy'}
        post(:insert, {:remarkable_type => :elements, :remarkable_id => element.id, :format => :js})
        session[:clipboard][:elements].collect { |e| e[:id] }.should_not == [element.id, element.id]
      end

    end

    describe "#delete" do
      it "should remove element ids from clipboard" do
        session[:clipboard][:elements] = {:id => element.id, :action => 'copy'}
        session[:clipboard][:elements] << {:id => another_element.id, :action => 'copy'}
        delete(:remove, {:remarkable_type => :elements, :remarkable_id => another_element.id, :format => :js})
        session[:clipboard][:elements].should == [{:id => element.id, :action => 'copy'}]
      end
    end

    describe "#clear" do
      it "should be clearable" do
        session[:clipboard][:elements] = {:id => element.id}
        delete(:clear, :format => :js)
        session[:clipboard].should be_empty
      end
    end

  end
end
