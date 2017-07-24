# frozen_string_literal: true
class SessionsController < ApplicationController
  def destroy
    # make any local additions here (e.g. expiring local sessions, etc.)
    # adapted from here: http://cosign.git.sourceforge.net/git/gitweb.cgi?p=cosign/cosign;a=blob;f=scripts/logout/logout.php;h=3779248c754001bfa4ea8e1224028be2b978f3ec;hb=HEAD

    cookies.delete(request.env['COSIGN_SERVICE']) if request.env['COSIGN_SERVICE']
    redirect_to Sufia::Engine.config.logout_url
  end

  def new
    redirect_url = session['user_return_to']
    session['user_return_to'] = nil if redirect_url # clear so we do not get it next time
    webaccess = Sufia::Engine.config.login_url.split('&')[0]
    dashboard = Sufia::Engine.config.login_url.split('&')[1]
    redirect_to webaccess + '&' + (redirect_url.blank? ? dashboard : redirect_url)
  end
end
