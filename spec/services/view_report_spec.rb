# frozen_string_literal: true

require 'rails_helper'

describe GoogleAnalytics::ViewReport do
  let(:start_date) { 2.days.ago }
  let(:end_date)   { 1.day.ago }
  let(:report) { described_class.new(start_date, end_date) }
  let(:profile) { instance_double Legato::Management::Profile }
  let(:view_query) { instance_double Legato::Query }

  context 'contacting Legato' do
    before do
      allow(Sufia::Analytics).to receive(:profile).and_return(profile)
      allow(view_query).to receive(:dimensions).and_return []
      allow(view_query).to receive(:select).and_return []
    end

    it 'gets results only once' do
      expect(Sufia::Pageview).to receive(:results).once.with(profile, start_date: start_date, end_date: end_date, sort: :pagePath).and_return(view_query)
      report.work_page_views
      report.file_set_page_views
      report.work_page_views
      report.file_set_page_views
    end
  end

  context 'with results to separate' do
    let(:view_results) {
      [OpenStruct.new(date: '20170815', pagePath: '/', pageviews: '20'),
       OpenStruct.new(date: '20170815', pagePath: '/about', pageviews: '4'),
       OpenStruct.new(date: '20170815', pagePath: '/concern/parent/3xs55m9505/file_sets/fj67314220', pageviews: '0'),
       OpenStruct.new(date: '20170818', pagePath: '/concern/parent/3xs55m9505/file_sets/fj67314220', pageviews: '0'),
       OpenStruct.new(date: '20170822', pagePath: '/concern/parent/3xs55m9505/file_sets/fj67314220', pageviews: '0'),
       OpenStruct.new(date: '20170816', pagePath: '/concern/file_sets/nzs25x853x', pageviews: '1'),
       OpenStruct.new(date: '20170819', pagePath: '/concern/file_sets/nzs25x853x', pageviews: '1'),
       OpenStruct.new(date: '20170820', pagePath: '/concern/file_sets/nzs25x853x', pageviews: '1'),
       OpenStruct.new(date: '20170820', pagePath: '/concern/parent/1vh53wt10z/file_sets/4f4752g26g', pageviews: '0'),
       OpenStruct.new(date: '20170815', pagePath: '/concern/generic_works/3xs55m9505', pageviews: '1'),
       OpenStruct.new(date: '20170820', pagePath: '/concern/generic_works/3xs55m9505', pageviews: '3'),
       OpenStruct.new(date: '20170825', pagePath: '/concern/generic_works/3xs55m9505', pageviews: '1'),
       OpenStruct.new(date: '20170816', pagePath: '/concern/generic_works/1vh53wt10', pageviews: '1'),
       OpenStruct.new(date: '20170822', pagePath: '/concern/generic_works/1vh53wt10', pageviews: '1')]
    }

    before do
      allow(report).to receive(:google_analytics_view_results).and_return(view_results)
    end

    describe '#work_page_views' do
      subject { report.work_page_views }

      it { expect(subject).to eq([OpenStruct.new(date: '20170815', pagePath: '/concern/generic_works/3xs55m9505', pageviews: '1'),
                                  OpenStruct.new(date: '20170820', pagePath: '/concern/generic_works/3xs55m9505', pageviews: '3'),
                                  OpenStruct.new(date: '20170825', pagePath: '/concern/generic_works/3xs55m9505', pageviews: '1'),
                                  OpenStruct.new(date: '20170816', pagePath: '/concern/generic_works/1vh53wt10', pageviews: '1'),
                                  OpenStruct.new(date: '20170822', pagePath: '/concern/generic_works/1vh53wt10', pageviews: '1')])
      }
    end

    describe '#file_set_page_views' do
      subject { report.file_set_page_views }

      it { expect(subject).to eq([OpenStruct.new(date: '20170815', pagePath: '/concern/parent/3xs55m9505/file_sets/fj67314220', pageviews: '0'),
                                  OpenStruct.new(date: '20170818', pagePath: '/concern/parent/3xs55m9505/file_sets/fj67314220', pageviews: '0'),
                                  OpenStruct.new(date: '20170822', pagePath: '/concern/parent/3xs55m9505/file_sets/fj67314220', pageviews: '0'),
                                  OpenStruct.new(date: '20170816', pagePath: '/concern/file_sets/nzs25x853x', pageviews: '1'),
                                  OpenStruct.new(date: '20170819', pagePath: '/concern/file_sets/nzs25x853x', pageviews: '1'),
                                  OpenStruct.new(date: '20170820', pagePath: '/concern/file_sets/nzs25x853x', pageviews: '1'),
                                  OpenStruct.new(date: '20170820', pagePath: '/concern/parent/1vh53wt10z/file_sets/4f4752g26g', pageviews: '0')])
      }
    end
  end
end
