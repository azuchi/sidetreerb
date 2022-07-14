require "spec_helper"

RSpec.describe Sidetree::Model::ChunkFile do
  describe "#create_from_ops" do
    it "generate ChunkFile instance" do
      create_op = Sidetree::OP::Create.generate
      chunk_file = described_class.create_from_ops(create_ops: [create_op])
      expect(chunk_file.deltas.size).to eq(1)
      expect(chunk_file.deltas[0]).to eq(create_op.delta)
    end
  end

  describe "#prase" do
    let(:chunk_data) do
      [
        "1f8b08000000000000034d91614fc2301086ff4b3f0b6e1888f24de7c8a62202138d8698dadeb6b26ead6bb731c9febb2d089af4c3f5bdf79ede5d778802d758a1f1fb0e5592620d9ec873a67328341a239fddc44eb0880baa5d928f565befed2b1bb6aa50edfc4b45fcc3597ef72efdeb0f98065e83ce90c49aa470e061a299280ca504c9310193a6825407f40ec9ea9333720fedc1cda8712a9614ac488c68ccba95607b2054e1251039188e327705258b19c1166d6c03c7bdb2cf1e59774d66d9996e6da56752a4ac2df8586f94adb9cfe70f336fb8899ec8f38c66cdf476e96c7a577c01abc974eb10df8d491847af735287a6c2c2824715a572d6def341350aaa49f0b278f49f7cceebd584f446d9ab9fe8642336df3721ea6c47a5146abf09842b9d9aa17fbb363cac1494369e824e05b55d62893f1967ba0d8b5a9c8c7ff22d70488e7206ed755202ec57b9eed66766beb26604feaff2a084d41d5cfc2d53891c221b9e4afc824ac1f6bf9d6a2dd5f8fcbc699a7e55f23e1139ead69d39ebee07b0a336622a020000"
      ].pack("H*")
    end
    subject { described_class.parse(chunk_data) }

    it "generate ChunkFile instance" do
      expect(subject.deltas.size).to eq(1)
    end

    context "compressed data contains unknown property." do
      let(:chunk_data) do
        [
          "1f8b08000000000000034d915f53e23014c5bf8a9367476911167943ac4c81754540911d66272497126993d0dcfe93e9773701d17d4b4ecefde5e4e44038c4480de9fe3d904c738ad0574922300189a44b02d16b4c5e178f6dd1da2f3badf1e895de99cd9b54a361eb637aef7bd364308e263e5b363b0f3d72493445b685138f32144a5a4a0a3aa60cec31572c3ba10f4467eb58b0115427b7e0d6694424858cac68cd586970191837740a4cfbadf6ce7b81546c04a30e6d6d7ec3bb75d79e59c362e7d83bacdc64df1eb13477e0f3bc554abbef2cfe040d1f47b49c61d199e7de3a0c9b318cb3c16c81ef057d6437c1cb9cc17bbfb0130e261f12c3effef5725de220586ef6f3f6ed66bd800ffdab14cf5533d1e16c385d4ef6fa86d42e51aa9539364168865bfbe8afd496478d81d4ad7f036e157729a9a66b110bac4299ab6fe38f7c0f3144677907552f4a018e55aeead5a57d5f9a0b06ff57795242eef9cd9f328d4a60e696df2381e45a89e36f6f11b5e95e5f17457195a5f1155309a957757dbc2193506a6008fc2955dac677a550595de434ce80d49f6772afdf4b020000"
        ].pack("H*")
      end
      it "raise error" do
        expect { subject }.to raise_error(
          Sidetree::Error,
          "Unexpected property unexpectedProperty in chunk file."
        )
      end
    end
  end
end
