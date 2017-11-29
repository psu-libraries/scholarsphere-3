# frozen_string_literal: true

require 'rails_helper'

describe Migration::SolrWorkList, clean: true do
  subject { described_class.new.works }

  let(:work)  { build :work, id: '123abc' }
  let(:work2) { build :work, id: '567abc' }
  let(:work3) { build :work, id: '999abc' }
  let(:conn)  { ActiveFedora::SolrService.instance.conn }
  let(:creator) { 'abc for me' }

  before do
    save_work_to_solr_and_fake_fedora(work, 'abc for me')
    save_work_to_solr_and_fake_fedora(work2, 'abc for me')
    save_work_to_solr_and_fake_fedora(work3, 'abc for me too')
  end
  after do
    ActiveFedora::Cleaner.cleanout_solr
  end
  it { is_expected.to contain_exactly(work.id, work2.id, work3.id) }

  it 'translates to object during each' do
    described_class.new.each_with_load { |item| expect(item.class).to eq(GenericWork) }
  end
end
