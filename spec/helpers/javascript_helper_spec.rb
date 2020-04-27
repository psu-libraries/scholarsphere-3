# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionView::Helpers::JavaScriptHelper do
  subject { JavaScriptTestHelper.new }

  before do
    class JavaScriptTestHelper
      include ActionView::Helpers::JavaScriptHelper
    end
  end

  after { ActiveSupport::Dependencies.remove_constant('JavaScriptTestHelper') }

  it { is_expected.to respond_to(:javascript_tag) }
  it { is_expected.to respond_to(:javascript_cdata_section) }
  it { is_expected.to respond_to(:old_ej) }
  it { is_expected.to respond_to(:old_j) }

  describe '::JS_ESCAPE_MAP' do
    let(:keys) { ActionView::Helpers::JavaScriptHelper::JS_ESCAPE_MAP }

    it 'includes additional monkey-patched keys' do
      expect(keys.count).to eq(11)
      expect(keys).to include('`', '$')
    end
  end
end
