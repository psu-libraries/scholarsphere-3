# frozen_string_literal: true

ClamAV.instance.loaddb unless Rails.env.test?
