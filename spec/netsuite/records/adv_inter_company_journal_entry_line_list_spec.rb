require 'spec_helper'

describe NetSuite::Records::AdvInterCompanyJournalEntryLineList do
  let(:list) { NetSuite::Records::AdvInterCompanyJournalEntryLineList.new }

  it 'has a custom_fields attribute' do
    expect(list.lines).to be_kind_of(Array)
  end

  describe '#to_record' do
    before do
      list.lines << NetSuite::Records::AdvInterCompanyJournalEntryLine.new(:memo => 'This is a memo')
    end

    it 'can represent itself as a SOAP record' do
      expect(list.to_record).to eql({
        'tranGeneral:line' => [{
          'tranGeneral:memo' => 'This is a memo'
        }]
      })
    end
  end
end
