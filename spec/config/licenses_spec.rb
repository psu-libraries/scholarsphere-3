# frozen_string_literal: true
require "rails_helper"

describe CurationConcerns::LicenseService do
  let(:service) { described_class.new }

  describe "all licenses" do
    let(:all_license_urls) do
      [
        "http://creativecommons.org/licenses/by/3.0/us/",
        "http://creativecommons.org/licenses/by-sa/3.0/us/",
        "http://creativecommons.org/licenses/by-nc/3.0/us/",
        "http://creativecommons.org/licenses/by-nd/3.0/us/",
        "http://creativecommons.org/licenses/by-nc-nd/3.0/us/",
        "http://creativecommons.org/licenses/by-nc-sa/3.0/us/",
        "https://creativecommons.org/licenses/by/4.0/",
        "https://creativecommons.org/licenses/by-sa/4.0/",
        "https://creativecommons.org/licenses/by-nc/4.0/",
        "https://creativecommons.org/licenses/by-nd/4.0/",
        "https://creativecommons.org/licenses/by-nc-nd/4.0/",
        "https://creativecommons.org/licenses/by-nc-sa/4.0/",
        "http://creativecommons.org/publicdomain/mark/1.0/",
        "http://creativecommons.org/publicdomain/zero/1.0/",
        "http://www.europeana.eu/portal/rights/rr-r.html",
        "http://www.apache.org/licenses/LICENSE-2.0",
        "https://www.gnu.org/licenses/gpl.html",
        "https://opensource.org/licenses/MIT"
      ]
    end
    subject { service.select_all_options.map(&:last) }
    it { is_expected.to contain_exactly(*all_license_urls) }
  end

  describe "active licenses" do
    let(:active_license_urls) do
      [
        "https://creativecommons.org/licenses/by/4.0/",
        "https://creativecommons.org/licenses/by-sa/4.0/",
        "https://creativecommons.org/licenses/by-nc/4.0/",
        "https://creativecommons.org/licenses/by-nd/4.0/",
        "https://creativecommons.org/licenses/by-nc-nd/4.0/",
        "https://creativecommons.org/licenses/by-nc-sa/4.0/",
        "http://creativecommons.org/publicdomain/mark/1.0/",
        "http://creativecommons.org/publicdomain/zero/1.0/",
        "http://www.europeana.eu/portal/rights/rr-r.html",
        "http://www.apache.org/licenses/LICENSE-2.0",
        "https://www.gnu.org/licenses/gpl.html",
        "https://opensource.org/licenses/MIT"
      ]
    end
    subject { service.select_active_options.map(&:last) }
    it { is_expected.to contain_exactly(*active_license_urls) }
  end
end
