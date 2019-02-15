# frozen_string_literal: true

require 'rails_helper'

describe NameDisambiguationService, unless: travis? do
  subject { described_class.new(name).disambiguate }

  context 'when we have a normal name' do
    let(:name) { 'Thompson, Britta M' }

    it 'finds the user' do
      expect(subject).to eq([{ id: 'bmt13', given_name: 'Britta May', surname: 'Thompson', email: 'bmt13@psu.edu', affiliation: ['FACULTY'], displayname: 'Britta May Thompson' }])
    end
  end

  context 'when we have an id' do
    let(:name) { 'cam156' }

    it 'finds the ids' do
      expect(subject).to eq([{ id: 'cam156', given_name: 'Carolyn Ann', surname: 'Cole', email: 'cam156@psu.edu', affiliation: ['STAFF'], displayname: 'Carolyn Ann Cole' }])
    end
  end

  context 'when we have multiple combined with an and' do
    let(:name) { 'Carolyn Cole and Adam Wead' }

    it 'finds both users' do
      expect(subject).to eq([{ id: 'cam156', given_name: 'Carolyn Ann', surname: 'Cole', email: 'cam156@psu.edu', affiliation: ['STAFF'], displayname: 'Carolyn Ann Cole' },
                             { id: 'agw13', given_name: 'Adam Garner', surname: 'Wead', email: 'agw13@psu.edu', affiliation: ['STAFF'], displayname: 'Adam Garner Wead' }])
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
      expect(subject).to eq([{ id: 'nas150', given_name: 'NICOLE A', surname: 'SEGER', email: 'nas150@psu.edu', affiliation: ['STAFF'], displayname: 'NICOLE A SEGER' }])
    end
  end

  context 'when the user has a title first' do
    let(:name) { 'MSN Deb Cardenas' }

    it 'finds the user' do
      expect(subject).to eq([{ id: 'dac40', given_name: 'DEBORAH A.', surname: 'CARDENAS', email: 'dac40@psu.edu', affiliation: ['STAFF'], displayname: 'DEBORAH A. CARDENAS' }])
    end
  end

  context 'when the user has strange characters' do
    let(:name) { 'Adam Garner Wead *' }

    it 'cleans the name' do
      expect(subject).to eq([{ id: 'agw13', given_name: 'Adam Garner', surname: 'Wead', email: 'agw13@psu.edu', affiliation: ['STAFF'], displayname: 'Adam Garner Wead' }])
    end
  end

  context 'when the user has an apostrophy' do
    let(:name) { "Anthony R. D'Augelli" }

    it 'finds the user' do
      expect(subject).to eq([{ id: 'ard', given_name: 'Anthony Raymond', surname: "D'Augelli", email: 'ard@psu.edu', affiliation: ['EMERITUS'], displayname: "Anthony Raymond D'Augelli" }])
    end
  end

  context 'when the user has many names' do
    let(:name) { 'ALIDA HEATHER DOHN ROSS' }

    it 'finds the user' do
      expect(subject).to eq([{ id: 'hdr10', given_name: 'Alida Heather', surname: 'Dohn Ross', email: 'hdr10@psu.edu', affiliation: ['STAFF'], displayname: 'Alida Heather Dohn Ross' }])
    end
  end

  context 'when the user has additional information' do
    let(:name) { 'Cole, Carolyn (Kubicki Group)' }

    it 'cleans the name' do
      expect(subject).to eq([{ id: 'cam156', given_name: 'Carolyn Ann', surname: 'Cole', email: 'cam156@psu.edu', affiliation: ['STAFF'], displayname: 'Carolyn Ann Cole' }])
    end
  end

  context 'when the user has an email in thier name' do
    context 'when the email is not their id' do
      let(:name) { 'Barbara I. Dewey a bdewey@psu.edu' }

      it 'does not find the user' do
        expect(subject).to eq([{ id: 'bid1', given_name: 'Barbara Irene', surname: 'Dewey', email: 'bid1@psu.edu', affiliation: ['STAFF'], displayname: 'Barbara Irene Dewey' }])
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
