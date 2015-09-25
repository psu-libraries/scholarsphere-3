require 'spec_helper'

describe 'Routes', type: :routing do
  describe 'Homepage' do
    it 'routes the root url to the catalog controller' do
      expect(get: '/').to route_to(controller: 'homepage', action: 'index')
    end
  end

  describe 'Catalog' do
    it 'routes to recently added files' do
      expect(get: '/catalog/recent').to route_to(controller: 'catalog', action: 'recent')
    end
  end

  describe 'Sessions' do
    it "routes to logout" do
      expect(get: '/logout').to route_to(controller: 'sessions', action: 'destroy')
    end

    it "routes to login" do
      expect({ get: '/login' }).to route_to(controller: 'sessions', action: 'new')
    end
  end

  describe 'Stats Export' do
    before do
      allow(Sufia::StatsAdmin).to receive(:matches?).and_return(true)
    end
    it "routes to export" do
      expect(get: 'admin/stats/export').to route_to(controller: 'admin/stats', action: 'export')
    end
  end
end
