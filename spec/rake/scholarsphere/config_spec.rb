# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'scholarsphere:config' do
  before do
    load_rake_environment ["#{Rails.root}/lib/tasks/scholarsphere/config.rake"]
  end

  describe ':check' do
    it 'checks the validity of our production yaml files' do
      run_task('scholarsphere:config:check')
    end
  end
end
