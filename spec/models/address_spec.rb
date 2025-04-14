# spec/models/address_spec.rb

require 'rails_helper'

RSpec.describe Address do
  subject(:address) do
    described_class.new(
      street: street,
      city: city,
      state: state,
      zipcode: zipcode
    )
  end

  let(:street) { '123 Main' }
  let(:city) { 'San Jose' }
  let(:state) { 'CA' }
  let(:zipcode) { '95112' }

  describe '#valid?' do
    context 'with all valid fields' do
      it 'is valid' do
        expect(address).to be_valid
      end
    end

    context 'with blank street' do
      let(:street) { '' }
      it 'is invalid' do
        expect(address).not_to be_valid
        expect(address.errors[:street]).to include("can't be blank")
      end
    end

    context 'with blank city' do
      let(:city) { '' }
      it 'is invalid' do
        expect(address).not_to be_valid
        expect(address.errors[:city]).to include("can't be blank")
      end
    end

    context 'with blank state' do
      let(:state) { '' }
      it 'is invalid' do
        expect(address).not_to be_valid
        expect(address.errors[:state]).to include("can't be blank")
      end
    end

    context 'with blank zipcode' do
      let(:zipcode) { '' }
      it 'is invalid' do
        expect(address).not_to be_valid
        expect(address.errors[:zipcode]).to include("can't be blank")
      end
    end

    context 'with invalid zipcode format' do
      let(:zipcode) { '95x12' }
      it 'is invalid' do
        expect(address).not_to be_valid
        expect(address.errors[:zipcode]).to include("is invalid")
      end
    end

    context 'with valid 9-digit ZIP+4 format' do
      let(:zipcode) { '95112-1234' }
      it 'is valid' do
        expect(address).to be_valid
      end
    end
  end

  describe '#full_address' do
    it 'returns the correctly formatted full address' do
      expect(address.full_address).to eq('123 Main, San Jose, CA 95112')
    end
  end
end