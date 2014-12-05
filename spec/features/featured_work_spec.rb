require_relative './feature_spec_helper'

describe "Featured works on the home page", :type => :feature do
  let!(:admin_user) { create :administrator }
  let!(:jill_user) { create :jill }
  let!(:file) { create_file admin_user, {title:'file title'} }
  let!(:featured_work) { FeaturedWork.create!(generic_file_id: file.noid) }

  let!(:file2) { create_file admin_user, {title:'another_title_bites_the_dust'} }
  let!(:featured_work2) { FeaturedWork.create!(generic_file_id: file2.noid) }

  let!(:private_file) { create_file jill_user, {title:'private_document', read_groups:['private']} }

  before do
    sign_in_as admin_user
    visit "/"
  end

  it "appears as a featured work", js:true do
    expect(page).to have_content "Featured Works"
    within("#featured_container") do
      expect(page).to have_content(file.title[0])
    end
  end

  it "only public documents appear as recently uploaded files" do
    click_link "Recent Additions"
    within("#recently_uploaded") do
      expect(page).to have_content(file.title[0])
      expect(page).to have_no_content(private_file.title[0])
    end
  end

  it 'allows the user to remove it as a featured work' do
    document = find('li.dd-item:nth-of-type(1)')
    expect(document['data-id']).to eq(file.noid)

    within('li.dd-item:nth-of-type(1)') do
      expect(page).to have_css '.glyphicon-remove'
      find('.glyphicon-remove').click
      expect(page).to have_no_content(file.title[0])
    end
  end

  it 'removes a featured work if it becomes private' do
    within('#featured_container') do
      expect(page).to have_content(file2.title[0])
    end

    click_on file2.title[0]
    click_on 'Edit'
    click_on 'Permissions'
    find('#visibility_restricted').click
    click_on 'Save'
    visit '/'

    within('#featured_container') do
      expect(page).to have_no_content(file2.title[0])
    end
  end

end
