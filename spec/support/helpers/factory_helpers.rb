# frozen_string_literal: true

module FactoryHelpers
  extend self

  def mock_file_factory(opts = {})
    mock_model('MockFile',
               mime_type:         opts.fetch(:mime_type, 'text/plain'),
               content:           opts.fetch(:content, 'content'),
               file_size:         opts.fetch(:file_size, []),
               format_label:      opts.fetch(:format_label, []),
               height:            opts.fetch(:height, []),
               width:             opts.fetch(:width, []),
               filename:          opts.fetch(:filename, []),
               well_formed:       opts.fetch(:well_formed, []),
               page_count:        opts.fetch(:page_count, []),
               file_title:        opts.fetch(:file_title, []),
               last_modified:     opts.fetch(:last_modified, []),
               original_checksum: opts.fetch(:original_checksum, []),
               digest:            opts.fetch(:digest, []),
               duration:          opts.fetch(:duration, []),
               sample_rate:       opts.fetch(:sample_rate, []))
  end

  # Create a new fileset with a public PNG file and add it to the work
  def add_public_png(work, attributes)
    fs = FactoryGirl.create(:file_set,
                            user: User.find_by(login: work.depositor),
                            title: ['A contained PNG file'],
                            label: 'world.png',
                            visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)

    file_path = "#{Rails.root}/spec/fixtures/world.png"
    IngestFileJob.perform_now(fs, file_path, attributes.user)

    work.ordered_members << fs
    work.thumbnail_id = fs.id
    work.representative_id = fs.id
    work.update_index
  end

  def add_another_version(work, attributes)
    file_path = "#{Rails.root}/spec/fixtures/world.png"
    IngestFileJob.perform_now(work.file_sets.first, file_path, attributes.user)
  end

  def add_public_pdf(work, attributes)
    fs = FactoryGirl.create(:file_set,
                            user: User.find_by(login: work.depositor),
                            title: ['A full-text pdf file'],
                            label: 'test.pdf',
                            visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)

    file_path = "#{Rails.root}/spec/fixtures/test.pdf"
    IngestFileJob.perform_now(fs, file_path, attributes.user)

    work.ordered_members << fs
    work.thumbnail_id = fs.id
    work.representative_id = fs.id
    work.update_index
  end

  def add_public_readme(work, attributes)
    fs = FactoryGirl.create(:file_set,
                            user: User.find_by(login: work.depositor),
                            title: ['README'],
                            label: 'readme.md',
                            visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)

    file_path = "#{Rails.root}/spec/fixtures/readme.md"
    IngestFileJob.perform_now(fs, file_path, attributes.user)

    work.ordered_members << fs
    work.thumbnail_id = fs.id
    work.representative_id = fs.id
    work.save
  end

  def add_public_mp3(work, attributes)
    fs = FactoryGirl.create(:file_set,
                            user: attributes.user,
                            title: ['A contained MP3 file'],
                            label: 'scholarsphere_test5.mp3',
                            visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)

    filename = "#{Rails.root}/spec/fixtures/scholarsphere/scholarsphere_test5.mp3"
    local_file = File.open(filename, 'rb')
    Hydra::Works::AddFileToFileSet.call(fs, local_file, :original_file, versioning: false)
    fs.save!
    work.ordered_members << fs
    work.thumbnail_id = fs.id
  end
end
