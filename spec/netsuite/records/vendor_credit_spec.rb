require 'spec_helper'

describe NetSuite::Records::VendorCredit do
  let(:test_data) { {} }
  let(:vendor) { NetSuite::Records::Vendor.new }
  let(:credit) { NetSuite::Records::VendorCredit.new(test_data) }
  let(:response) { NetSuite::Response.new(:success => :true, :body => {:internal_id => '1'}) }

  it 'has all the right fields' do
    [
      :applied, :auto_apply, :created_date, :currency_name, :exchange_rate, :external_id,
      :last_modified_date, :memo, :total, :tran_date, :tran_id, :transaction_number, :un_applied,
      :user_total
    ].each do |field|
      expect(credit).to have_field(field)
    end
  end

  it 'has all the right record refs' do
    [
      :account, :bill_address_list, :klass, :created_from, :currency, :custom_form, :department, :entity,
      :location, :posting_period, :subsidiary
    ].each do |record_ref|
      expect(credit).to have_record_ref(record_ref)
    end
  end

  describe '#add' do
    subject { credit.add }

    let(:test_data) { {:tran_id => 42} }

    before(:each) do
      expect(NetSuite::Actions::Add).to receive(:call)
        .with([credit], {})
        .and_return(response)
    end

    context 'when the response is successful' do
      it { is_expected.to be_truthy }
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#delete' do
    subject { credit.delete }

    let(:test_data) { {:internal_id => '1'} }

    before(:each) do
      expect(NetSuite::Actions::Delete).to receive(:call)
        .with([credit], {})
        .and_return(response)
    end

    context 'when the response is successful' do
      it { is_expected.to be_truthy }
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it { is_expected.to be_falsey }
    end
  end

  describe '.get' do
    context 'when the response is successful' do
      let(:response) { NetSuite::Response.new(:success => true, :body => { :@internal_id => '1', :@external_id =>'some_id' }) }

      it 'returns a VendorCredit instance populated with the data from the response object' do
        expect(NetSuite::Actions::Get).to receive(:call).with([NetSuite::Records::VendorCredit, external_id: 'some_id'], {}).and_return(response)
        vendor_credit = NetSuite::Records::VendorCredit.get(external_id: 'some_id')
        expect(vendor_credit).to be_kind_of(NetSuite::Records::VendorCredit)
        expect(vendor_credit.internal_id).to eq('1')
        expect(vendor_credit.external_id).to eq('some_id')
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it 'raises a RecordNotFound exception' do
        expect(NetSuite::Actions::Get).to receive(:call).with([NetSuite::Records::VendorCredit, external_id: 'some_id'], {}).and_return(response)
        expect {
          NetSuite::Records::VendorCredit.get(external_id: 'some_id')
        }.to raise_error(NetSuite::RecordNotFound,
          /NetSuite::Records::VendorCredit with OPTIONS=(.*) could not be found/)
      end
    end
  end

  describe '#item_list' do
    it 'can be set from attributes' do
      attributes = {
        :item => {
          :amount => 10
        }
      }
      credit.item_list = attributes
      expect(credit.item_list).to be_kind_of(NetSuite::Records::VendorCreditItemList)
      expect(credit.item_list.items.length).to eql(1)
    end

    it 'can be set from a VendorCreditItemList object' do
      item_list = NetSuite::Records::VendorCreditItemList.new
      credit.item_list = item_list
      expect(credit.item_list).to eql(item_list)
    end
  end

  describe '#apply_list' do
    it 'can be set from attributes' do
      attributes = {
        :apply => {
          :amount => 10
        }
      }
      credit.apply_list = attributes
      expect(credit.apply_list).to be_kind_of(NetSuite::Records::VendorCreditApplyList)
      expect(credit.apply_list.applies.length).to eql(1)
    end

    it 'can be set from a VendorCreditApplyList object' do
      apply_list = NetSuite::Records::VendorCreditApplyList.new
      credit.apply_list = apply_list
      expect(credit.apply_list).to eql(apply_list)
    end
  end

  describe '#expense_list' do
    it 'can be set from attributes' do
      attributes = {
        :expense => {
          :amount => 10
        }
      }
      credit.expense_list = attributes
      expect(credit.expense_list).to be_kind_of(NetSuite::Records::VendorCreditExpenseList)
      expect(credit.expense_list.expenses.length).to eql(1)
    end

    it 'can be set from a VendorCreditExpenseList object' do
      expense_list = NetSuite::Records::VendorCreditExpenseList.new
      credit.expense_list = expense_list
      expect(credit.expense_list).to eql(expense_list)
    end
  end


  describe '#custom_field_list' do
    it 'can be set from attributes' do
      attributes = {
        custom_field: {
          internal_id: 'some id'
        }
      }
      credit.custom_field_list = attributes
      expect(credit.custom_field_list).to be_kind_of(NetSuite::Records::CustomFieldList)
      expect(credit.custom_field_list.custom_fields.length).to eql(1)
    end

    it 'can be set from a CustomFieldList object' do
      custom_field_list = NetSuite::Records::CustomFieldList.new
      credit.custom_field_list = custom_field_list
      expect(credit.custom_field_list).to eql(custom_field_list)
    end
  end

  describe '#to_record' do
    subject { credit.to_record }

    let(:test_data) { {:tran_id => 42} }

    it { is_expected.to include('tranPurch:tranId' => 42) }
  end

  describe '#record_type' do
    subject { credit.record_type }

    let(:test_data) { {:tran_id => 42} }

    it { is_expected.to eql('tranPurch:VendorCredit') }
  end

  describe '.initialize' do
    subject { NetSuite::Records::VendorCredit.initialize(vendor) }

    before(:each) do
      expect(NetSuite::Actions::Initialize).to receive(:call)
        .with([NetSuite::Records::VendorCredit, vendor], {})
        .and_return(response)
    end

    context 'when the request is successful' do
      it { is_expected.to be_kind_of(NetSuite::Records::VendorCredit) }
    end

    context 'when the request is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it 'raises an InitializationError exception' do
        expect{ subject }
          .to raise_error(
            NetSuite::InitializationError,
            /NetSuite::Records::VendorCredit.initialize with (.*) failed./)
      end
    end
  end
end
