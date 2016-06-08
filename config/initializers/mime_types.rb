# frozen_string_literal: true
# Be sure to restart your server when you modify this file.Mime::Type.register_alias "text/plain", :refworks_marc_txt
Mime::Type.register_alias "text/plain", :openurl_kev
Mime::Type.register_alias "text/plain", :refworks_marc_txt
Mime::Type.register_alias "text/html", :textile
Mime::Type.register_alias "text/html", :inline
Mime::Type.register "application/x-endnote-refer", :endnote
Mime::Type.register "application/marc", :marc
Mime::Type.register "application/marcxml+xml", :marcxml, ["application/x-marc+xml", "application/x-marcxml+xml", "application/marc+xml"]
Mime::Type.register "audio/mpeg", :audio
Mime::Type.register "application/n-triples", :nt
Mime::Type.register "application/ld+json", :jsonld
Mime::Type.register "text/turtle", :ttl
