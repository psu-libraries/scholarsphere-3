# frozen_string_literal: true
class StaticController < ApplicationController
  rescue_from AbstractController::ActionNotFound, with: :render_404

  def help
    @page = ContentBlock.find_or_create_by(name: "help_faq")
  end

  def zotero
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def mendeley
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def licenses
    @page = ContentBlock.find_or_create_by(name: ContentBlock::LICENSE)
  end
end
