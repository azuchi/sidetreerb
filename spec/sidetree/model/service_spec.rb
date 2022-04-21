require 'spec_helper'

RSpec.describe Sidetree::Model::Service do
  describe '#from_hash' do
    let(:hash) { fixture_file('inputs/service1.json') }
    subject { Sidetree::Model::Service.from_hash(hash) }
    it 'parse hash object' do
      expect(subject.id).to eq('service1Id')
      expect(subject.type).to eq('service1Type')
      expect(subject.endpoint).to eq('http://www.service1.com')
    end

    context 'ID is not using Base64URL characters' do
      let(:hash) do
        {
          id: 'notAllBase64UrlChars!',
          type: 'anyType',
          serviceEndpoint: 'http://any.endpoint'
        }.stringify_keys
      end
      it 'raise error' do
        expect { subject }.to raise_error(
          Sidetree::Error,
          'id does not use base64url character set.'
        )
      end
    end

    context 'service endpoint type exceeds maximum length' do
      let(:hash) do
        {
          id: 'anyId',
          type: 'superDuperLongServiceTypeValueThatExceedsMaximumAllowedLength',
          serviceEndpoint: 'http://any.endpoint'
        }.stringify_keys
      end
      it 'raise error' do
        expect { subject }.to raise_error(
          Sidetree::Error,
          'Service endpoint type length 61 exceeds max allowed length of 30.'
        )
      end
    end

    context 'service endpoint value is an array' do
      let(:hash) do
        { id: 'anyId', type: 'anyType', serviceEndpoint: [] }.stringify_keys
      end
      it 'raise error' do
        expect { subject }.to raise_error(
          Sidetree::Error,
          'Service endpoint value cannot be an array.'
        )
      end
    end

    context 'object as service endpoint value' do
      let(:hash) do
        {
          id: 'anyId',
          type: 'anyType',
          serviceEndpoint: {
            value: 'someValue'
          }
        }.stringify_keys
      end
      it 'can accept' do
        expect(subject.endpoint).to eq({ value: 'someValue' })
      end
    end

    context 'service endpoint string is not a URL' do
      let(:hash) do
        {
          id: 'anyId',
          type: 'anyType',
          serviceEndpoint: 'htp://'
        }.stringify_keys
      end
      it 'raise error' do
        expect { subject }.to raise_error(
          Sidetree::Error,
          "URI string 'htp://' is not a valid URI."
        )
      end
    end
  end
end
