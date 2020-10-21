# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Rights
      def self.call(rights)
        result = nil
        [
          [
            ['http://creativecommons.org/licenses/by-nc-sa/3.0/us/', 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'],
            'http://creativecommons.org/licenses/by-nc-sa/3.0/us/'
          ],
          [
            ['http://creativecommons.org/licenses/by-nc-sa/3.0/us/', 'http://creativecommons.org/licenses/by/3.0/us/'],
            'http://creativecommons.org/licenses/by/3.0/us/'
          ],
          [
            ['http://creativecommons.org/licenses/by-nc/3.0/us/', 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'],
            'http://creativecommons.org/licenses/by-nc/3.0/us/'
          ],
          [
            ['http://creativecommons.org/licenses/by-nc/3.0/us/', 'http://creativecommons.org/licenses/by-sa/3.0/us/', 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'],
            'https://creativecommons.org/licenses/by-nc/3.0/us/'
          ],
          [
            ['http://creativecommons.org/licenses/by-nd/3.0/us/', 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'],
            'http://creativecommons.org/licenses/by-nd/3.0/us/'
          ],
          [
            ['http://creativecommons.org/licenses/by-sa/3.0/us/', 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'],
            'http://creativecommons.org/licenses/by-sa/3.0/us/'
          ],
          [
            ['http://creativecommons.org/licenses/by/3.0/us/', 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'],
            'http://creativecommons.org/licenses/by/3.0/us/'
          ],
          [
            ['http://creativecommons.org/publicdomain/mark/1.0/', 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'],
            'http://creativecommons.org/publicdomain/mark/1.0/'
          ],
          [
            ['http://creativecommons.org/publicdomain/zero/1.0/', 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'],
            'http://creativecommons.org/publicdomain/zero/1.0/'
          ],
          [
            ['http://www.europeana.eu/portal/rights/rr-r.html', 'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'],
            'http://creativecommons.org/licenses/by-nc-nd/3.0/us/'
          ],
          [
            ['https://creativecommons.org/licenses/by/4.0/', 'http://www.europeana.eu/portal/rights/rr-r.html'],
            'https://creativecommons.org/licenses/by/4.0/'
          ]
        ].each do |tuple|
          if tuple.first.sort == rights.sort
            result = tuple.second
          end
        end

        return rights.first if result.nil?

        result
      end
    end
  end
end
