require_relative './feature_spec_helper'

describe 'Visting the home page:', :type => :feature do

  let!(:current_user) { create :user }

  before :each do
    @blk = ContentBlock.find_or_create_by(name: "marketing_text").tap do |market|
      market.value = "Share. Manage. Preserve."
      market.save
    end
  end

  context 'when logged in' do

    before do
      sign_in_as current_user
    end

    context 'and I do not belong to any groups' do
      before do
        visit '/'
      end
      specify 'I can see the home page' do
        expect(page).to have_content 'Share. Manage. Preserve.'
      end
    end

    context 'and I belong to a couple of groups' do
      before do
        add_groups_to_current_user 2
        visit '/'
      end
      specify 'I can see the home page' do
        expect(page).to have_content 'Share. Manage. Preserve.'
      end
      specify 'I can see that I am logged in' do
        expect(page).to have_content current_user.display_name
      end
    end

    context 'and I belong to a lot of groups' do
      before do
        add_groups_to_current_user 100
        visit '/'
      end
      specify 'I can see the home page' do
        expect(page).to have_content 'Share. Manage. Preserve.'
      end
      specify 'I can see that I am logged in' do
        expect(page).to have_content current_user.display_name
      end
    end

    context 'and tag cloud is shown' do
      let!(:gf1) { create_file current_user, {title:'doc 1', tag:["tagX", "tagY"]} }
      let!(:gf2) { create_file current_user, {title:'doc 2', tag:["tagY", "tagZ"]} }
      specify 'tags are listed' do
        visit '/'
        expect(page).to have_content 'tagX tagY tagZ'
      end

      specify 'clicking on a tag goes to the right URL' do
        visit '/'
        target_url = URI.encode('/catalog?f[tag_sim][]=tagY','[]')
        click_link('tagY')
        expect(current_url).to end_with(target_url)
      end
    end

    context 'with a mobile device' do

      before do
        page.driver.browser.resize(400,600)
        visit "/"
      end

      specify 'then I should not see my name' do
        within('#user_utility_links') do
          expect(page).not_to have_content(current_user.name)
        end
      end

    end
  end

  def add_groups_to_current_user number_of_groups
    group_list_array = []
    (0..number_of_groups).each do |i|
      group_list_array << "umg/up.dlt.scholarsphere-admin.admin#{i}"
    end
    current_user.update_attribute :group_list, group_list_array.join(';?;')
    # groups_last_update can't be nil, otherwise @user.groups will be []
    # (see User.rb (def groups) )
    current_user.update_attribute :groups_last_update, Time.now
    current_user.save!
  end

end