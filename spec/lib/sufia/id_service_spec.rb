require 'spec_helper'

describe Sufia::IdService do
  it "should respond to mint" do
    expect(Sufia::IdService).to respond_to(:mint)
  end
  describe "mint" do
    before(:all) do
      @id = Sufia::IdService.mint
    end
    it "should create a unique id" do
      expect(@id).not_to be_empty
    end
    it "should look like a ScholarSphere id" do
      expect(@id).to match(/scholarsphere\:.{9}/)
    end
    it "should not mint the same id twice in a row" do
      other_id = Sufia::IdService.mint
      expect(other_id).not_to eq(@id)
    end
  end
end
