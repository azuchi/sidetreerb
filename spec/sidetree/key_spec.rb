require "spec_helper"

RSpec.describe Sidetree::Key do
  describe "#to_jwk" do
    subject do
      Sidetree::Key.new(
        private_key:
          0xf0fe16c5b9267dad0ae986df93d18c0f88f250c47aaff312a3fc8ea1abd19414
      ).to_jwk
    end
    it "generate JWK object" do
      expect(subject).to be_a(JSON::JWK)
      expect(subject["x"]).to eq("mZT44XgevHQ-7_thiCit2TGuTg_kbxVtcznWf88NvPQ")
      expect(subject["y"]).to eq("OwDl7AGBcJyMufDs3lwdiF3zvVifoPn6DgwVEhg_E0M")
      expect(subject["kty"]).to eq("EC")
      expect(subject["crv"]).to eq("secp256k1")
    end
  end

  describe "#from_json" do
    subject { Sidetree::Key.from_hash(data) }
    context "has only public key" do
      let(:data) { fixture_file("inputs/jwkEs256k1Public.json") }
      it "generate Key instance" do
        expect(subject.private_key).to be nil
        jwk = subject.to_jwk
        expect(jwk["x"]).to eq(data["x"])
        expect(jwk["y"]).to eq(data["y"])
      end
    end
    context "has private key" do
      let(:data) { fixture_file("inputs/jwkEs256k1Private.json") }
      it "generate Key instance" do
        expect(subject.private_key).to eq(
          Base64.urlsafe_decode64(data["d"]).unpack1("H*").to_i(16)
        )
        jwk = subject.to_jwk
        expect(jwk["x"]).to eq(data["x"])
        expect(jwk["y"]).to eq(data["y"])
      end
    end

    context "pubkey model json" do
      let(:data) { fixture_file("inputs/publicKeyModel1.json") }
      it "has purpose and id, type" do
        jwk = subject.to_jwk
        expect(jwk["x"]).to eq(data["publicKeyJwk"]["x"])
        expect(jwk["y"]).to eq(data["publicKeyJwk"]["y"])
        expect(subject.id).to eq("publicKeyModel1Id")
        expect(subject.type).to eq("EcdsaSecp256k1VerificationKey2019")
        expect(subject.purposes).to eq(%w[authentication keyAgreement])
      end
    end

    context "Unsupported curve" do
      let(:data) do
        data = fixture_file("inputs/jwkEs256k1Public.json")
        data["crv"] = "wrongValue"
        data
      end
      it "raise error" do
        expect { subject }.to raise_error(
          Sidetree::Error,
          'Unsupported curve \'wrongValue\' specified.'
        )
      end
    end

    context "Unsupported key type" do
      let(:data) do
        data = fixture_file("inputs/jwkEs256k1Public.json")
        data["kty"] = "wrongValue"
        data
      end
      it "raise error" do
        expect { subject }.to raise_error(
          Sidetree::Error,
          'Unsupported key type \'wrongValue\' specified.'
        )
      end
    end

    context "Invalid x length" do
      let(:data) do
        data = fixture_file("inputs/jwkEs256k1Public.json")
        data["x"] = "wrongValueLength"
        data
      end
      it "raise error" do
        expect { subject }.to raise_error(
          Sidetree::Error,
          'Secp256k1 JWK \'x\' property must be 43 bytes.'
        )
      end
    end

    context "Invalid y length" do
      let(:data) do
        data = fixture_file("inputs/jwkEs256k1Public.json")
        data["y"] = "wrongValueLength"
        data
      end
      it "raise error" do
        expect { subject }.to raise_error(
          Sidetree::Error,
          'Secp256k1 JWK \'y\' property must be 43 bytes.'
        )
      end
    end
  end
end
