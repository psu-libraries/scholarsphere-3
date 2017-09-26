# frozen_string_literal: true

require 'rails_helper'

describe NullRepresentativePresenter do
  subject { presenter }

  let(:current_ability) { Ability.new(nil) }
  let(:presenter)       { described_class.new(current_ability, nil) }

  describe '#has?' do
    it 'has a thumbnail url' do
      expect(subject.has?('thumbnail_path_ss')).to be true
    end
  end

  describe '#display_download_link?' do
    its(:display_download_link?) { is_expected.to be false }
  end
end
