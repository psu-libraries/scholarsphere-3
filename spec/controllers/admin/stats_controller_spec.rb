# frozen_string_literal: true

require 'rails_helper'

describe Admin::StatsController, type: :controller do
  let(:query_service) { Sufia::QueryService.new }

  before { allow(controller).to receive(:query_service).and_return(query_service) }
  describe '#export' do
    context 'when format is csv' do
      let(:header) { "Work Url,Work Id,Work Title,Work Resource Type,Work Rights,File Set Url,File Set Time Uploaded,File Set Id,File Set Title,File Set Depositor,File Set Creator,File Set Visibility,File Set File Format\n" }

      before do
        allow(query_service).to receive(:find_by_date_created).and_return(file_list)
      end
      context 'no files' do
        let(:file_list) { [] }

        it 'exports csv' do
          get :export, format: 'csv'
          expect(response.status).to eq(200)
          expect(response.body).to eq(header)
        end
      end
      context 'with files' do
        let(:file_list) { [create(:work, :with_one_file, file_title: ['my file'])] }

        it 'exports csv' do
          get :export, format: 'csv'
          expect(response.status).to eq(200)
          expect(response.body).to include(header)
          expect(response.body).to include('my file')
        end
      end

      context 'with dates' do
        let(:start_datetime_str) { start_datetime.to_s }
        let(:end_datetime_str) { end_datetime.to_s }
        let(:begining) { start_datetime.beginning_of_day.to_datetime }
        let(:ending) { end_datetime.end_of_day.to_datetime }

        context 'with start date' do
          let(:file_list) { [build(:file, id: 'abc123', title: ['my file'])] }
          let(:start_datetime) { 2.days.ago }
          let(:end_datetime) { 1.day.ago.end_of_day }

          it 'defaults end date and pasess start date parameters' do
            expect(query_service).to receive(:find_by_date_created).with(begining, ending).and_return([])
            get :export, format: 'csv', start_datetime: start_datetime_str
          end
        end

        context 'with end date' do
          let(:file_list) { [build(:file, id: 'abc123', title: ['my file'])] }
          let(:start_datetime) { 1.day.ago.beginning_of_day }
          let(:end_datetime) { 1.day.ago }

          it 'defaults start date and pasess end date parameters' do
            expect(query_service).to receive(:find_by_date_created).with(begining, ending).and_return([])
            get :export, format: 'csv', end_datetime: end_datetime_str
          end
        end

        context 'with start and end date parameters' do
          let(:file_list) { [build(:file, id: 'abc123', title: ['my file'])] }
          let(:start_datetime) { 2.days.ago }
          let(:end_datetime) { 1.day.ago }

          it 'pasess start and end date' do
            expect(query_service).to receive(:find_by_date_created).with(begining, ending).and_return([])
            get :export, format: 'csv', start_datetime: start_datetime_str, end_datetime: end_datetime_str
          end
        end
      end
    end

    context 'when format is html' do
      it 'renders the form' do
        get :export
        expect(response).to be_success
        expect(response).to render_template('admin/stats/export')
      end
    end
  end
end
