# frozen_string_literal: true

require 'rails_helper'

describe 'user_mailer/acknowledgment_email.html.erb', type: :view do
  before { render }

  it 'creates an email with html links' do
    expect(rendered).to include('<a href="https://scholarsphere.psu.edu/help/">help page</a>')
  end
end
