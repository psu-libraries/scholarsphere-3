require 'active_fedora'

namespace :scholarsphere do

  desc "Init Hydra configuration"
  task init: [:environment] do
    # We need to just start rails so that all the models are loaded
  end

  namespace :fixtures do
    @localPart = 'spec/fixtures'
    @fixtureDir = ENV["FIXTURE_DIR"] || 'scholarsphere'

    desc "Create ScholarSphere Hydra fixtures for generation and loading"
    task create: :environment do

      @id = ENV["FIXTURE_ID"] ||'scholarsphere1'
      @title = ENV["FIXTURE_TITLE"] || 'scholarsphere test'
      @user = ENV["FIXTURE_USER"] || 'archivist1'

      @root ='<%=Rails.root%>'

      @inputFoxmlFile = File.join(Rails.root, 'spec', 'fixtures', 'scholarsphere_generic_stub.foxml.erb')
      @inputDescFile = File.join(Rails.root, 'spec', 'fixtures',  'scholarsphere_generic_stub.descMeta.txt')
      @inputTxtFile = File.join(Rails.root, 'spec', 'fixtures',  'scholarsphere_generic_stub.txt')
      @outputFoxmlFile = File.join(Rails.root, @localPart, @fixtureDir, 'scholarsphere_'+@id+'.foxml.erb')
      @outputDescFile = File.join(Rails.root, @localPart, @fixtureDir, 'scholarsphere_'+@id+'.descMeta.txt')
      @outputTxtFile = File.join(Rails.root, @localPart, @fixtureDir, 'scholarsphere_'+@id+'.txt')
      run_erb_stub @inputFoxmlFile, @outputFoxmlFile
      run_erb_stub @inputDescFile, @outputDescFile
      run_erb_stub @inputTxtFile, @outputTxtFile
    end

    desc "Generate default ScholarSphere Hydra fixtures"
    task :generate do
      ENV["dir"] = File.join(Rails.root, @localPart, @fixtureDir)
      fixtures = find_fixtures_erb(@fixtureDir)
      fixtures.each do |fixture|
        unless fixture.include?('generic_stub')
          outFile = fixture.sub('foxml.erb','foxml.xml')
          File.open(outFile, "w+") do |f|
            f.write(ERB.new(get_erb_template fixture).result())
          end
        end
      end
    end

    desc "Load default ScholarSphere Hydra fixtures"
    task :load do
      #ENV["dir"] = File.join(Rails.root, @localPart, @fixtureDir)
      dir = File.join(Rails.root, @localPart, @fixtureDir)
      loader = ActiveFedora::FixtureLoader.new(dir)

      fixtures = find_fixtures_scholar(@fixtureDir)
      fixtures.each do |fixture|
        #ENV["pid"] = fixture
        loader.import_and_index(fixture)
        puts "Loaded '#{fixture}'"
        #Rake::Task["repo:load"].reenable
        #Rake::Task["repo:load"].invoke
      end
      raise "No fixtures found; you may need to generate from erb, use: rake scholarsphere:fixtures:generate" if fixtures.empty?
    end

    desc "Remove default ScholarSphere Hydra fixtures"
    task :delete do
      ENV["dir"] = File.join(Rails.root, @localPart, @fixtureDir)
      fixtures = find_fixtures_scholar(@fixtureDir)
      fixtures.each do |fixture|
        ENV["pid"] = fixture
        Rake::Task["repo:delete"].reenable
        Rake::Task["repo:delete"].invoke
      end
    end

    desc "Refresh default ScholarSphere Hydra fixtures"
    task refresh: [:delete, :load]

    private

    def run_erb_stub(inputFile, outputFile)
      File.open(outputFile, "w+") do |f|
        f.write(ERB.new(get_erb_template inputFile).result())
      end
    end

    def find_fixtures_scholar(dir)
      Dir.glob(File.join(Rails.root, @localPart, dir, '*.foxml.xml')).map do |fixture_file|
        File.basename(fixture_file, '.foxml.xml').gsub('_',':')
      end
    end

    def find_fixtures_erb(dir)
      Dir.glob(File.join(Rails.root, @localPart, dir, '*.foxml.erb'))
    end

    def get_erb_template(file)
      File.read(file)
    end
  end
end
