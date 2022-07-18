require "spec_helper"

RSpec.describe Sidetree::CAS::IPFS do
  before do
    stub_request(:post, "http://localhost:5001/api/v0/id").to_return(
      status: 200,
      body:
        '{"ID":"12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","PublicKey":"CAESIKeJOO0nQipXN7r5m4FpayysfU8QqkppS1ByTWwFiBFS","Addresses":["/ip4/119.47.61.98/tcp/46075/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip4/119.47.61.98/udp/46075/quic/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip4/127.0.0.1/tcp/4001/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip4/127.0.0.1/udp/4001/quic/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip4/192.168.50.185/tcp/4001/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip4/192.168.50.185/udp/4001/quic/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip6/::1/tcp/4001/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw","/ip6/::1/udp/4001/quic/p2p/12D3KooWM6McbQzskE3xx4DMcy4uy2Ydfo91BDwCL7T4xCLN1NDw"],"AgentVersion":"go-ipfs/0.12.2/","ProtocolVersion":"ipfs/0.1.0","Protocols":["/ipfs/bitswap","/ipfs/bitswap/1.0.0","/ipfs/bitswap/1.1.0","/ipfs/bitswap/1.2.0","/ipfs/id/1.0.0","/ipfs/id/push/1.0.0","/ipfs/kad/1.0.0","/ipfs/lan/kad/1.0.0","/ipfs/ping/1.0.0","/libp2p/autonat/1.0.0","/libp2p/circuit/relay/0.1.0","/libp2p/circuit/relay/0.2.0/hop","/libp2p/circuit/relay/0.2.0/stop","/p2p/id/delta/1.0.0","/x/"]}'
    )
  end
  describe "#write" do
    context '"IPFS HTTP API returned OK status' do
      before do
        stub_request(:post, "http://localhost:5001/api/v0/add").to_return(
          status: 200,
          body:
            '{"Name":"QmcUeB9gvUWb5pq4qCsvnM6pbxSgETUvXmd9puVf3jpDXG","Hash":"QmcUeB9gvUWb5pq4qCsvnM6pbxSgETUvXmd9puVf3jpDXG","Size":"292"}'
        )
      end
      it "return file hash of the content written." do
        create_op = Sidetree::OP::Create.generate
        chunk_file =
          Sidetree::Model::ChunkFile.create_from_ops(create_ops: [create_op])
        ipfs = described_class.new
        expect(ipfs.write(chunk_file.to_compress)).to eq('QmcUeB9gvUWb5pq4qCsvnM6pbxSgETUvXmd9puVf3jpDXG')
        expect(WebMock).to have_requested(
                             :post,
                             "http://localhost:5001/api/v0/add"
                           ).once
      end
    end

    context "IPFS HTTP API returned a non-OK status with or without body" do
      it "raise error." do
      end
    end

    context "IPFS HTTP API returned a non-OK status without body" do
      it "raise error." do
      end
    end
  end

  describe "#read" do
    it "set fetch CIDv0 result as success" do
    end

    it "set fetch CIDv1 result as success" do
    end

    context "IPFS HTTP API returns non OK status" do
      it "set fetch result as not-found" do
      end
    end

    context "timeout throws unexpected error" do
      it "set fetch result as not-found" do
      end
    end

    context "timeout throws timeout error" do
      it "set fetch result as not-found" do
      end
    end

    context "given hash is invalid" do
      it "set fetch result correctly" do
      end
    end

    context "IPFS service is not reachable" do
      it "return correct fetch result code" do
      end
    end

    context "fetch throws unexpected error" do
      it "return as content not found" do
      end
    end

    context "unexpected error occurred while reading the content stream" do
      it "return as content not found" do
      end
    end

    context "content found is not a file" do
      it "return correct fetch result code" do
      end
    end

    context "content max size is exceeded" do
      it "return correct fetch result code" do
      end
    end
  end
end
