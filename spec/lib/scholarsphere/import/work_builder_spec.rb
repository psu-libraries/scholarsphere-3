# frozen_string_literal: true

require 'rails_helper'

describe Import::WorkBuilder do
  let(:sufia6_user) { 's6user' }
  let(:sufia6_password) { 's6password' }
  let(:builder) { described_class.new }

  let(:gf_metadata) { JSON.parse(json, symbolize_names: true) }
  let(:gf_metadata2) { JSON.parse(json2, symbolize_names: true) }

  let(:json) do
    generic_file_json(id: 'th83kz34n',
                      date_uploaded: '2016-06-21T09:08:00.000+00:00',
                      date_modified: '2016-06-21T09:08:00.000+00:00',
                      rights: 'All rights reserved')
  end
  let(:import_directory) { File.join(fixture_path, 'import') }
  let(:json_file_name) { File.join(import_directory, 'generic_file_zp38wc72r.json') }
  let(:json2) { File.read(json_file_name) }

  # let(:json2) do
  #   generic_file_json(id: "different_id",
  #                     title: ["A different work"],
  #                     creator: ["Adams, Nancy E.",
  #                               "Gaffney, Maureen A.",
  #                               "Lynn, Valerie"])
  # end
  #
  let(:permission_builder) { instance_double(Sufia::Import::PermissionBuilder) }

  before do
    allow(Sufia::Import::PermissionBuilder).to receive(:new).and_return(permission_builder)
  end

  it 'creates a Work with metadata and permissions' do
    expect(permission_builder).to receive(:build).with(an_instance_of(Sufia.primary_work_type), gf_metadata[:permissions])
    work = builder.build(gf_metadata)
    expect(work.id).to eq 'th83kz34n'
    expect(work.label).to eq '15040187724_9e2f2d7c21_z.jpg'
    expect(work.depositor).to eq 'cam156@psu.edu'
    expect(work.arkivo_checksum).to eq 'arkivo checksum'
    expect(work.relative_path).to eq 'relative path'
    expect(work.import_url).to eq 'import url'
    expect(work.resource_type).to eq ['resource type']
    expect(work.title).to eq(['My Awesone File'])
    expect(work.creator).to eq ['cam156@psu.edu']
    expect(work.contributor).to include 'contributor1'
    expect(work.contributor).to include 'contribnutor2'
    expect(work.description).to eq ['description of the file']
    expect(work.keyword).to include 'tag1'
    expect(work.keyword).to include 'tag2'
    expect(work.rights).to eq ['http://www.europeana.eu/portal/rights/rr-r.html']
    expect(work.publisher).to eq ['publisher joe']
    expect(work.date_created).to eq ['a long time ago']
    expect(work.date_uploaded).to eq DateTime.parse('2016-06-21T09:08:00.000+00:00')
    expect(work.date_modified).to eq DateTime.parse('2016-06-21T09:08:00.000+00:00')
    expect(work.subject).to include 'subject 1'
    expect(work.subject).to include 'subject 2'
    expect(work.language).to eq ['WA Language WA']
    expect(work.identifier).to eq ['You ID ME']
    expect(work.based_near).to eq ['Kalamazoo']
    expect(work.related_url).to eq ['abc123.org']
    expect(work.bibliographic_citation).to eq ['cite me']
    expect(work.source).to eq ['source of me']
    expect(work.visibility).to eq 'restricted'
  end

  context 'when used more than once' do
    before do
      allow(permission_builder).to receive(:build)
    end
    it 'creates a distinct Works' do
      work1 = builder.build(gf_metadata)
      work2 = builder.build(gf_metadata2)
      expect(work1.title).to eq ['My Awesone File']
      expect(work1.id).to eq 'th83kz34n'
      expect(work2.title).to eq ['another title for us']
      expect(work2.id).to eq 'abc123'
      expect(work2.creator).to eq ['Adams, Nancy E.', 'Gaffney, Maureen A.', 'Lynn, Valerie']
    end
  end
end
