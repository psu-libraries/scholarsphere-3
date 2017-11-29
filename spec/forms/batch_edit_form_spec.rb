# frozen_string_literal: true

require 'rails_helper'

describe BatchEditForm do
  describe '::build_permitted_params' do
    subject { described_class }

    its(:build_permitted_params) { is_expected.to include(:visibility) }
    its(:build_permitted_params) { is_expected.to include(creators: [
                                                            :id,
                                                            :display_name,
                                                            :given_name,
                                                            :sur_name,
                                                            :psu_id,
                                                            :email,
                                                            :orcid_id,
                                                            :_destroy
                                                          ]) }
  end

  describe '#initialize_combined_fields' do
    let(:user) { build(:user) }
    let(:ability) { Ability.new(user) }
    let(:work1) { create(:work, :with_complete_metadata, title: ['First batch work']) }
    let(:work2) { create(:work, :with_complete_metadata, title: ['Second batch work']) }
    let(:batch) { [work1.id, work2.id] }
    let(:model) { BatchEditItem.new(batch: batch) }
    let(:form) { described_class.new(model, ability, batch) }

    it 'sets names and model to a combined set of attributes' do
      expect(form.names).to contain_exactly('First batch work', 'Second batch work')
      expect(form.model.creators.map(&:id)).to contain_exactly(work1.creators.first.id, work2.creators.first.id)
      expect(form.model.admin_set_id).to eq('admin_set/default')
      expect(form.model.permissions.map(&:to_hash)).to contain_exactly(name: 'user', type: 'person', access: 'edit')
      expect(form.model.contributor).to contain_exactly('contributorcontributor')
      expect(form.model.description).to contain_exactly('descriptiondescription')
      expect(form.model.keyword).to contain_exactly('tagtag')
      expect(form.model.resource_type).to contain_exactly('resource_typeresource_type')
      expect(form.model.rights).to contain_exactly('http://creativecommons.org/licenses/by/3.0/us/')
      expect(form.model.publisher).to contain_exactly('publisherpublisher')
      expect(form.model.date_created).to contain_exactly('two days after the day before yesterday')
      expect(form.model.subject).to contain_exactly('subjectsubject')
      expect(form.model.language).to contain_exactly('languagelanguage')
      expect(form.model.identifier).to contain_exactly('')
      expect(form.model.based_near).to contain_exactly('based_nearbased_near')
      expect(form.model.related_url).to contain_exactly('http://example.org/TheRelatedURLLink/')
    end
  end
end
