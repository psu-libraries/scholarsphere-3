require_relative 'feature_spec_helper'

include Selectors::Dashboard
include Selectors::EditCollections

describe 'Collection editing:' do

  let!(:current_user) { create :user }
  let(:filenames) { %w{small_file.txt world.png} }
  #let!(:file_1) { create_file current_user, {title:'world.png'} }
  #let!(:file_2) { create_file current_user, {title:'little_file.txt'} }
  #let!(:file_3) { create_file current_user, {title:'scholarsphere_test5.txt'} }
  #let(:collection) { Collection.first }

  before do
    sign_in_as current_user
    filenames.each do |name|
      upload_generic_file name
    end
    @file = find_file_by_title  "small_file.txt"
  end

  describe 'When adding a file to a collection' do

    specify 'I should see the new file in the collection' do
      @file.should_not be_nil
    end
  end

end