# frozen_string_literal: true
require "spec_helper"
require "rake"

describe "scholarsphere:list_users" do
  let!(:user_list) do
    users = []
    (1..3).each do |n|
      users << User.create(login: "user#{n}", email: "user#{n}@example.org")
    end
    users
  end

  # set up the rake environment
  before do
    load_rake_environment ["#{Rails.root}/lib/tasks/scholarsphere.rake"]
  end

  describe 'list users' do
    it 'includes all users' do
      run_task 'scholarsphere:list_users'
      filename = Rails.root.join("user_emails.txt")
      expect(Dir.glob(filename).entries.size).to eq(1)
      f = File.open(filename)
      output = f.read
      user_list.each do |user|
        expect(output).to include(user.email)
      end
    end
  end
end
