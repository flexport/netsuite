require 'spec_helper'

describe NetSuite::Records::Department do
  let(:test_data) { {} }
  let(:department) { NetSuite::Records::Department.new(test_data) }
  let(:response) { NetSuite::Response.new(:success => true, :body => {:name => 'Department 1'}) }

  it 'has all the right fields' do
    [
      :name, :is_inactive
    ].each do |field|
      expect(department).to have_field(field)
    end
  end

  it 'has all the right record refs' do
    [
      :parent
    ].each do |record_ref|
      expect(department).to have_record_ref(record_ref)
    end
  end

  describe '.get' do
    subject { NetSuite::Records::Department.get(:external_id => 1) }

    let(:test_data) { { :external_id => 1 } }

    before(:each) do
      expect(NetSuite::Actions::Get).to receive(:call)
        .with([NetSuite::Records::Department, {:external_id => 1}], {})
        .and_return(response)
    end

    context 'when the response is successful' do
      it 'returns a Department instance populated with the data from the response object' do
        expect(subject)
          .to be_kind_of(NetSuite::Records::Department)
          .and have_attributes('name' => 'Department 1')
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it 'raises a RecordNotFound exception' do
        expect{ subject }
          .to raise_error(
            NetSuite::RecordNotFound,
            /NetSuite::Records::Department with OPTIONS=(.*) could not be found/)
      end
    end
  end

  describe '#add' do
    subject { department.add }

    let(:test_data) { { :name => 'Test Department' } }

    before(:each) do
      expect(NetSuite::Actions::Add).to receive(:call)
        .with([department], {})
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
    subject { department.delete }

    let(:test_data) { { :internal_id => '1' } }

    before(:each) do
      expect(NetSuite::Actions::Delete).to receive(:call)
        .with([department], {})
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

  describe '#to_record' do
    subject { department.to_record }

    let(:test_data) { { :name => 'Test Department' } }

    it { is_expected.to include('listAcct:name' => 'Test Department') }
  end

  describe '#record_type' do
    subject { department.record_type }

    it { is_expected.to eql('listAcct:Department') }
  end

end
