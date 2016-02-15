# frozen_string_literal: true
require 'spec_helper'

describe RedirectToWebAccessFailure do
  def call_failure(env_params = {})
    env = {
      'REQUEST_URI' => 'http://test.host/',
      'HTTP_HOST' => 'test.host',
      'REQUEST_METHOD' => 'GET',
      'warden.options' => { scope: :user },
      'rack.session' => {},
      'action_dispatch.request.formats' => Array(env_params.delete('formats') || Mime::HTML),
      'rack.input' => "",
      'warden' => OpenStruct.new(message: nil)
    }.merge!(env_params)

    @response = RedirectToWebAccessFailure.call(env).to_a
    @request  = ActionDispatch::Request.new(env)
  end
  describe "when http_auth? is false" do
    it "does not set flash" do
      call_failure
      expect(@response.first).to eq 302
      expect(@response.second['Location']).to eq 'https://webaccess.psu.edu/?cosign-localhost&https://localhost'
      expect(@request.flash[:alert]).to be_nil
    end
  end
end
