# frozen_string_literal: true

require 'rails_helper'

describe NameDisambiguationService, unless: travis? do
  subject { described_class.new(name).disambiguate }

  context 'when we have a normal name' do
    let(:name) { 'Thompson, Britta M' }

    it 'finds the user' do
      expect(subject).to eq([{ id: 'bmt13', given_name: 'Britta', surname: 'Thompson', email: 'bmt13@psu.edu', affiliation: ['FACULTY'], displayname: 'Britta May Thompson' }])
    end
  end

  context 'when we have an id' do
    let(:name) { 'dmc186' }

    it 'finds the ids' do
      expect(subject).to eq([{ id: 'dmc186', given_name: 'DANIEL M', surname: 'COUGHLIN', email: 'dmc186@psu.edu', affiliation: ['STAFF'], displayname: 'Daniel M Coughlin' }])
    end
  end

  context 'when we have multiple combined with an and' do
    let(:name) { 'Daniel M Coughlin and Adam Wead' }

    it 'finds both users' do
      expect(subject).to eq([{ id: 'dmc186', given_name: 'DANIEL M', surname: 'COUGHLIN', email: 'dmc186@psu.edu', affiliation: ['STAFF'], displayname: 'Daniel M Coughlin' },
                             { id: 'agw13', given_name: 'Adam', surname: 'Wead', email: 'agw13@psu.edu', affiliation: ['STAFF'], displayname: 'Adam Wead' }])
    end
  end

  context 'when we have initials for first name' do
    let(:name) { 'K.B. Baker' }

    it 'finds the user' do
      expect(subject).to eq([{ id: 'kbb2', given_name: 'Kurt Bradley', surname: 'Baker', email: 'kbb2@psu.edu', affiliation: ['RETIREE'], displayname: 'Kurt Bradley Baker' }])
    end
  end

  context 'when we have multiple results' do
    let(:name) { 'Jane Doe' }

    it 'finds the user' do
      expect(subject).to eq([])
    end
  end

  context 'when the user has many titles' do
    let(:name) { 'Nicole Seger, MSN, RN, CPN' }

    it 'finds the user' do
      expect(subject).to eq([{ id: 'nas150', given_name: 'Nicole', surname: 'Seger', email: 'nas150@psu.edu', affiliation: ['STAFF'], displayname: 'Nicole A Seger' }])
    end
  end

  context 'when the user has a title first' do
    let(:name) { 'MSN Deb Cardenas' }

    it 'finds the user' do
      expect(subject).to eq([{ id: 'dac40', given_name: 'Deborah', surname: 'Cardenas', email: 'dac40@psu.edu', affiliation: ['STAFF'], displayname: 'Deborah A. Cardenas' }])
    end
  end

  context 'when the user has strange characters' do
    let(:name) { 'Adam Garner Wead *' }

    it 'cleans the name' do
      expect(subject).to eq([{ id: 'agw13', given_name: 'Adam', surname: 'Wead', email: 'agw13@psu.edu', affiliation: ['STAFF'], displayname: 'Adam Wead' }])
    end
  end

  context 'when the user has an apostrophy' do
    let(:name) { "Anthony R. D'Augelli" }

    it 'finds the user' do
      expect(subject).to eq([{ id: 'ard', given_name: 'Anthony', surname: "D'Augelli", email: 'ard@psu.edu', affiliation: ['EMERITUS'], displayname: "Anthony Raymond D'Augelli" }])
    end
  end

  context 'when the user has many names' do
    let(:name) { 'David Florn Johnson Arginteanu' }

    it 'finds the user' do
      expect(subject).to eq([{ id: 'dxa179', given_name: 'David', surname: 'Arginteanu', email: 'dxa179@psu.edu', affiliation: ['STAFF'], displayname: 'David Florn Johnson Arginteanu' }])
    end
  end

  context 'when the user has additional information' do
    let(:name) { 'Cole, Carolyn (Kubicki Group)' }

    it 'cleans the name' do
      expect(subject).to eq([{ id: 'cam156', given_name: 'Carolyn', surname: 'Cole', email: 'cam156@psu.edu', affiliation: ['MEMBER'], displayname: 'Carolyn Ann Cole' }])
    end
  end

  context 'when the user has an email in their name' do
    context 'when the email is not their id' do
      let(:name) { 'Barbara I. Dewey a bdewey@psu.edu' }

      it 'does not find the user' do
        expect(subject).to eq([{ id: 'bid1', given_name: 'Barbara', surname: 'Dewey', email: 'bid1@psu.edu', affiliation: ['STAFF'], displayname: 'Barbara Irene Dewey' }])
      end
    end

    context 'when the email is their id' do
      let(:name) { 'sjs230@psu.edu' }

      it 'finds the user' do
        expect(subject.count).to eq(1)
      end
    end

    context 'when the email is their id' do
      let(:name) { 'sjs230@psu.edu, cam156@psu.edu' }

      it 'finds the user' do
        expect(subject.count).to eq(2)
      end
    end
  end
end
