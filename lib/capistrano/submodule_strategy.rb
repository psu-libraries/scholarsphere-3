# frozen_string_literal: true

if Object.const_defined?('Capistrano::SCM')

  class Capistrano::Git < Capistrano::SCM
    module SubmoduleStrategy
      include DefaultStrategy

      def test
        test! " [ -d #{repo_path}/.git ] "
      end

      def clone
        git :clone, '-b', fetch(:branch), '--recursive', repo_url, repo_path
      end

      def release
        context.execute :rm, '-rf', release_path
        git :clone, '--branch', fetch(:branch),
            '--recursive',
            '--no-hardlinks',
            repo_path, release_path
      end
    end
  end
end
