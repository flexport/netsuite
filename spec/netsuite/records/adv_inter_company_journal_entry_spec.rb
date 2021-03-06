require 'spec_helper'

describe NetSuite::Records::AdvInterCompanyJournalEntry do
  let(:entry) { NetSuite::Records::AdvInterCompanyJournalEntry.new }

  it 'has all the right fields' do
    [
      :approved, :created_date, :is_book_specific, :last_modified_date,
      :memo, :perform_auto_balance, :reversal_date, :reversal_defer,
      :reversal_entry, :tran_date, :tran_id
    ].each do |field|
      expect(entry).to have_field(field)
    end
  end

  it 'has all the right record refs' do
    [
      :created_from, :currency, :custom_form, :department, :klass, :location,
      :parent_expense_alloc, :posting_period, :subsidiary,
    ].each do |record_ref|
      expect(entry).to have_record_ref(record_ref)
    end
  end

  describe '#custom_field_list' do
    it 'can be set from attributes' do
      attributes = {
        :custom_field => {
          :amount => 10,
          :script_id => 'custfield_amount'
        }
      }
      entry.custom_field_list = attributes
      expect(entry.custom_field_list).to be_kind_of(NetSuite::Records::CustomFieldList)
      expect(entry.custom_field_list.custom_fields.length).to eql(1)
      expect(entry.custom_field_list.custfield_amount.attributes[:amount]).to eq(10)
    end

    it 'can be set from a CustomFieldList object' do
      custom_field_list = NetSuite::Records::CustomFieldList.new
      entry.custom_field_list = custom_field_list
      expect(entry.custom_field_list).to eql(custom_field_list)
    end
  end

  describe '#line_list' do
    it 'can be set from attributes' do
      attributes = {
        :line => {
        }
      }
      entry.line_list = attributes
      expect(entry.line_list).to be_kind_of(NetSuite::Records::AdvInterCompanyJournalEntryLineList)
      expect(entry.line_list.lines.length).to eql(1)
    end

    it 'can be set from an AdvInterCompanyJournalEntryLineList object' do
      line_list = NetSuite::Records::AdvInterCompanyJournalEntryLineList.new
      entry.line_list = line_list
      expect(entry.line_list).to eql(line_list)
    end
  end

  describe '.get' do
    context 'when the response is successful' do
      let(:response) { NetSuite::Response.new(:success => true, :body => { :approved => true }) }

      it 'returns an AdvInterCompanyJournalEntry instance populated with the data from the response object' do
        expect(NetSuite::Actions::Get).to receive(:call).with([NetSuite::Records::AdvInterCompanyJournalEntry, {:external_id => 1}], {}).and_return(response)
        record = NetSuite::Records::AdvInterCompanyJournalEntry.get(:external_id => 1)
        expect(record).to be_kind_of(NetSuite::Records::AdvInterCompanyJournalEntry)
        expect(record.approved).to be_truthy
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it 'raises a RecordNotFound exception' do
        expect(NetSuite::Actions::Get).to receive(:call).with([NetSuite::Records::AdvInterCompanyJournalEntry, {:external_id => 1}], {}).and_return(response)
        expect do
          NetSuite::Records::AdvInterCompanyJournalEntry.get(:external_id => 1)
        end.to raise_error(
          NetSuite::RecordNotFound,
          /NetSuite::Records::AdvInterCompanyJournalEntry with OPTIONS=(.*) could not be found/
        )
      end
    end
  end

  describe '#add' do
    let(:entry) { NetSuite::Records::JournalEntry.new(:approved => true) }

    before(:each) do
      expect(NetSuite::Actions::Add).to receive(:call)
        .with([entry], {})
        .and_return(response)
    end

    context 'when the response is successful' do
      let(:response) { NetSuite::Response.new(:success => true, :body => { :internal_id => '1' }) }

      it 'returns true' do
        expect(entry.add).to be_truthy
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it 'returns false' do
        expect(entry.add).to be_falsey
      end
    end
  end

  describe '#delete' do
    before(:each) do
      expect(NetSuite::Actions::Delete)
        .to receive(:call)
        .with([entry], {})
        .and_return(response)
    end

    context 'when the response is successful' do
      let(:response) { NetSuite::Response.new(:success => true, :body => {:internal_id => '1'}) }

      it 'returns true' do
        expect(entry.delete).to be_truthy
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it 'returns false' do
        expect(entry.delete).to be_falsey
      end
    end
  end

  describe '#to_record' do
    let(:entry) { NetSuite::Records::AdvInterCompanyJournalEntry.new(:tran_id => '1234', :approved => true) }

    it 'returns a hash of attributes that can be used in a SOAP request' do
      expect(entry.to_record).to eql({
        'tranGeneral:tranId'   => '1234',
        'tranGeneral:approved' => true
      })
    end
  end

  describe '#record_type' do
    it 'returns a string type for the record to be used in a SOAP request' do
      expect(entry.record_type).to eql('tranGeneral:AdvInterCompanyJournalEntry')
    end
  end
end
