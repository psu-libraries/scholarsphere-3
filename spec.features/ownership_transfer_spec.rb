require_relative './feature_spec_helper'

describe "Sending a transfer" do

  let(:original_owner) { create(:user) }
  let(:new_owner) { create(:user) }

  before do
    sign_in_as original_owner
  end

  context "Given I've successfully uploaded a file" do
    before do
      upload_generic_file 'world.png'
    end

    let (:file) { GenericFile.first }
    context "Transferring the file to someone else" do
      before do
        within "#document_#{file.noid}" do
          caret = find ".dropdown-toggle"
          caret.click
        end
        click_link "Transfer Ownership of File"

       #fill_in "User", with: new_owner.user_key
       #select2(new_owner.user_key)
        select3
        fill_in "Comments", with: "File transfer comments"
        within ".form-actions" do
          button = find(".btn.btn-primary")
          button.click
        end
      end
      pending "Creates a proxy_deposit_request" do
       #p = ProxyDepositRequest.first
       #p.receiving_user.should == new_owner  
        save_and_open_page
        page.should have_content "Transfer request created"
      end
    end
  end
  def select2(value)
    p "%%%% #{value}"
    page.execute_script %Q{
      i = $('.select2-input');
      i.focus().val("#{value}").blur();
    }
    #i.trigger('keydown').val('#{value}').trigger('keyup');
    sleep 2
   #user_option = find('div.select2-result-label')
   #user_option.click
  end
  def select3
    p "%%%% in select3"
    page.execute_script %Q{
      i = $('.select2-input');
      e = $.Event('keypress');
      e.which = 48;
      i.trigger(e);
      e.which = 49;
      i.trigger(e);
    }
    sleep 2
    user_option = find('div.select2-result-label')
    user_option.click
  end
end
