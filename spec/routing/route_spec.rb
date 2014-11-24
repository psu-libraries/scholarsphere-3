require 'spec_helper'

describe 'Routes' do
  describe 'Homepage' do
    it 'should route the root url to the catalog controller' do
      { get: '/' }.should route_to(controller: 'homepage', action: 'index')
    end

  end

  describe 'Catalog' do
    it 'should route to recently added files' do
      { get: '/catalog/recent' }.should route_to(controller: 'catalog', action: 'recent')
    end
  end

  describe 'Sessions' do
    it "should route to logout" do
      { get: '/logout' }.should route_to(controller: 'sessions', action: 'destroy')
    end

    it "should route to login" do
      { get: '/login' }.should route_to(controller: 'sessions', action: 'new')
    end
  end
end
