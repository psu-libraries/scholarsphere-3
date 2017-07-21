# frozen_string_literal: true
require "rails_helper"

describe ApplicationController do
  subject { response }

  context "with ActiveFedora::ObjectNotFoundError" do
    controller do
      def index
        raise ActiveFedora::ObjectNotFoundError
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(404) }
  end

  context "with AbstractController::ActionNotFound" do
    controller do
      def index
        raise AbstractController::ActionNotFound
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(404) }
  end

  context "with ActionController::RoutingError" do
    controller do
      def index
        raise ActionController::RoutingError.new("message")
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(404) }
  end

  context "with ActionDispatch::Cookies::CookieOverflow" do
    controller do
      def index
        raise ActionDispatch::Cookies::CookieOverflow
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  context "with ActionView::Template::Error" do
    controller do
      def index
        raise ActionView::Template::Error.new(nil, nil)
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  context "with ActiveRecord::RecordNotFound" do
    controller do
      def index
        raise ActiveRecord::RecordNotFound
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(404) }
  end

  context "with ActiveRecord::StatementInvalid" do
    controller do
      def index
        raise ActiveRecord::StatementInvalid.new(nil)
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  context "with Blacklight::Exceptions::ECONNREFUSED" do
    controller do
      def index
        raise Blacklight::Exceptions::ECONNREFUSED
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  context "with Blacklight::Exceptions::InvalidSolrID" do
    controller do
      def index
        raise Blacklight::Exceptions::InvalidSolrID
      end
    end
    before { get :index }
    it "returns a 404" do
      pending "Returning 500 instead of 404"
      expect(response.status).to be(404)
    end
  end

  context "with Errno::ECONNREFUSED" do
    controller do
      def index
        raise Errno::ECONNREFUSED
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  context "with NameError" do
    controller do
      def index
        raise NameError
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  context "with Net::LDAP::LdapError" do
    controller do
      def index
        raise Net::LDAP::LdapError
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  context "with Redis::CannotConnectError" do
    controller do
      def index
        raise Redis::CannotConnectError
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  context "with RSolr::Error::Http" do
    controller do
      def index
        raise RSolr::Error::Http.new({ uri: "uri" }, nil)
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  context "with Ldp::BadRequest" do
    controller do
      def index
        raise Ldp::BadRequest
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  context "with RuntimeError" do
    controller do
      def index
        raise RuntimeError
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  context "with StandardError" do
    controller do
      def index
        raise StandardError
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(500) }
  end

  describe "#render_404" do
    controller do
      def index
        render_404
      end
    end
    before { get :index }
    its(:status) { is_expected.to be(404) }
  end
end
