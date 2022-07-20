require "spec_helper"

RSpec.describe Sidetree::CAS::IPFS do
  let(:add_url) { "#{ipfs_base_url}add" }
  before do
    stub_request(:post, "http://localhost:5001/api/v0/id").to_return(
      status: 200,
      body:
        '{"ID":"12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","PublicKey":"CAESIKeJOO0nQipXN7r5m4FpayysfU8QqkppS1ByTWwFiBFS","Addresses":["/ip4/119.47.61.98/tcp/46075/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip4/119.47.61.98/udp/46075/quic/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip4/127.0.0.1/tcp/4001/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip4/127.0.0.1/udp/4001/quic/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip4/192.168.50.185/tcp/4001/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip4/192.168.50.185/udp/4001/quic/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip6/::1/tcp/4001/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip6/::1/udp/4001/quic/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw"],"AgentVersion":"go-ipfs/0.12.2/","ProtocolVersion":"ipfs/0.1.0","Protocols":["/ipfs/bitswap","/ipfs/bitswap/1.0.0","/ipfs/bitswap/1.1.0","/ipfs/bitswap/1.2.0","/ipfs/id/1.0.0","/ipfs/id/push/1.0.0","/ipfs/kad/1.0.0","/ipfs/lan/kad/1.0.0","/ipfs/ping/1.0.0","/libp2p/autonat/1.0.0","/libp2p/circuit/relay/0.1.0","/libp2p/circuit/relay/0.2.0/hop","/libp2p/circuit/relay/0.2.0/stop","/p2p/id/delta/1.0.0","/x/"]}'
    )
  end
  describe "#write" do
    subject do
      chunk_file =
        Sidetree::Model::ChunkFile.create_from_ops(
          create_ops: [Sidetree::OP::Create.generate]
        )
      described_class.new.write(chunk_file.to_compress)
    end
    context '"IPFS HTTP API returned OK status' do
      before do
        stub_request(:post, add_url).to_return(
          status: 200,
          body:
            '{"Name":"QmcUeB9gvUWb5pq4qCsvnM6pbxSgETUvXmd9puVf3jpDXG","Hash":"QmcUeB9gvUWb5pq4qCsvnM6pbxSgETUvXmd9puVf3jpDXG","Size":"292"}'
        )
      end
      it "return file hash of the content written." do
        expect(subject).to eq("QmcUeB9gvUWb5pq4qCsvnM6pbxSgETUvXmd9puVf3jpDXG")
        expect(WebMock).to have_requested(:post, add_url).once
      end
    end

    context "IPFS HTTP API returned a non-OK status with or without body" do
      before do
        stub_request(:post, add_url).to_return(status: 500, body: "unused")
      end
      it "raise error." do
        expect { subject }.to raise_error(
          Sidetree::Error,
          "Failed writing content. unused"
        )
      end
    end

    context "IPFS HTTP API returned a non-OK status without body" do
      before { stub_request(:post, add_url).to_return(status: 500) }
      it "raise error." do
        expect { subject }.to raise_error(
          Sidetree::Error,
          "Failed writing content. "
        )
      end
    end
  end

  describe "#read" do
    let(:read_url) do
      "#{ipfs_base_url}cat?arg=QmcUeB9gvUWb5pq4qCsvnM6pbxSgETUvXmd9puVf3jpDXG"
    end
    let(:chunk_file) do
      decompressed =
        '{"deltas":[{"patches":[{"action":"replace","document":{"publicKeys":[{"id":"signing-key","publicKeyJwk":{"crv":"secp256k1","kty":"EC","x":"e8GxPKV0uIAs1KzIrCKTwUYo4FZ0htHOhv6xvd48OPc","y":"cqkqkzusRi__7UN18hUnodTTbcAe7fCrgASKSqsIri8"},"purposes":[]}],"services":[]}}],"updateCommitment":"EiAgHnpr3R5M3_z7-02T8c7uKtpgwrJzihm34iRcKfPdEg"}]}'
      Sidetree::Model::ChunkFile.parse(decompressed, compressed: false)
    end
    subject do
      described_class.new.read("QmcUeB9gvUWb5pq4qCsvnM6pbxSgETUvXmd9puVf3jpDXG")
    end
    before do
      stub_request(:post, read_url).to_return(
        status: 200,
        body: chunk_file.to_compress
      )
    end
    context "IPFS returns CIDv0" do
      it "set fetch CIDv0 result as success" do
        expect(subject.code).to eq(Sidetree::CAS::FetchResult::CODE_SUCCESS)
        expect(Sidetree::Model::ChunkFile.parse(subject.content)).to eq(
          chunk_file
        )
        expect(WebMock).to have_requested(:post, read_url).once
      end
    end

    context "IPFS returns CIDv1" do
      before {}
      it "set fetch CIDv1 result as success" do
        # TODO
      end
    end

    context "IPFS HTTP API returns non OK status" do
      before do
        stub_request(:post, read_url).to_return(status: 500, body: "unused")
      end
      it "set fetch result as not-found" do
        expect(subject.code).to eq(Sidetree::CAS::FetchResult::CODE_NOT_FOUND)
        expect(subject.content).to be nil
      end
    end

    context "IPFS service is not reachable" do
      before { stub_request(:post, read_url).to_raise(Errno::ECONNREFUSED) }
      it "return correct fetch result code" do
        expect(subject.code).to eq(
          Sidetree::CAS::FetchResult::CODE_CAS_NOT_REACHABLE
        )
      end
    end

    context "fetch throws unexpected error" do
      before { stub_request(:post, read_url).to_raise(RuntimeError) }
      it "return as content not found" do
        expect(subject.code).to eq(Sidetree::CAS::FetchResult::CODE_NOT_FOUND)
      end
    end
  end
end
