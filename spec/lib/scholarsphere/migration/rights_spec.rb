# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::Rights do
  subject { described_class.call(rights) }

  context 'with one value for rights' do
    let(:rights) { ['value'] }

    it { is_expected.to eq('value') }
  end

  context 'with different combinations of mutliple rights' do
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

      it { expect(described_class.call(tuple.first)).to eq(tuple.second) }
    end
  end
end
