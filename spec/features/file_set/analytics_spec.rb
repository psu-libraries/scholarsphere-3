# frozen_string_literal: true
require "feature_spec_helper"

# Notice that with Sufia 7 we generate thumbnails at the FileSets level
# in a similar way to what we did in Sufia 6 for GenericFiles.
describe "FileSet Thumbnail Creation:", type: :feature do
  let(:work)           { create(:public_work_with_png, file_title: ["Some work"], depositor: current_user.login) }
  let(:current_user)   { create(:user) }
  let(:file_set)       { work.file_sets.first }
  let(:thumbnail_path) { main_app.download_path(file_set, file: "thumbnail") }
  let(:today)          { Time.zone.today }
  let(:four_days_ago)  { (Time.zone.today - 4.days) }

  let(:dates) do
    ldates = []
    4.downto(0) { |idx| ldates << (today - idx.day) }
    ldates
  end

  let(:date_strs) do
    ldate_strs = []
    dates.each { |date| ldate_strs << date.strftime("%Y%m%d") }
    ldate_strs
  end

  let(:sample_download_statistics) do
    [
      OpenStruct.new(eventCategory: "Files", eventAction: "Downloaded", eventLabel: "sufia:x920fw85p", date: date_strs[0], totalEvents: "1"),
      OpenStruct.new(eventCategory: "Files", eventAction: "Downloaded", eventLabel: "sufia:x920fw85p", date: date_strs[1], totalEvents: "1"),
      OpenStruct.new(eventCategory: "Files", eventAction: "Downloaded", eventLabel: "sufia:x920fw85p", date: date_strs[2], totalEvents: "2"),
      OpenStruct.new(eventCategory: "Files", eventAction: "Downloaded", eventLabel: "sufia:x920fw85p", date: date_strs[3], totalEvents: "3"),
      OpenStruct.new(eventCategory: "Files", eventAction: "Downloaded", eventLabel: "sufia:x920fw85p", date: date_strs[4], totalEvents: "5")
    ]
  end

  let(:sample_pageview_statistics) do
    [
      OpenStruct.new(date: date_strs[0], pageviews: 4),
      OpenStruct.new(date: date_strs[1], pageviews: 8),
      OpenStruct.new(date: date_strs[2], pageviews: 6),
      OpenStruct.new(date: date_strs[3], pageviews: 10),
      OpenStruct.new(date: date_strs[4], pageviews: 2)
    ]
  end

  before do
    allow_any_instance_of(FileSet).to receive(:create_date).and_return(today.to_s)
    allow_any_instance_of(FileSet).to receive(:date_uploaded).and_return(four_days_ago.to_s)
    expect(FileDownloadStat).to receive(:ga_statistics).and_return(sample_download_statistics)
    expect(FileViewStat).to receive(:ga_statistics).and_return(sample_pageview_statistics)
    sign_in(current_user)
    visit "/concern/file_sets/#{file_set.id}"
  end

  it "renders without error" do
    pending("Passes when run individually, but raises:
      Routing Error uninitialized constant Sufia::SingularSubresourceController::DenyAccessOverrideBehavior
      when run in the suite. See #379")
    click_on "Analytics"
    expect(page).to have_text("30 views and 12 downloads since #{four_days_ago.strftime('%B %-d, %Y')}")
  end
end
