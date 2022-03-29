require 'spec_helper'

RSpec.describe Sidetree::DID do

  describe '#initialize' do
    let(:did) { 'did:sidetree:EiAgE-q5cRcn4JHh8ETJGKqaJv1z2OgjmN3N-APx0aAvHg' }
    subject { Sidetree::DID.new(did) }
    context 'short form' do

      context 'Unsupported method' do
        let(:did) { 'did:sidetree2:EiAgE-q5cRcn4JHh8ETJGKqaJv1z2OgjmN3N-APx0aAvHg' }
        it 'raise error' do
          expect{subject}.to raise_error(Sidetree::Error, 'Expected DID method not given in DID.')
        end
      end

      context 'ion' do
        let(:did) { 'did:ion:EiAgE-q5cRcn4JHh8ETJGKqaJv1z2OgjmN3N-APx0aAvHg' }
        it do
          expect(subject.method).to eq('ion')
        end
      end

      it do
        expect(subject.short_form?).to be true
        expect(subject.long_form?).to be false
        expect(subject.method).to eq('sidetree')
        expect(subject.suffix).to eq('EiAgE-q5cRcn4JHh8ETJGKqaJv1z2OgjmN3N-APx0aAvHg')
      end
    end

    context 'long form' do
      let(:did) { 'did:sidetree:EiCpTgB_VcGO8hr4dYIvdKVfIPpzEDwSbbPxRJ0Acx4Xzw:eyJkZWx0YSI6eyJwYXRjaGVzIjpbeyJhY3Rpb24iOiJyZXBsYWNlIiwiZG9jdW1lbnQiOnsicHVibGljS2V5cyI6W10sInNlcnZpY2VzIjpbXX19XSwidXBkYXRlQ29tbWl0bWVudCI6IkVpREx6djJQbGJRc1BscjU2VmpGeUo5YW4xTW54M1hVSHBVcktoT1hrdEFQZGcifSwic3VmZml4RGF0YSI6eyJkZWx0YUhhc2giOiJFaUE5TmkwNUhqd1VYSk5lbFV2LUFqM1Y1M3V5aXI4QTRMSmJ1ZGstZ2xfNzR3IiwicmVjb3ZlcnlDb21taXRtZW50IjoiRWlBaGNMZHZSTGpZam44YktrV3RzS1BuNXJxcTJRZXVmX2FXQ2JjNFphaEczdyJ9fQ' }

      it do
        expect(subject.short_form?).to be false
        expect(subject.long_form?).to be true
        expect(subject.method).to eq('sidetree')
        expect(subject.suffix).to eq('EiCpTgB_VcGO8hr4dYIvdKVfIPpzEDwSbbPxRJ0Acx4Xzw')
        expect(subject.long_suffix).to eq('eyJkZWx0YSI6eyJwYXRjaGVzIjpbeyJhY3Rpb24iOiJyZXBsYWNlIiwiZG9jdW1lbnQiOnsicHVibGljS2V5cyI6W10sInNlcnZpY2VzIjpbXX19XSwidXBkYXRlQ29tbWl0bWVudCI6IkVpREx6djJQbGJRc1BscjU2VmpGeUo5YW4xTW54M1hVSHBVcktoT1hrdEFQZGcifSwic3VmZml4RGF0YSI6eyJkZWx0YUhhc2giOiJFaUE5TmkwNUhqd1VYSk5lbFV2LUFqM1Y1M3V5aXI4QTRMSmJ1ZGstZ2xfNzR3IiwicmVjb3ZlcnlDb21taXRtZW50IjoiRWlBaGNMZHZSTGpZam44YktrV3RzS1BuNXJxcTJRZXVmX2FXQ2JjNFphaEczdyJ9fQ')
        expect(subject.create_op.match_delta_hash?).to be true
      end

      context 'Encoded DID document mismatches short-form DID' do
        let(:did) { 'did:sidetree:EiA_MismatchingDID_AAAAAAAAAAAAAAAAAAAAAAAAAAA:eyJkZWx0YSI6eyJwYXRjaGVzIjpbeyJhY3Rpb24iOiJyZXBsYWNlIiwiZG9jdW1lbnQiOnsicHVibGljS2V5cyI6W10sInNlcnZpY2VzIjpbXX19XSwidXBkYXRlQ29tbWl0bWVudCI6IkVpREx6djJQbGJRc1BscjU2VmpGeUo5YW4xTW54M1hVSHBVcktoT1hrdEFQZGcifSwic3VmZml4RGF0YSI6eyJkZWx0YUhhc2giOiJFaUE5TmkwNUhqd1VYSk5lbFV2LUFqM1Y1M3V5aXI4QTRMSmJ1ZGstZ2xfNzR3IiwicmVjb3ZlcnlDb21taXRtZW50IjoiRWlBaGNMZHZSTGpZam44YktrV3RzS1BuNXJxcTJRZXVmX2FXQ2JjNFphaEczdyJ9fQ' }
        it 'raise error' do
          expect{subject}.to raise_error(Sidetree::Error, 'DID document mismatches short-form DID.')
        end
      end

      context 'Invalid format' do
        let(:did) {'did:sidetree:EiCpTgB_VcGO8hr4dYIvdKVfIPpzEDwSbbPxRJ0Acx4Xzw:eyJkZWx0YSI6eyJwYXRjaGVzIjpbeyJhY3Rpb24iOiJyZXBsYWNlIiwiZG9jdW1lbnQiOnsicHVibGljS2V5cyI6W10sInNlcnZpY2VzIjpbXX19XSwidXBkYXRlQ29tbWl0bWVudCI6IkVpREx6djJQbGJRc1BscjU2VmpGeUo5YW4xTW54M1hVSHBVcktoT1hrdEFQZGcifSwic3VmZml4RGF0YSI6eyJkZWx0YUhhc2giOiJFaUE5TmkwNUhqd1VYSk5lbFV2LUFqM1Y1M3V5aXI4QTRMSmJ1ZGstZ2xfNzR3IiwicmVjb3ZlcnlDb21taXRtZW50IjoiRWlBaGNMZHZSTGpZam44YktrV3RzS1BuNXJxcTJRZXVmX2FXQ2JjNFphaEczdyJ9fQ:'}
        it 'raise error' do
          expect {subject}.to raise_error(Sidetree::Error, 'Unsupported DID format.')
        end
      end

      context 'long suffix not json' do
        let(:did) {"did:sidetree:EiCpTgB_VcGO8hr4dYIvdKVfIPpzEDwSbbPxRJ0Acx4Xzw:#{Base64.urlsafe_encode64('notJson', padding: false)}"}
        it 'raise error' do
          expect {subject}.to raise_error(Sidetree::Error, 'Long form initial state should be encoded jcs.')
        end
      end

      context 'long suffix is not jcs' do
        let(:did) {"did:sidetree:EiCpTgB_VcGO8hr4dYIvdKVfIPpzEDwSbbPxRJ0Acx4Xzw:#{Base64.urlsafe_encode64({z: 1, a: 2, b: 1}.to_json, padding: false)}"}
        it 'raise error' do
          expect {subject}.to raise_error(Sidetree::Error, 'Initial state object and JCS string mismatch.')
        end
      end

      context 'delta exceeds size limit' do
        let(:did) do
          large_data = { data: Random.bytes(2000).unpack1('H*') }
          suffix = {deltaHash: "EiA9Ni05HjwUXJNelUv-Aj3V53uyir8A4LJbudk-gl_74w",
                    recoveryCommitment:"EiAhcLdvRLjYjn8bKkWtsKPn5rqq2Qeuf_aWCbc4ZahG3w"}
          long_suffix = Base64.urlsafe_encode64({ suffixData: suffix, delta: large_data }.to_json_c14n, padding: false)
          "did:sidetree:EiCpTgB_VcGO8hr4dYIvdKVfIPpzEDwSbbPxRJ0Acx4Xzw:#{long_suffix}"
        end
        it 'raise error' do
          expect {subject}.to raise_error(Sidetree::Error, "4011 bytes of 'delta' exceeded limit of 1000 bytes.")
        end
      end
    end
  end

end
