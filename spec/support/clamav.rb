# frozen_string_literal: true
class ClamAV
  include Singleton
  def scanfile(_f)
    0
  end

  def loaddb
    nil
  end
end
