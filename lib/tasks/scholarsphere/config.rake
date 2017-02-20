namespace :scholarsphere do
  namespace :config do

    desc "Check configuration files for completeness"
    task check: :environment do
      Scholarsphere::Config.check
    end

  end
end
