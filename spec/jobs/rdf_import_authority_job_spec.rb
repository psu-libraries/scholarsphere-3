# frozen_string_literal: true

require 'rails_helper'

describe RDFAuthorityImportJob do
  let(:file) { double }

  context 'with no authority' do
    it 'raises and error' do
      expect { described_class.perform_now(file) }.to raise_error(NotImplementedError, 'No authority defined')
    end
  end

  context 'with an authority' do
    before { allow(described_class).to receive(:authority).and_return('the law') }

    it 'imports the authority from a file using Questioning Authority' do
      expect(Qa::LocalAuthority).to receive(:find_or_create_by).with(name: 'the law')
      expect(Qa::Services::RDFAuthorityParser).to receive(:import_rdf).with('the law', [file], {})
      described_class.perform_now(file)
    end
  end
end
