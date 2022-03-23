require 'spec_helper'

RSpec.describe Sidetree::Key do
  describe '#to_jwk' do
    subject { Sidetree::Key.new(private_key: 0xf0fe16c5b9267dad0ae986df93d18c0f88f250c47aaff312a3fc8ea1abd19414).to_jwk }
    it 'generate JWK object' do
      expect(subject).to be_a(JSON::JWK)
      expect(subject['x']).to eq('mZT44XgevHQ-7_thiCit2TGuTg_kbxVtcznWf88NvPQ')
      expect(subject['y']).to eq('OwDl7AGBcJyMufDs3lwdiF3zvVifoPn6DgwVEhg_E0M')
      expect(subject['kty']).to eq(:EC)
      expect(subject['crv']).to eq(:secp256k1)
    end
  end
end