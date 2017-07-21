# frozen_string_literal: true

# These must be required here so that Pageview and Download classes will properly load Legato's
# additional methods. This allows for the rake tasks to have access to legato.
require "legato"
require "sufia/pageview"
require "sufia/download"
