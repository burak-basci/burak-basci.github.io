'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"favicon.ico": "d92da94026ef14b2470fc77e2df1767e",
"favicon.png": "b1e6e19cafa905308746bf2b29652cb7",
"assets/assets/fonts/urw-gothic/URWGothic-BookOblique.otf": "618b6bac30198f462aa1eace775109fd",
"assets/assets/fonts/urw-gothic/URWGothic-Demi.otf": "ff393e05506adf99fbe82a51f60beb12",
"assets/assets/fonts/urw-gothic/URWGothic-DemiOblique.otf": "46918584b0d2dee6e8740823fcf87b04",
"assets/assets/fonts/urw-gothic/URWGothic-Book.otf": "27e46100a038e1e6f874d3f6c931b6e5",
"assets/assets/fonts/visuelt/VisueltPro-ExtraLight.ttf": "90bfa0766e43260710e3c6ac0f78c9e9",
"assets/assets/fonts/visuelt/VisueltPro-Regular.ttf": "0f8cd2494eb8c5e3a33352b2dd38fd61",
"assets/assets/fonts/visuelt/VisueltPro-Light.ttf": "2a1df2ff00c2611bf1b7fdeeaeebfa59",
"assets/assets/fonts/visuelt/VisueltPro-Black.ttf": "691b6f9aa3ee625e3cd8da2f8849a126",
"assets/assets/fonts/visuelt/VisueltPro-Thin.ttf": "82d7b5b67c24f00acb08f2dccf1fd03b",
"assets/assets/fonts/visuelt/VisueltPro-Medium.ttf": "cf4dbc20776a2b309fe30a9bbfe7de0a",
"assets/assets/fonts/visuelt/VisueltPro-Bold.ttf": "18acd33c965a455418d4204f0f334ea8",
"assets/assets/fonts/roboto/Roboto-Regular.ttf": "8a36205bd9b83e03af0591a004bc97f4",
"assets/assets/fonts/roboto/Roboto-Medium.ttf": "68ea4734cf86bd544650aee05137d7bb",
"assets/assets/fonts/roboto/Roboto-Bold.ttf": "b8e42971dec8d49207a8c8e2b919a6ac",
"assets/assets/fonts/inter/Inter-Light.ttf": "c3965f36261090496560874aaa610c4e",
"assets/assets/fonts/inter/Inter-ExtraLight.ttf": "ce8d7d651577a310cae58caa4595696e",
"assets/assets/fonts/inter/Inter-Regular.ttf": "a32ace5dba8400232b84bc017dcc38ef",
"assets/assets/fonts/inter/Inter-Bold.ttf": "c59d7314123c3b770bfbbd994215805c",
"assets/assets/fonts/inter/Inter-Thin.ttf": "5dd6e42bd3f80b003e20806fe5de34bd",
"assets/assets/fonts/inter/Inter-Medium.ttf": "eb0312411b133c48049ac630ab7f1fec",
"assets/assets/fonts/carlito/Carlito-Regular.ttf": "f474e3f5ae874552271ac8fed82320a7",
"assets/assets/fonts/carlito/Carlito-Bold.ttf": "b32e6889046488ce0b3c3a322f686873",
"assets/assets/fonts/carlito/Carlito-BoldItalic.ttf": "040cd89c75c9c9ae1c9f50d322e5aaa1",
"assets/assets/fonts/carlito/Carlito-Italic.ttf": "29e88ddd27fd6e4a95a4c5103f0f587d",
"assets/assets/images/default_page_header.png": "5c6f8eb3a22f703781aad6c2528cf0cd",
"assets/assets/images/caesar2.png": "c2bf68cb3b24b5361c95d04c445511a8",
"assets/assets/images/down-arrow.png": "4393cd5feeb20fb468c7eb223d1bbd06",
"assets/assets/images/projects/jumpnrun/cover-color.webp": "83661914d97089cde025921812946a35",
"assets/assets/images/projects/jumpnrun/cover-de.webp": "9b8ce84c588dcadaafd538748c49a026",
"assets/assets/images/projects/jumpnrun/cover.webp": "e38a9f030d5106520690b6cf755673f2",
"assets/assets/images/projects/voice-assistant/cover-color.webp": "e98479a6f4dfe3dd7b7bad8a22f827ed",
"assets/assets/images/projects/voice-assistant/cover-de.webp": "61bd80fab80e8082b5539332337aad40",
"assets/assets/images/projects/voice-assistant/cover.webp": "89c473e20e5f4fed0583aacb4c6af0d7",
"assets/assets/images/projects/nestnode/cover-color.webp": "41d68ab8d2780399007452300ba0c317",
"assets/assets/images/projects/nestnode/cover-de.webp": "5c602e9aa7cbd4b8ae3ecfc8944248ea",
"assets/assets/images/projects/nestnode/cover.webp": "4be6c7d1d01c43093793547379fe54c0",
"assets/assets/images/projects/llm-mail/cover-color.webp": "3b8cb21cd76369de5966ad1c03e3821e",
"assets/assets/images/projects/llm-mail/cover-de.webp": "5ce7f4956d90e71b272a330aabedbdf9",
"assets/assets/images/projects/llm-mail/cover.webp": "984464f9577499ae2f53640465086914",
"assets/assets/images/projects/home-assistant/cover-color.webp": "88500436c39d6928285c801da60a8990",
"assets/assets/images/projects/home-assistant/cover-de.webp": "13717abda67d4c2d7742f828573c3b8d",
"assets/assets/images/projects/home-assistant/cover.webp": "5e0e79b67b3cd74a160f13b1610883c1",
"assets/assets/images/projects/catersmart/cover-color.webp": "f9d729d5cfd796a86c8c1782eb8cd106",
"assets/assets/images/projects/catersmart/cover-de.webp": "363884e3bcf4252c1c3c950123ffdfa8",
"assets/assets/images/projects/catersmart/cover.webp": "036132ce963c378481b5b0e4e956b35f",
"assets/assets/images/projects/image-upscaler/cover.jpg": "4842915ef58467de8072e75c25b8d133",
"assets/assets/images/projects/python-recall/cover-color.webp": "9135f33fea671353b80ad8b456ea0ca1",
"assets/assets/images/projects/python-recall/cover-de.webp": "e413c775735cf4419626807578dfeec4",
"assets/assets/images/projects/python-recall/cover.webp": "e4f1592247c587319dae17df8681e636",
"assets/assets/images/projects/wp-plugins/cover-color.webp": "055bc79ea4fe27008c504351fc590af1",
"assets/assets/images/projects/wp-plugins/cover-de.webp": "614c15d193649fca331cd42836d3b3a7",
"assets/assets/images/projects/wp-plugins/cover.webp": "48db38cfef50f2b534c26435b253b62d",
"assets/assets/images/projects/luminarep/cover-color.webp": "c05a39608413022bfd537c2bf29022aa",
"assets/assets/images/projects/luminarep/cover-de.webp": "3299eb70509c0b4cfadc5dbb614cacd4",
"assets/assets/images/projects/luminarep/cover.webp": "5504eabc251d5eafcff21100b5e6ad97",
"assets/assets/images/projects/unity-hackathon/cover-color.webp": "c0ea6bf9e1db64ca392c6d62429a82b6",
"assets/assets/images/projects/unity-hackathon/cover-de.webp": "301950f5481fd13fd09e3df227a723a8",
"assets/assets/images/projects/unity-hackathon/cover.webp": "258c60969a445aa9e79ea45dc5edaa65",
"assets/assets/images/projects/thesis-night/shot-02.webp": "cf58246da4fe5536130c11b56b07b5fb",
"assets/assets/images/projects/thesis-night/shot-01.webp": "edd8c1a8d4fafa9540512882aa8abdba",
"assets/assets/images/projects/thesis-night/cover-color.webp": "7f37b0763fc50df6760bab50ee301aac",
"assets/assets/images/projects/thesis-night/cover-de.webp": "d158e4f3d2b86fa8ad387889601a79ad",
"assets/assets/images/projects/thesis-night/shot-03.webp": "e74f76ce2397c4cb5017aa846415d039",
"assets/assets/images/projects/thesis-night/cover.webp": "12be432ae61070c8d71198fc012ac109",
"assets/assets/images/projects/theater/cover-color.webp": "fccb632a3573b9c6eed402a2ecdab555",
"assets/assets/images/projects/theater/cover-de.webp": "8931a22fefeeb32e27271e36001c2170",
"assets/assets/images/projects/theater/cover.webp": "2d8e6d85603f6aaf57383819ead58554",
"assets/assets/images/projects/k3s/cover-color.webp": "94696dbe1f73c3858b25f523b258d3c9",
"assets/assets/images/projects/k3s/cover-de.webp": "c321525a122b84dd24c083125318e54f",
"assets/assets/images/projects/k3s/cover.webp": "86c322eb1ea4abef5285a7c865a62e3e",
"assets/assets/images/projects/utopia/cover-color.webp": "4208ee897cede6d81b10e63384d56686",
"assets/assets/images/projects/utopia/cover-de.webp": "e8483715a2e2926cc7111a84e0fd67a5",
"assets/assets/images/projects/utopia/cover.webp": "aa581066c7a332c229135daa9c85634b",
"assets/assets/images/projects/postflow/cover-color.webp": "8ce7d674724212788dd1531d4759672a",
"assets/assets/images/projects/postflow/cover-de.webp": "b9fef8410ad5c786ced9e298fcb421cd",
"assets/assets/images/projects/postflow/cover.webp": "abfd7b7ad2b2320ef96a5c06561bee54",
"assets/assets/images/projects/formal-docs/cover-color.webp": "3e507cfc9a9f3202214b7396edd13fff",
"assets/assets/images/projects/formal-docs/cover-de.webp": "393f9bfe56699bf0fb85aa20945a5d75",
"assets/assets/images/projects/formal-docs/cover.webp": "a1d4d1d5bc835bcc8ba569427c9fb034",
"assets/assets/images/projects/vr-anxiety/shot-01.webp": "9fa5587791d9627a05a2ef87934a2b8a",
"assets/assets/images/projects/vr-anxiety/cover-de.webp": "56f4b7e483825dc0e2e162681c8c1e85",
"assets/assets/images/projects/vr-anxiety/cover.webp": "7837182689f3e858e5b773042e5cf0fe",
"assets/assets/images/projects/flappy-griffon/cover-color.webp": "a108e89c73aa8ebd6fb0210978a17ef8",
"assets/assets/images/projects/flappy-griffon/cover-de.webp": "12c10d60ac45a93ca7f7c754c4e89616",
"assets/assets/images/projects/flappy-griffon/cover.webp": "0545c6778303eb2f00d1421f71cb3821",
"assets/assets/images/projects/binance-tax/cover-color.webp": "5f20e11528a2dfb9e7ed5b92100c68b2",
"assets/assets/images/projects/binance-tax/cover-de.webp": "cfb6bbf0fd93c3ebc5f9115b9ca7664a",
"assets/assets/images/projects/binance-tax/cover.webp": "19a97a1be7bfb3c824132842389c1747",
"assets/assets/images/projects/csfloat/cover-color.webp": "f387c607b09bb439437eab41b58ade03",
"assets/assets/images/projects/csfloat/cover-de.webp": "5a19ae111cf37550378782d1cb0590a4",
"assets/assets/images/projects/csfloat/cover.webp": "4bd6d0be08fc7ef1346e37018f288ba3",
"assets/assets/images/projects/this-site/cover-color.webp": "c161634548b6d969a89abc88cca1969d",
"assets/assets/images/projects/this-site/cover-de.webp": "0e0b6835b67e29543f64322724e5e543",
"assets/assets/images/projects/this-site/cover.webp": "70c69522d4cd98bc03d7f73e6d40e2f5",
"assets/assets/images/projects/durak/shot-02.webp": "7654258bdbfcaf4e4437fe24669515b3",
"assets/assets/images/projects/durak/shot-01.webp": "2c13e36f512435d705e05db98717c5e1",
"assets/assets/images/projects/durak/cover-color.webp": "122b378ed728f2e9071b4d563e9e62eb",
"assets/assets/images/projects/durak/cover-de.webp": "52c359014c9c58be926399935cbe8503",
"assets/assets/images/projects/durak/cover.webp": "b52a69f9c5020ef0dffce8155353c386",
"assets/assets/images/projects/immopilot/cover-color.webp": "25dd93d66ded0872fa468f07b8f36ac7",
"assets/assets/images/projects/immopilot/cover-de.webp": "06380c34cb46a674e19dedcbe337f280",
"assets/assets/images/projects/immopilot/cover.webp": "a4a55e6adae8b0a8485dba10d85b9156",
"assets/assets/images/projects/coldmailing/cover-color.webp": "ad40431899c8009a28e85e7f2364e7a6",
"assets/assets/images/projects/coldmailing/cover-de.webp": "17ef7e33b2940511e05e53c2adff8695",
"assets/assets/images/projects/coldmailing/cover.webp": "4a01d0a7d63e4cd6fc6112da67f5a9d8",
"assets/assets/images/projects/widgets-pkg/cover-color.webp": "29ba50e7c90258c0e4c216d67230a66c",
"assets/assets/images/projects/widgets-pkg/cover-de.webp": "9b7eeda58d505f28681908de49f9c224",
"assets/assets/images/projects/widgets-pkg/cover.webp": "693b69bc5813ebdbca43447fb9650339",
"assets/assets/images/projects/boxhead/shot-03.png": "71c711b5d17df6f67b671ea2df0ec701",
"assets/assets/images/projects/boxhead/shot-04.png": "b02162b2955e5efb6f9e66b93712fed4",
"assets/assets/images/projects/boxhead/shot-01.png": "0aa435c1e2e738ca233d3622ade34320",
"assets/assets/images/projects/boxhead/cover-color.webp": "9f612a7d86eef51d5d774473c555a355",
"assets/assets/images/projects/boxhead/cover-de.webp": "501825d42bb2f4fb4dd8e2000d170f00",
"assets/assets/images/projects/boxhead/shot-02.png": "74f416a50a31024ce0132a65cf616c83",
"assets/assets/images/projects/boxhead/cover.webp": "060af7aff833c5495601541a436ee35b",
"assets/assets/images/projects/steam-market/cover-color.webp": "fb16c13e047aae712ff199971a6d5941",
"assets/assets/images/projects/steam-market/cover-de.webp": "98b527eac0bee76c1677f656a064a9ad",
"assets/assets/images/projects/steam-market/cover.webp": "bd15d55add66e619e6d91e7d57c8fa3f",
"assets/assets/images/projects/pscoat/cover-color.webp": "7638ea84fb0cc2c64417edc5b063d08a",
"assets/assets/images/projects/pscoat/cover-de.webp": "da089912ee04a91cff4fb6d94a6682e5",
"assets/assets/images/projects/pscoat/cover.webp": "0cc9bc583a15e2b5f84424ccdfa07fce",
"assets/assets/images/projects/patent-search/cover-color.webp": "4ae0ef3ba2ce8790177c12578a8672e4",
"assets/assets/images/projects/patent-search/cover-de.webp": "39595868a05599f5f90600cead87b26b",
"assets/assets/images/projects/patent-search/cover.webp": "c85ad8ab0a4236cf7928e949bc6a2f0b",
"assets/assets/images/projects/sovereign-immo/cover-color.webp": "38e7dd7235283703eb6bceb8243ec313",
"assets/assets/images/projects/sovereign-immo/cover-de.webp": "a7cfe9b7e87f88d20d05136cf7fa0ab5",
"assets/assets/images/projects/sovereign-immo/cover.webp": "b9ae9f6a99813b362bccece4d973ec04",
"assets/assets/images/projects/shop-automation/cover-color.webp": "df58c7abfb8e2973db24c06c1f97489a",
"assets/assets/images/projects/shop-automation/cover-de.webp": "850c57a6091e90a070f4a604406216e0",
"assets/assets/images/projects/shop-automation/cover.webp": "06f2f6908dacfec531ec8c9b73b2a750",
"assets/assets/images/projects/freelance/cover-color.webp": "d4d5615f9cc8e02849df2364f9f98526",
"assets/assets/images/projects/freelance/cover-de.webp": "d6db97e5f1cee700dd3fcb68ba2d0e56",
"assets/assets/images/projects/freelance/cover.webp": "04b36b5309bee5a935d873852a27b3eb",
"assets/assets/images/projects/legal-evidence/cover-color.webp": "e1887a480cb388c65286e476c102a56d",
"assets/assets/images/projects/legal-evidence/cover-de.webp": "2e208a55ab4ac83d712126828b996b1f",
"assets/assets/images/projects/legal-evidence/cover.webp": "6331ac4c74fc66913c072063e676ee43",
"assets/assets/images/projects/open-design/shot-03.png": "6539a4d7bcf5d3a06336b5014ffa3324",
"assets/assets/images/projects/open-design/shot-05.png": "9a86ab2512ec8bd39e0aaf61e9c968a3",
"assets/assets/images/projects/open-design/shot-04.png": "e4e3b6dc93e124bcc1555124950e64e7",
"assets/assets/images/projects/open-design/shot-01.png": "727e96cea7a6d830fdb185eab141286e",
"assets/assets/images/projects/open-design/shot-06.png": "ba0851f006bd354ca562349865317495",
"assets/assets/images/projects/open-design/shot-02.png": "6103d4fb796efd09eaaac11543a2bbdc",
"assets/assets/images/right-arrow.png": "62a7bab73a0fe40acd3f4555adfcab91",
"assets/assets/images/home_dude.png": "4d20839af1a2f79a75266dbbf0369aca",
"assets/assets/images/default_page_footer.png": "663d5187ada8666bfa87120d1665605f",
"assets/assets/images/piano.jpg": "9a296cfad4ecc4c715622693faf8c085",
"assets/assets/images/ios-down-arrow.png": "fa4679d2972f1d11355142a60ed34ede",
"assets/FontManifest.json": "16763666fc1b8c2cbcb3f62bd3ed1a80",
"assets/AssetManifest.json": "4a91e9d6e2ce1ab358ee43faa393ec7f",
"assets/fonts/MaterialIcons-Regular.otf": "1becacb47361b0c300e83148a441635d",
"assets/AssetManifest.bin.json": "4dd3d1c10b859c6e4fcac282f3af4344",
"assets/NOTICES": "f5aa8cda156568bbce6a8c23e27eef5c",
"assets/AssetManifest.bin": "986898e66af8b641c3c99322d134c485",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "ce3fe1e9ce6ae0ba186ce28e2f6a4fe8",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "e9703b8610cad8341c774baba3213036",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "262525e2081311609d1fdab966c82bfc",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"manifest.json": "c22239d777022c8da38cfd274970f3fa",
"sitemap.xml": "f4d2681ba074e1caef43bd37ca193152",
"favicon-16x16.png": "4b1cb3e295a3c89edaed9615e612ed2a",
"apple-icon.png": "869b1c354f0c580baedf511d46cd20d5",
"favicon-96x96.png": "14069518c7f4d0ead1e9d7d97c2bf210",
"apple-icon-144x144.png": "d6922517e4760d2e17b75e5114efb2b9",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"apple-icon-114x114.png": "a56a0f738043ecbd8b85194fc5eff2a9",
"ms-icon-150x150.png": "922c023f6bfc6475abca02b0c9d69d16",
"ms-icon-310x310.png": "3df630d318acff6815630dd093df9e8f",
"index.html": "6149f570ee7517be9d4544a73fde11cb",
"/": "6149f570ee7517be9d4544a73fde11cb",
"ms-icon-144x144.png": "d6922517e4760d2e17b75e5114efb2b9",
"apple-icon-76x76.png": "8b6bc7cbc55eec00ef45a89ccbef5090",
"flutter_bootstrap.js": "a927875505770053394267b8cbde79d5",
"favicon-32x32.png": "b1e6e19cafa905308746bf2b29652cb7",
"404.html": "eef457e1fdfa0fca1d56885ef0b42f45",
"apple-icon-72x72.png": "91c3b0b3f58f3276c6d776e836e8a2c4",
"apple-icon-120x120.png": "e320b0e59f2f559cc70c12fb2c253f58",
"apple-icon-60x60.png": "538294b9b14d98bd76f4f2af158b980c",
"apple-icon-57x57.png": "b5ef31eb414e811b4898dd5f78417781",
"ms-icon-70x70.png": "b534289d21bcfadc1c0cc4bca2a69344",
"apple-icon-152x152.png": "cfb852814c77351c9a8e27743c525f5d",
"icons/android-icon-48x48.png": "e69d1303a06560441b0bd5d03a3fce05",
"icons/android-icon-72x72.png": "91c3b0b3f58f3276c6d776e836e8a2c4",
"icons/android-icon-36x36.png": "0f5f99d87f8feb65b912ac3437a800b7",
"icons/android-icon-96x96.png": "14069518c7f4d0ead1e9d7d97c2bf210",
"icons/android-icon-144x144.png": "d6922517e4760d2e17b75e5114efb2b9",
"icons/android-icon-192x192.png": "950701d52f9d14cb902fc2f1b0e511ac",
"apple-icon-180x180.png": "67bddcf915ee8f197b70477ebf53dcea",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"main.dart.js": "2a2db2b9ddcef2e1dad6dfb9e746c018",
"apple-icon-precomposed.png": "869b1c354f0c580baedf511d46cd20d5",
"robots.txt": "2287ab54e007a203c4acca16182897ca",
"version.json": "c24b28c83c66f0912b83c52039dee59b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
