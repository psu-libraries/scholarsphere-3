# frozen_string_literal: true

require 'rails_helper'

describe CleanAgents::Processor do
  let(:agent1_id) { '123-456-789' }
  let(:agent2_id) { '999-456-789' }
  let(:agent3_id) { '555-456-789' }

  context 'agent needs to be split' do
    let(:agent) { create :agent, sur_name: 'Sally Brown, Matilda Smith' }
    let(:agent_alias) { create :alias, display_name: 'Sally Brown, Matilda Smith', agent: agent }
    let(:names) { [{ sur_name: 'Brown', given_name: 'Sally', email: 'sab123@example.com' }, { sur_name: 'Smith', given_name: 'Matilda' }] }
    let!(:work) { create :work, creators: [agent_alias] }

    describe '#split_agent' do
      it 'creates a second agent' do
        agents = []
        expect { agents = described_class.split_agent(agent: agent, names: names) }.to change(Agent, :count).by(1).and change(Alias, :count).by(1)
        expect(agents.first.sur_name).to eq('Brown')
        expect(agents.first.given_name).to eq('Sally')
        expect(agents.first.email).to eq('sab123@example.com')
        expect(agents.first.aliases.first.display_name).to eq('Sally Brown')
        expect(agents.last.sur_name).to eq('Smith')
        expect(agents.last.given_name).to eq('Matilda')
        expect(agents.last.aliases.first.display_name).to eq('Matilda Smith')
        expect(work.reload.creators).to contain_exactly(*agents.map(&:aliases).flatten)
      end
    end
  end

  context 'agents that need to be combined' do
    let(:agent1) { create :agent, sur_name: 'Sally B Brown' }
    let(:agent_alias1) { create :alias, display_name: 'Sally B Brown', agent: agent1 }
    let!(:work1) { create :work, creators: [agent_alias1] }
    let(:agent2) { create :agent, sur_name: 'Brown', given_name: 'Sally B' }
    let(:agent_alias2) { create :alias, display_name: 'Sally Brown', agent: agent2 }
    let!(:work2) { create :work, creators: [agent_alias2] }

    it 'combines the agents' do
      expect { described_class.combine_agents(agent: agent1, other_agents: [agent2]) }.to change(Agent, :count).by(-1).and change(Alias, :count).by(0)
      expect { Agent.find(agent2.id) }.to raise_error(Ldp::Gone)
      expect(agent1.reload.aliases).to contain_exactly(agent_alias1, agent_alias2)
      expect(work1.reload.creators).to contain_exactly(agent_alias1)
      expect(work2.reload.creators).to contain_exactly(agent_alias2)
    end
  end

  context 'valid csv data' do
    let(:csv) do
      "id,psu_id_ssim,sur_name_ssim,given_name_ssim,email_ssim,Id_of_equal_agent,id_split_from_agent,revised_sur_name,revised_given_name,revised_email\n"\
      "#{agent1_id},,Sally B Brown,,,#{agent1_id},,Brown,Sally B,\n"\
      "#{agent2_id},,Brown,Sally B,,#{agent1_id},,Brown,Sally B,\n"\
      "#{agent3_id},,Sally Grape, Matilda Smith,,,#{agent3_id},Grape,Sally,sag123@example.com\n"\
      ",,,,,,#{agent3_id},Smith,Matilda,\n"
    end

    let(:parse_split_groups) do
      [{
        id: agent3_id,
        names: [{ sur_name: 'Grape', given_name: 'Sally', email: 'sag123@example.com' },
                { sur_name: 'Smith', given_name: 'Matilda', email: nil }]
      }]
    end

    let(:parse_combine_groups) do
      { agent1_id => [agent2_id] }
    end

    describe 'parse_file' do
      let(:file) { Tempfile.new('test_csv', 'tmp') }

      before do
        file.write(csv)
        file.flush
      end

      after do
        file.unlink
      end

      it 'reads the file and processes the data' do
        parsed_info = described_class.parse_file(file.path)
        expect(parsed_info[:split_groups]).to eq parse_split_groups
        expect(parsed_info[:combine_groups]).to eq parse_combine_groups
        expect(parsed_info[:file_data]).to be_a(CSV::Table)
      end
    end

    describe 'parse_csv' do
      it 'parses the combinations and separations' do
        parsed_info = described_class.parse_csv(csv)
        expect(parsed_info[:split_groups]).to eq parse_split_groups
        expect(parsed_info[:combine_groups]).to eq parse_combine_groups
      end
    end
  end

  context 'bad csv split' do
    let(:csv) do
      "id,psu_id_ssim,sur_name_ssim,given_name_ssim,email_ssim,Id_of_equal_agent,id_split_from_agent,revised_sur_name,revised_given_name,revised_email\n"\
    "#{agent1_id},,Sally B Brown,,,#{agent1_id},,Brown,Sally B,\n"\
    "#{agent2_id},,Brown,Sally B,,#{agent1_id},,Brown,Sally B,\n"\
    "#{agent3_id},,Sally Grape, Matilda Smith,,,#{agent3_id},Grape,Sally,\n"\
    ",,,,,,#{agent1_id},Smith,Matilda\n"
    end

    it 'raises and exception' do
      expect { described_class.parse_csv(csv) }.to raise_error(StandardError)
    end
  end

  context 'bad csv combine' do
    let(:csv) do
      "id,psu_id_ssim,sur_name_ssim,given_name_ssim,email_ssim,Id_of_equal_agent,id_split_from_agent,revised_sur_name,revised_given_name,revised_email\n"\
    "#{agent1_id},,Sally B Brown,,,#{agent2_id},,Brown,Sally B,\n"\
    "#{agent2_id},,Brown,Sally B,,#{agent1_id},,Brown,Sally B,\n"\
    "#{agent3_id},,Sally Grape, Matilda Smith,,,#{agent3_id},Grape,Sally,\n"\
    ",,,,,,#{agent1_id},Smith,Matilda,\n"
    end

    it 'raises and exception' do
      expect { described_class.parse_csv(csv) }.to raise_error(StandardError)
    end
  end

  describe 'process_data' do
    let(:agent1) { create :agent, sur_name: 'Brown', given_name: 'Sally B' }
    let(:agent_alias1) { create :alias, display_name: 'Sally B Brown', agent: agent1 }
    let(:work1) { create :work, creators: [agent_alias1] }
    let(:agent2) { create :agent, sur_name: 'Sally B Brown' }
    let(:agent_alias2) { create :alias, display_name: 'Sally Brown', agent: agent2 }
    let(:work2) { create :work, creators: [agent_alias2] }
    let(:agent3) { create :agent, sur_name: 'Sally Grape, Matilda Smith' }
    let(:agent_alias3) { create :alias, display_name: 'Sally Grape, Matilda Smith', agent: agent3 }
    let(:names) { [{ sur_name: 'Brown', given_name: 'Sally' }, { sur_name: 'Smith', given_name: 'Matilda' }] }
    let(:work3) { create :work, creators: [agent_alias3] }

    let(:parse_split_groups) do
      [{
        id: agent3.id,
        names: [{ sur_name: 'Grape', given_name: 'Sally' },
                { sur_name: 'Smith', given_name: 'Matilda' }]
      }]
    end

    let(:parse_combine_groups) do
      { agent1.id => [agent2.id] }
    end

    let(:csv_table) do
      headers = ['id', 'psu_id_ssim', 'sur_name_ssim', 'given_name_ssim', 'email_ssim', 'Id_of_equal_agent',
                 'id_split_from_agent', 'revised_sur_name', 'revised_given_name', 'revised_email']
      CSV::Table.new([CSV::Row.new(headers, [agent1.id, 'sbb', 'Brown', 'Sally B',
                                             'sbb@example.com', agent1.id, nil, 'Brown', 'Sandra B'])])
    end

    let(:parsed_info) { { split_groups: parse_split_groups, combine_groups: parse_combine_groups, file_data: csv_table } }

    before do
      Agent.destroy_all
      work1
      work2
      work3
    end

    it 'parses the combinations and separations' do
      expect { described_class.process_data(parsed_info) }.to change(Agent, :count).by(0).and change(Alias, :count).by(1)
      expect { Agent.find(agent2.id) }.to raise_error(Ldp::Gone)
      expect(agent1.reload.aliases).to contain_exactly(agent_alias1, agent_alias2)
      expect(Agent.all.map(&:display_name)).to contain_exactly('Sandra B Brown', 'Sally Grape', 'Matilda Smith')
    end
  end
end
