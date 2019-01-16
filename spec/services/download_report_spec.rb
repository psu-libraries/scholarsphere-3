# frozen_string_literal: true

require 'rails_helper'

describe GoogleAnalytics::DownloadReport do
  let(:start_date) { 2.days.ago }
  let(:end_date)   { 1.day.ago }
  let(:report) { described_class.new(start_date, end_date) }
  let(:user1)      { create(:user) }
  let(:user2)      { create(:user) }

  context 'calling out to Legato' do
    let(:profile) { instance_double Legato::Management::Profile }
    let(:view_query) { instance_double Legato::Query }
    let(:download_query) { instance_double Legato::Query }

    before do
      allow(Sufia::Analytics).to receive(:profile).and_return(profile)
      allow(view_query).to receive(:dimensions).and_return []
      allow(view_query).to receive(:select).and_return []
      allow(download_query).to receive(:dimensions).and_return []
      allow(download_query).to receive(:each)
    end

    describe 'views and downloads' do
      it 'gets results only once' do
        expect(Sufia::Download).to receive(:results).once.with(profile, start_date: start_date, end_date: end_date, sort: :pagePath).and_return(download_query)
        report.work_downloads
        report.file_set_downloads
        report.work_downloads
        report.file_set_downloads
      end
    end
  end

  context 'Google analytics stubbed' do
    let(:download_results) {
      [OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170815', pagePath: '/downloads/3xs55m950', totalEvents: '1'),
       OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170817', pagePath: '/downloads/3xs55m950', totalEvents: '1'),
       OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170819', pagePath: '/downloads/3xs55m950', totalEvents: '1'),
       OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170819', pagePath: '/downloads/other_missing', totalEvents: '1'),
       OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170819', pagePath: '/downloads/gone_baby', totalEvents: '1'),
       OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170817', pagePath: '/downloads/19953w999z', totalEvents: '1'),
       OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170820', pagePath: '/downloads/19953w999z', totalEvents: '1'),
       OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170820', pagePath: '/downloads/19953w999z?abc=123', totalEvents: '1')]
    }

    let(:generic_file_with_fileset) { GenericWork.new(id: '3xs55m950', depositor: user2.login) }

    before do
      allow(report).to receive(:google_analytics_download_results).and_return(download_results)
      allow(generic_file_with_fileset).to receive(:file_sets).and_return([FileSet.new(id: '3xs55m950_file', depositor: user2.login)])
      allow(ActiveFedora::Base).to receive(:find).with('3xs55m950').twice.and_return(generic_file_with_fileset)
      allow(ActiveFedora::Base).to receive(:find).with('1vh53wt10').once.and_return(GenericWork.new(id: '1vh53wt10', depositor: user2.login))
      allow(ActiveFedora::Base).to receive(:find).with('19953w999z').once.and_return(FileSet.new(id: '19953w999z', depositor: user1.login))
      allow(ActiveFedora::Base).to receive(:find).with('other_missing').and_raise(ActiveFedora::ObjectNotFoundError)
      allow(ActiveFedora::Base).to receive(:find).with('gone_baby').and_raise(Ldp::Gone)
    end

    describe '#work_downloads' do
      subject { report.work_downloads }

      it { expect(subject).to eq([OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170815', pagePath: '/downloads/3xs55m950', totalEvents: '1'),
                                  OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170817', pagePath: '/downloads/3xs55m950', totalEvents: '1'),
                                  OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170819', pagePath: '/downloads/3xs55m950', totalEvents: '1')])
      }
    end

    describe '#file_set_downloads' do
      subject { report.file_set_downloads }

      it { expect(subject).to eq([OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170817', pagePath: '/downloads/19953w999z', totalEvents: '1'),
                                  OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170820', pagePath: '/downloads/19953w999z', totalEvents: '1'),
                                  OpenStruct.new(eventCategory: 'Files', eventAction: 'Downloaded', eventLabel: '(not set)', date: '20170820', pagePath: '/downloads/19953w999z?abc=123', totalEvents: '1')])
      }
    end
  end

  private

    def map_to_hash(list, field_id)
      list.map do |stat|
        hash = {}
        hash[:date] = stat.date
        hash[field_id] = stat.send(field_id)
        hash[:user_id] = stat.user_id
        hash.to_json
      end
    end
end
