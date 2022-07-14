require "spec_helper"

RSpec.describe Sidetree::Util::Compressor do
  let(:json) do
    [
      "5b7b225f6964223a22356438616238613838333063306162646462356237386661222c22696e646578223a302c2267756964223a2233636137633135302d393664662d343633352d613364342d373831303666383061653537222c226973416374697665223a66616c73652c2262616c616e6365223a2224312c3133372e3838222c2270696374757265223a22687474703a2f2f706c616365686f6c642e69742f3332783332222c22616765223a32322c22657965436f6c6f72223a2262726f776e222c226e616d65223a224d696c6c65722048756262617264222c2267656e646572223a226d616c65222c22636f6d70616e79223a22535155495348222c22656d61696c223a226d696c6c657268756262617264407371756973682e636f6d222c2270686f6e65223a222b31202839343629203431322d33303130222c2261646472657373223a223736342052657665726520506c6163652c20486f6275636b656e2c204e65772048616d7073686972652c2035363335222c2261626f7574223a22457863657074657572206c61626f726973206e6f73747275642061642076656c697420636f6e73656374657475722065737420656e696d206164206f636361656361742e2045737365206e756c6c61206c61626f726520657865726369746174696f6e204c6f72656d20656975736d6f64206c61626f7265206f6363616563617420657420656975736d6f642e2044756973206164697069736963696e67206578636570746575722074656d706f72206d696e696d2063756c70612e2043756c7061207175692065786365707465757220657374204c6f72656d2066756769617420657820697073756d20697073756d20726570726568656e646572697420757420656c69742e0d0a222c2272656769737465726564223a22323031342d31312d30375431323a33363a3038202b30383a3030222c226c61746974756465223a2d312e3939333736382c226c6f6e676974756465223a36382e3337373636352c2274616773223a5b2276656c6974222c22616e696d222c226e6f6e222c22657374222c22646f6c6f72222c2273696e74222c226e6f6e225d2c22667269656e6473223a5b7b226964223a302c226e616d65223a224361696e205370656e6365227d2c7b226964223a312c226e616d65223a22576869746e65792041726d7374726f6e67227d2c7b226964223a322c226e616d65223a22436f72696e612048696c6c227d5d2c226772656574696e67223a2248656c6c6f2c204d696c6c657220487562626172642120596f75206861766520313020756e72656164206d657373616765732e222c226661766f726974654672756974223a2273747261776265727279227d2c7b225f6964223a22356438616238613838663838333936353638323334616333222c22696e646578223a312c2267756964223a2232313466636461352d633930622d343961662d383862642d626464303461396133383064222c226973416374697665223a747275652c2262616c616e6365223a2224332c3331322e3539222c2270696374757265223a22687474703a2f2f706c616365686f6c642e69742f3332783332222c22616765223a32332c22657965436f6c6f72223a2262726f776e222c226e616d65223a224c617572656c20466f776c6572222c2267656e646572223a2266656d616c65222c22636f6d70616e79223a2257414142222c22656d61696c223a226c617572656c666f776c657240776161622e636f6d222c2270686f6e65223a222b31202839313829203533362d33303338222c2261646472657373223a22383033204761796c6f72642044726976652c205961726476696c6c652c2057796f6d696e672c2033353333222c2261626f7574223a224c61626f7269732074656d706f7220696e6369646964756e742061757465206578636570746575722076656e69616d206e697369206475697320696e6369646964756e74206972757265206e6f6e20656c69742e2053756e742063696c6c756d20656c69742070726f6964656e74204c6f72656d206574206465736572756e742e20456975736d6f64206c61626f72697320696e2066756769617420656e696d20757420657820756c6c616d636f20646f6c6f7265207061726961747572206e756c6c6120656c697420616d657420636f6d6d6f646f20636f6e73656374657475722e204164207061726961747572206f66666963696120616c697175612076656e69616d20616c6971756120616c69717561206d6f6c6c697420657420726570726568656e64657269742e20467567696174206578206575206e756c6c6120696e20696e6369646964756e7420697073756d2e0d0a222c2272656769737465726564223a22323031352d30362d30375431303a35363a3231202b30373a3030222c226c61746974756465223a32342e3238313033332c226c6f6e676974756465223a2d3135322e3934313837342c2274616773223a5b226972757265222c226972757265222c22616d6574222c226c61626f7265222c226972757265222c22616d6574222c2265737365225d2c22667269656e6473223a5b7b226964223a302c226e616d65223a225765737420576174736f6e227d2c7b226964223a312c226e616d65223a22426c616e636865204e756e657a227d2c7b226964223a322c226e616d65223a22526f77656e612048657272696e67227d5d2c226772656574696e67223a2248656c6c6f2c204c617572656c20466f776c65722120596f752068617665203420756e72656164206d657373616765732e222c226661766f726974654672756974223a226170706c65227d2c7b225f6964223a22356438616238613861323035396538393933653938386133222c22696e646578223a322c2267756964223a2261393936346462352d636366622d343662382d386631622d356164643536613530353036222c226973416374697665223a747275652c2262616c616e6365223a2224322c3436382e3536222c2270696374757265223a22687474703a2f2f706c616365686f6c642e69742f3332783332222c22616765223a32312c22657965436f6c6f72223a22677265656e222c226e616d65223a224a61636b6965204861726d6f6e222c2267656e646572223a2266656d616c65222c22636f6d70616e79223a2254414c4145222c22656d61696c223a226a61636b69656861726d6f6e4074616c61652e636f6d222c2270686f6e65223a222b31202838313429203539392d32343638222c2261646472657373223a22373837204d6f6e74726f7365204176656e75652c2054686f726e706f72742c204b656e7475636b792c2032393039222c2261626f7574223a22497275726520656e696d20656e696d20657373652065612e20416c697175612064756973207175697320646f6c6f7220657865726369746174696f6e206164697069736963696e672e204972757265207369742075742063696c6c756d2074656d706f7220696e2e204164697069736963696e6720766f6c7570746174652070726f6964656e7420657373652076656c69742070617269617475722069727572652076656e69616d206164697069736963696e672e0d0a222c2272656769737465726564223a22323031382d31302d32375430333a30373a3436202b30373a3030222c226c61746974756465223a2d322e3539393635372c226c6f6e676974756465223a3135362e3734373634392c2274616773223a5b226465736572756e74222c22646f222c226561222c2263696c6c756d222c22657374222c22616e696d222c22636f6e7365637465747572225d2c22667269656e6473223a5b7b226964223a302c226e616d65223a2256616c656e636961204d65726361646f227d2c7b226964223a312c226e616d65223a224c697a20476c617373227d2c7b226964223a322c226e616d65223a224577696e6720416c62657274227d5d2c226772656574696e67223a2248656c6c6f2c204a61636b6965204861726d6f6e2120596f752068617665203320756e72656164206d657373616765732e222c226661766f726974654672756974223a2262616e616e61227d2c7b225f6964223a22356438616238613832663464376232636566353131333032222c22696e646578223a332c2267756964223a2235383534363464642d643135382d343637622d396330382d366164636139666332383362222c226973416374697665223a66616c73652c2262616c616e6365223a2224312c3234372e3139222c2270696374757265223a22687474703a2f2f706c616365686f6c642e69742f3332783332222c22616765223a32392c22657965436f6c6f72223a22626c7565222c226e616d65223a224a756c69652043616272657261222c2267656e646572223a2266656d616c65222c22636f6d70616e79223a22434f4d56454e45222c22656d61696c223a226a756c69656361627265726140636f6d76656e652e636f6d222c2270686f6e65223a222b31202838333129203438372d33393236222c2261646472657373223a2231343720427261676720436f7572742c2043616c65646f6e69612c204d697373697373697070692c2034313034222c2261626f7574223a2245737420756c6c616d636f2061757465206164697069736963696e67206574206e69736920636f6e736563746574757220656e696d206e6f73747275642e20416c697175697020657820616d65742063756c706120657420636f6e7365717561742e204e756c6c6120697275726520616c6971756120656e696d206c61626f7265206972757265204c6f72656d20616420766f6c7570746174652063756c70612063757069646174617420736974206d696e696d2e20457865726369746174696f6e207369742065786365707465757220756c6c616d636f20697073756d206c61626f72697320616e696d206375706964617461742e0d0a222c2272656769737465726564223a22323031372d30392d30315430373a34363a3439202b30373a3030222c226c61746974756465223a2d37332e3830363732342c226c6f6e676974756465223a2d3134342e3035313732342c2274616773223a5b2270726f6964656e74222c226561222c22657863657074657572222c22657863657074657572222c226e756c6c61222c2261757465222c22657374225d2c22667269656e6473223a5b7b226964223a302c226e616d65223a22457370696e6f7a61204b6e69676874227d2c7b226964223a312c226e616d65223a225768697465204b656e74227d2c7b226964223a322c226e616d65223a224d6f6c6c6965204461766973227d5d2c226772656574696e67223a2248656c6c6f2c204a756c696520436162726572612120596f752068617665203220756e72656164206d657373616765732e222c226661766f726974654672756974223a2273747261776265727279227d2c7b225f6964223a22356438616238613830386164353735663865616236643539222c22696e646578223a342c2267756964223a2264323561663639312d313334312d343264342d613239612d343336653936643634346165222c226973416374697665223a66616c73652c2262616c616e6365223a2224322c3833362e3734222c2270696374757265223a22687474703a2f2f706c616365686f6c642e69742f3332783332222c22616765223a33322c22657965436f6c6f72223a2262726f776e222c226e616d65223a22526f73616c796e204f627269656e222c2267656e646572223a2266656d616c65222c22636f6d70616e79223a224e5552414c49222c22656d61696c223a22726f73616c796e6f627269656e406e7572616c692e636f6d222c2270686f6e65223a222b31202838303929203532362d32333833222c2261646472657373223a22343933204b6f73636975736b6f205374726565742c2057656f6775666b612c20436f6c6f7261646f2c2035373138222c2261626f7574223a224475697320696420657820726570726568656e6465726974206c61626f72756d206e756c6c6120646f6c6f72206e756c6c6120646f6c6f7265206175746520706172696174757220696e206573742e2055742065737365206c61626f726973206c61626f72697320756c6c616d636f206f6666696369612074656d706f7220756c6c616d636f2e20497073756d20657863657074657572206c61626f72756d206573742070726f6964656e74206e69736920756c6c616d636f206475697320656975736d6f642e20506172696174757220656120646f6c6f7220656c69742065752e20436f6d6d6f646f20706172696174757220696e6369646964756e74206675676961742064756973206e6f6e206578636570746575722e204164697069736963696e672061757465206f66666963696120646f6c6f7265206d6f6c6c6974206375706964617461742e204c61626f72756d2074656d706f72206e6f737472756420657374206d6f6c6c697420656c697420616e696d20616d657420646f20617574652073697420696e20756c6c616d636f206561206465736572756e742e0d0a222c2272656769737465726564223a22323031362d30322d30375431323a30373a3039202b30383a3030222c226c61746974756465223a36352e3034303331392c226c6f6e676974756465223a2d3132352e3336303631372c2274616773223a5b226e6f7374727564222c226e6f7374727564222c22616c6971756970222c22636f6e736571756174222c22697073756d222c2265737365222c2263696c6c756d225d2c22667269656e6473223a5b7b226964223a302c226e616d65223a22426f77656e204d6f727269736f6e227d2c7b226964223a312c226e616d65223a224761726e65722041726e6f6c64227d2c7b226964223a322c226e616d65223a22526f7369652052696365227d5d2c226772656574696e67223a2248656c6c6f2c20526f73616c796e204f627269656e2120596f752068617665203920756e72656164206d657373616765732e222c226661766f726974654672756974223a226170706c65227d2c7b225f6964223a22356438616238613862613233356635626533666365616438222c22696e646578223a352c2267756964223a2263643366393136322d376330392d346436312d613631382d663465323565626236376565222c226973416374697665223a747275652c2262616c616e6365223a2224322c3133392e3631222c2270696374757265223a22687474703a2f2f706c616365686f6c642e69742f3332783332222c22616765223a33322c22657965436f6c6f72223a2262726f776e222c226e616d65223a224368656c736561204c796e6e222c2267656e646572223a2266656d616c65222c22636f6d70616e79223a22475255504f4c49222c22656d61696c223a226368656c7365616c796e6e40677275706f6c692e636f6d222c2270686f6e65223a222b31202839353429203534302d33333336222c2261646472657373223a2232323020426561766572205374726565742c205369646d616e2c204172697a6f6e612c2036353937222c2261626f7574223a224c61626f726520657865726369746174696f6e206c61626f7265206f6363616563617420657420657863657074657572206e69736920636f6d6d6f646f20726570726568656e64657269742073696e742e2053756e742074656d706f7220616d65742076656c6974206d696e696d2066756769617420697275726520616e696d20726570726568656e646572697420616c69717569702070726f6964656e742071756920726570726568656e646572697420616e696d2e20436f6e73657175617420646f6c6f7265206465736572756e74206e6f7374727564204c6f72656d2070726f6964656e74204c6f72656d206e6973692e0d0a222c2272656769737465726564223a22323031352d30392d31365431313a30343a3135202b30373a3030222c226c61746974756465223a31392e3237343135352c226c6f6e676974756465223a2d3134382e31373139362c2274616773223a5b22646f222c226164697069736963696e67222c226561222c227061726961747572222c2265737365222c22636f6d6d6f646f222c2261757465225d2c22667269656e6473223a5b7b226964223a302c226e616d65223a2254686f726e746f6e20436f7465227d2c7b226964223a312c226e616d65223a224d656c6261205265657365227d2c7b226964223a322c226e616d65223a2247616c6c6f77617920436f6e726164227d5d2c226772656574696e67223a2248656c6c6f2c204368656c736561204c796e6e2120596f752068617665203120756e72656164206d657373616765732e222c226661766f726974654672756974223a2262616e616e61227d5d"
    ].pack("H*")
  end

  it "compress and decompress as" do
    compressed = described_class.compress(json)
    expect(compressed.unpack1("H*")).to eq(
      "1f8b0800000000000003ad986b6fdc361686bf2fd0ffc01dec872d2a29bce842cd274f1cc74e6327a9edd4288a624149d40c371a49d5c59714fdef7b485d467214a74617093c3314491d5e9ef7bce4af7facfea392d57ae5255c445c70ce708c4594249117053c152b6ba5f244deafd6d85a6d5b5397c522888987edd04f52dbf599670b96b876c009f6538e85f402ddaedec48dba95ab752ab25a5aab4864228fe1f7ea5fc4222c7038876aa58a9bb6d2a5bba629d72f5e949988e5aec81247352f18bd67146a892dd4a0d45ac907795c644505f5a3aab8cbe1592ef6baf985ca3259a1b3368a449540f95642e4bae25e64127ec7c5be14f903145cfdf4f1cdd51914c9bd5099ae61daeebaa647f5efadaa770ed4d7f1ed8a5c77ff0341ff0e5dff7be4126a334cb08e2a492a59d7f034f05d74296f6525d1071dbf85ce8aa88d3fc9dc42efe41d3a13fbb2dea90a1e783061ba6d54b40db43cb98f65d9c8b642191455aa46795137559b2091a05b99a906c5455ecbb891304f48d60d92b9daeba7451c0b198bc64127752d51de6699e87a9148decb2a568d685491a37328d923a9da7a5f24438da13592cdf0c841af60e4d0b52a55ad62956fa19f21bc46eecba2427ba5df1eb759291c74ac3f104cd7a49e8eb07b61da6e95eeff1ea9b26ef7fddf4a9695dc99b581b1b5f01cc6e87cf70f98934a6e55ddc024ea6d4631716d426c1c5c13ba66fe1a73f403e66bac673e8381356d020b6313270c59e073282cf26d5fea73870581ef7bd6aa115b58a15f57662ef5c443fc7ad7147aef40b0f037313bca5ad52a6ffa47bf59abb45210a56efbc74a6f7c3c6eb563a17274554abd9bffb4baa7647c7ab3534d2e1fd0a6dac342424c631d7ae801563a17e80cf6ddea4f78d7b692b281f986476732cb0a0bcdb7f33fd12f458b76e2562282519b5712d67f0f7b0fc0a81d883915b7d065235f57add2db0ade2cee2259550fe6ed8f284f01f4d0f77c4e992b6276a09c8c9453e2a671223c3b0e7164bba1486dcea3c4066dc0ae0805e33899510e7b760e39b318a18e173e1372f614e4e702bac9d0ebe20e2667ca782abfa0fc66b37939613c334d53d3f2e84e88680970c2bf471ef30170c6678073ccd0a97880a012f4aa82015be81758975bbd4a16ba7928808bad8598c7d804eef31ee99e1d95c72a51499b3748b48d9c40730b4c8b3dca013b9468062755550581832ae41d29e84a17c6f06280c9e84359152a91f9801df09cc85a56500d94610abde977c45273dc1a3cb570ece302190e242a45051520aa4e51cc3b60fab510eda1af622a480eda248706459a826c082432f57b2b8651f5bffa8f7d91e90ea1bb991238e8f52817b2ed5f0dd14e2742ebc7b2527836f68d52e0b5e7af2901a5081e2b05751d0a298ab19952d8c4a34ee8121eb807ad3053ae7777ffa9476ffad2caf965396c11f9b462dc6855bc114d0dd2f2a562bcd4ccec247ad7e6f2f3825a5c167752ab05e0ac3562593066684cf4c2fd2b7221ca32930b4a2128f642c9416165c8b99828051d954284a1ef8261b0e33805a5f0236ef39444b607f478bef0b087fda795825a2e08b6e73f5329c84c29f48c4c94e247117f5212126fb5374aff94525c6fce372713a9f8af69bb334d8f1a88532e6805272e684518da14829f9b011ea08b2207ed87acbc010860b8e87a575439884063a1b7c02a7883070bd1108713b97863483760767f745a979067371d3a4619b439e9489d27f949d67650d753dd25d85e2b4611d2cc1e32fc6d91b525f4210f3a62dedb798f11ed4e8506a227ef5ae491db04db34b8c66c0d20bafe128fb64e0e908582198fc4f39dc0053f151e701ce4cca46abd4eda9776a31a73789fd627d2f434913fc326c8b5565dc01c0ae8f64b2ccfd567749a0958d32f913cb9d373b7c920c5365f0172b6032740b2bf02642472f8b740244ddd2488682c538f1086e981483612e971cf0524133b211e072283c80e63cc6d5f24b108d39872167dd3a1533770c8739377384fde592b2744b6194cc7b1882a59896f1079fcfee2e79377332675ebb86b7c041561272e52c90858741ed82ca4fe8c4ae206e86525b65b745cb41ac363786952c07ed666abaef5ffb25416187cec4e0d3a28f790204dd69ed9e3a6cbd9338baed1ed4d7c8fae2a755aeb72a8b1ccb277f5403564be775db23384f559d274d23bf5ee4197dcf5a16004b6eb2b6e4b95082830bc1b7f0e797f2a0dbafce03586c174767c3006a2b3f57d57cb5407360e6d4cae0dd26b375ca43a600ec77e40dd4769d6751dec11533e703d08ce80f418e3a3efc60ce82581e9ef817f92ed93ba5479f159a0b7b9daee9aaf787469847881ed0bed50247a256e55fd35b6a77b79c236fddbde1c73917881977229223f31eeb9e7db1df94ea827523f2436612eb15d0a876f414361bbcc977028f75d57c86ff04d2dceb4d03e8f6ff6e409fcb2a845f690a3f7915e996f10feeee3e5e6fccd04f0aa6b5d98c647795b01094b80e310d22ef56dca389b01ee860cbd2dea181cefa7025d357ad1c09acb62dba69f00721335283d1cc103c227849b43af4a34a2f3c3a9610318e9cc68977327df65a707871499ebc3af833ef61974406bf81cc01b5c729f90fb6248da064839bf10d025f5c4e31bb9190dbb8e7c3cbc7f18029143b02685cb160eeabd739fc43adaeafe3c60fa32a78c2180b94f30631d42efc7df7bf9836ca0f33ee67e6cc35d861ec260fccd71c25c61683d4c7a55d51a0513388c4c0f6138c42c6a11d87ddadf0d68110a97ee067ccfc12e66247c2445d473988f7d121ca4a80fd49cfe876fa293eec15568add654e9551a4cff68439ed4a397dabf832504fbbe7c003815550e87fd4d9503758b07801ae4e652e9fb86453d9aa33711a4f0efb8ff4850e6a55e24591a431ffca045dea84571c2d290f8d40e62480e6ee2135bf8e0ff5257524f46911fc8b9162db87fc242c727ff4f293ade49503c81ce1ff26f09d1e9e5c70fef674a14778d613ef3a36dd596c5a210859ef6ff2eb6196373a74129462f25cc7e35aad0954af622b76085d5e7220731f2bd30787c51f0e8d66ee99e6ed486de757454cf554bdf62f5b7043d8506b4cecf77d7773df2bde3d025f32efa9d7f501d7dc5f7a88ab119c7031883220cd08ee477b6e5d115858efeab07f9d026fe35216becc26160c96290d0a1814b3cefb1c3e00e0948e84f0e0e85599851c406a331c8e004e36e2a0793f124cee628d7c00a1d17cdd205e085cc22812e254cc502cba70288bd130f7aee201d7d05e8e9069e5efe3de7ecf0dbff007e065b8edf170000"
    )
    decompressed = described_class.decompress(compressed)
    expect(decompressed).to eq(json)
  end

  context "decompressed data exceeds maximum size specified" do
    it "raise error" do
      compressed = described_class.compress(json)
      expect {
        described_class.decompress(
          compressed,
          max_bytes: compressed.bytesize - 1
        )
      }.to raise_error(
        Sidetree::Error,
        "Exceed maximum compressed chunk file size."
      )
      expect {
        described_class.decompress(compressed, max_bytes: compressed.bytesize)
      }.not_to raise_error
    end
  end
end
