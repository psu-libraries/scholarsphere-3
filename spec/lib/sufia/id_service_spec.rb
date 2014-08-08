require 'spec_helper'

describe Sufia::IdService do
  it "should respond to mint" do
    Sufia::IdService.should respond_to(:mint)
  end
  describe "mint" do
    before(:all) do
      @id = Sufia::IdService.mint
    end
    it "should create a unique id" do
      @id.should_not be_empty
    end
    it "should look like a ScholarSphere id" do
      @id.should match(/scholarsphere\:.{9}/)
    end
    it "should not mint the same id twice in a row" do
      other_id = Sufia::IdService.mint
      other_id.should_not == @id
    end
  end
end
