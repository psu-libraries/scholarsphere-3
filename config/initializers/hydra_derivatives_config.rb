require 'hydra/derivatives'

Hydra::Derivatives::Video::Processor.timeout = 10.minutes
Hydra::Derivatives::Document.timeout = 5.minutes
Hydra::Derivatives::Audio.timeout = 10.minutes
Hydra::Derivatives::Image.timeout = 5.minutes
Hydra::Derivatives::Video::Processor.config.mpeg4.codec = "-vcodec mpeg4 -acodec aac -strict -2"
