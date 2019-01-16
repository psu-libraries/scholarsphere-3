# frozen_string_literal: true

class ClamAV
  include Singleton
  def scanfile(_)
    0
  end

  def loaddb
    nil
  end
end
