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
    end
  end

end
