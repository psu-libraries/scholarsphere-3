# frozen_string_literal: true

require 'rails_helper'

describe CurationConcerns::Actors::GenericWorkActor do
  let(:user) { create(:user) }
  let(:work) { build(:work, user: user) }

  let(:actor_stack) { CurationConcerns::Actors::ActorStack.new(work, user, [described_class]) }

  before do
    actor_stack.create(attributes)

    # saving work to be certain we are looking at the work in the repository
    work.save
    work.reload
  end

  context 'with ordered attributes' do
    let(:attributes) do
      { title: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'] }
    end

    it 'keeps the correct order' do
      expect(work.title).to eq(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'])
    end
  end

  context 'with an existing Alias record' do
    let!(:existing_alias) { create(:alias, :with_agent) }
    let(:attributes) do
      {
        title: ['A title'],
        creators: { '0' => { id: existing_alias.id } }
      }
    end

    it 'sets creator to existing Alias record' do
      expect(work.creators).to eq [existing_alias]
    end
  end

  context 'creator id nil' do
    let(:attributes) do
      {
        title: ['A title'],
        creators: { '0' => { id: nil, given_name: 'first', sur_name: 'last', display_name: 'first last' } }
      }
    end

    it 'sets the creators' do
      expect(work.creators.map(&:display_name)).to eq ['first last']
    end
  end

  context 'when uploading on behalf of another user' do
    subject { work }

    let(:other_user) { create(:user) }
    let(:attributes) { { title: ['Sample'], on_behalf_of: other_user.login } }

    its(:depositor) { is_expected.to eq(other_user.login) }
  end

  context 'with non-UTF-8 encoding' do
    let(:string) { "# Sample readme with bad characters\n\nincorrect dashes ��� are replaced with default characters.\n" }
    let(:attributes) { { description: [File.open(File.join(fixture_path, 'bad_readme.md'), 'rb').read] } }

    it 'converts the content to UTF-8' do
      expect(work.description).to contain_exactly(string)
      expect(work.description.first.encoding.name).to eq('UTF-8')
    end
  end
end
