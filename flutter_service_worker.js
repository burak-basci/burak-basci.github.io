'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"apple-icon-114x114.png": "a56a0f738043ecbd8b85194fc5eff2a9",
"apple-icon-120x120.png": "e320b0e59f2f559cc70c12fb2c253f58",
"apple-icon-72x72.png": "91c3b0b3f58f3276c6d776e836e8a2c4",
"apple-icon-180x180.png": "67bddcf915ee8f197b70477ebf53dcea",
"ms-icon-70x70.png": "b534289d21bcfadc1c0cc4bca2a69344",
"apple-icon-60x60.png": "538294b9b14d98bd76f4f2af158b980c",
"apple-icon-57x57.png": "b5ef31eb414e811b4898dd5f78417781",
"assets/assets/fonts/visuelt/VisueltPro-Thin.ttf": "82d7b5b67c24f00acb08f2dccf1fd03b",
"assets/assets/fonts/visuelt/VisueltPro-Regular.ttf": "0f8cd2494eb8c5e3a33352b2dd38fd61",
"assets/assets/fonts/visuelt/VisueltPro-Bold.ttf": "18acd33c965a455418d4204f0f334ea8",
"assets/assets/fonts/visuelt/VisueltPro-Light.ttf": "2a1df2ff00c2611bf1b7fdeeaeebfa59",
"assets/assets/fonts/visuelt/VisueltPro-ExtraLight.ttf": "90bfa0766e43260710e3c6ac0f78c9e9",
"assets/assets/fonts/visuelt/VisueltPro-Black.ttf": "691b6f9aa3ee625e3cd8da2f8849a126",
"assets/assets/fonts/visuelt/VisueltPro-Medium.ttf": "cf4dbc20776a2b309fe30a9bbfe7de0a",
"assets/assets/images/google_play.png": "7c42f3803d546db3d393106501dba541",
"assets/assets/images/works.png": "5c6f8eb3a22f703781aad6c2528cf0cd",
"assets/assets/images/caesar.png": "c2bf68cb3b24b5361c95d04c445511a8",
"assets/assets/images/right-arrow.png": "62a7bab73a0fe40acd3f4555adfcab91",
"assets/assets/images/down-arrow.png": "4393cd5feeb20fb468c7eb223d1bbd06",
"assets/assets/images/ios-down-arrow.png": "fa4679d2972f1d11355142a60ed34ede",
"assets/assets/images/piano.jpg": "b40e37fde428618abbc365fb883c71f9",
"assets/assets/images/circle.png": "663d5187ada8666bfa87120d1665605f",
"assets/assets/images/projects/foodybite/foodybite_typography.png": "af6e1b156ad00cfb382824b30ba38a35",
"assets/assets/images/projects/foodybite/foodybite_starting_flow.png": "77c7833485f0a71c95e3a74f3f01b7c4",
"assets/assets/images/projects/foodybite/foodybite_review_favorite_notifications_flow.png": "e80ce1073e823a2fc83ddbf1515794f7",
"assets/assets/images/projects/foodybite/foodybite_home.png": "831c86f2e1dd6fa238acd532e41b3607",
"assets/assets/images/projects/foodybite/foodybite_cover.png": "969daa4932408c630eb26f795cd84840",
"assets/assets/images/projects/foodybite/foodybite_home_flow.png": "f144497bae302b17e440392f547410e7",
"assets/assets/images/projects/otp_package/otp_cover.png": "6fc7ff3a9d1b6d8cbb81348c8f2df184",
"assets/assets/images/projects/outfitr/outfitr_4.jpeg": "4f45a2d1f2735a813f9e3ce4ca83f351",
"assets/assets/images/projects/outfitr/outfitr_cover.jpg": "73c49501f831207eb63ca115c5b1dd31",
"assets/assets/images/projects/outfitr/outfitr_6.jpeg": "8a986255dfcd301d00891cf0a6288df8",
"assets/assets/images/projects/outfitr/outfitr_2.jpeg": "b5c6638904552202a14d3d65f6d69116",
"assets/assets/images/projects/outfitr/outfitr_5.jpeg": "32317c7e7d7bf50c3ca110d6d393e670",
"assets/assets/images/projects/outfitr/outfitr_1.jpeg": "5a72c14039670e01bcbfaccbff889551",
"assets/assets/images/projects/disneyplus/disneyplus_the_end.png": "32e658209ce45e9227860a8c0fbf1b54",
"assets/assets/images/projects/disneyplus/disneyplus_components.png": "74d9e2263cebd38337ac2ae9d2f23b16",
"assets/assets/images/projects/disneyplus/disneyplus_great_menu.png": "d13b01ee672be2e3e884fe866db90359",
"assets/assets/images/projects/disneyplus/disneyplus_designs.png": "084289a49e4ec07af37d41eb0b919123",
"assets/assets/images/projects/disneyplus/disneyplus_description.png": "f049e03a0d786b44d57f80e702f10a5c",
"assets/assets/images/projects/disneyplus/disneyplus_downloads_feature.png": "3bb3d18e2b7af7b62e3bc90a8deed037",
"assets/assets/images/projects/disneyplus/mockups.png": "bfec31223be46e6c269d8bc71f3f707e",
"assets/assets/images/projects/disneyplus/disneyplus_mockups.png": "ec3d2333044bc2622030e38eb84a1b90",
"assets/assets/images/projects/disneyplus/disneyplus_home.png": "7c3f46edc91974a22db6ecab11e49cbd",
"assets/assets/images/projects/disneyplus/disneyplus_cover.png": "ffa11a0c8f114e0a24b31bb1790f2ef8",
"assets/assets/images/projects/disneyplus/disneyplus_theme.png": "b4a28335035d4b169f1033313801fcc5",
"assets/assets/images/projects/disneyplus/disneyplus_header.png": "1ef584f42c10fd2f994f44e35d281751",
"assets/assets/images/projects/disneyplus/disneyplus_more_description.png": "54c40930e0035fee095cc5f26e09e8d4",
"assets/assets/images/projects/disneyplus/disneyplus_profiles.png": "ee5c8f987396dbb6157911982b9e983d",
"assets/assets/images/projects/aerium-v1/portfolio_cover.png": "44d787594b26ade2562489ced20d9914",
"assets/assets/images/projects/aerium-v1/portfolio_design_2.png": "415b12138860ce60055b3ce39e517fde",
"assets/assets/images/projects/aerium-v1/portfolio_design_3.png": "4b8a024161c0d3f30b858ac60b9286d0",
"assets/assets/images/projects/aerium-v2/first.jpg": "d7a4be69fcea5718ce8fdaa844ce0988",
"assets/assets/images/projects/aerium-v2/typography.jpg": "e16664ace87aa12b2266e6f8127ca05f",
"assets/assets/images/projects/aerium-v2/last.jpg": "ee1b6eee2d5df5a5bfdcb686266b75a0",
"assets/assets/images/projects/aerium-v2/aerium_v2.jpg": "33ec4d62fe74fb6ee3b01301f92ceb9c",
"assets/assets/images/projects/aerium-v2/overall.jpg": "f114c609432d9115658f5477900f66a7",
"assets/assets/images/projects/flutter_catalog/screens.png": "f384d904e19edcdf3b83ac9fab4a2514",
"assets/assets/images/projects/flutter_catalog/thanks.png": "f23385476a0df7db049d7b8f94714706",
"assets/assets/images/projects/flutter_catalog/activities.png": "56b8a82f91b3bb17fc2da735be8309e2",
"assets/assets/images/projects/flutter_catalog/typography.png": "b12b17f85e8e12bd2ccab08e987c640c",
"assets/assets/images/projects/flutter_catalog/stats.png": "c6c5da388e4771644e3a0057737cc018",
"assets/assets/images/projects/flutter_catalog/flutter_catalog_cover.png": "529c018ceb7db5d85e0bba13a4cd19c3",
"assets/assets/images/projects/flutter_catalog/onboarding.png": "78cd62661bd65bca48016781ec5af76d",
"assets/assets/images/projects/drop/drop_cover.png": "c50dd8fc206812051747e58cf5a8b345",
"assets/assets/images/projects/drop/drop_description.gif": "7a0eede4ed79d2468eeaec6d30347b3c",
"assets/assets/images/projects/drop/drop_wireframes.gif": "155af5f6c5def746328626cfce09c163",
"assets/assets/images/projects/drop/drop_simple.png": "c4c00ba6b1933a304067dda102a922dd",
"assets/assets/images/projects/drop/drop_thanks.gif": "7f63f39ed7c894ee6e0755f77a39afb5",
"assets/assets/images/projects/drop/drop_minimal_design.png": "06c3434542050151428b3f66a0193244",
"assets/assets/images/projects/drop/drop_flowchart.png": "6601108c834215bb982c5fa49f586591",
"assets/assets/images/projects/drop/drop_easy_access.gif": "7657c8f99a7a3a405cb71cb1f4bee892",
"assets/assets/images/projects/nimbus/nimbus_cover.jpg": "454409edbf32cc8432d70c69155a6016",
"assets/assets/images/projects/nimbus/nimbus.jpg": "9f925a888c2ff02c9f1206f99c2b155d",
"assets/assets/images/projects/login_catalog/login9.png": "4eb5737139e26eb31c1bea5e6e2c0a6b",
"assets/assets/images/projects/login_catalog/login_catalog_cover.jpg": "8142a609044c0f5b26df2964fe9304c4",
"assets/assets/images/projects/login_catalog/login4.png": "f5eb46c00b1ad99b48dc75648ae232c0",
"assets/assets/images/projects/login_catalog/login8.png": "2bf8b3ab8d940dfb5c48069195c2d039",
"assets/assets/images/projects/login_catalog/login5.png": "bafb620a4388df5ef86cff21ef895491",
"assets/assets/images/projects/login_catalog/login7.jpeg": "34412e31d874c3147f29d3bc522efbd2",
"assets/assets/images/projects/roam/roam_explore.jpeg": "545a73fcfd824fdc7aa66ec3b5601cf8",
"assets/assets/images/projects/roam/wireframes_app.jpeg": "2fba25598d725ec44a6b828448535e3a",
"assets/assets/images/projects/roam/roam_overall.jpeg": "5c76cf22ede0a7955733f39d4439a055",
"assets/assets/images/projects/roam/wireframes_onboarding.jpeg": "0793bcaad704dc77c2115eca32ec488b",
"assets/assets/images/projects/roam/roam_home.jpeg": "9bcacb5453047dca89cf69352742765f",
"assets/assets/images/projects/roam/roam_onboarding.jpeg": "d6f2a2c09df8af0fc8708db8bd3c9a93",
"assets/assets/images/projects/roam/roam_flow_chart.png": "50aa1d22e98a682fb24ad8beca7f306f",
"assets/assets/images/projects/roam/roam_profile.jpeg": "3351fb0171a75f53d2974e20e586db86",
"assets/assets/images/projects/roam/wireframes_signup_login.jpeg": "3f9c2d5af711cbc401036749fca0ec76",
"assets/assets/images/projects/roam/roam_cover.jpeg": "a67b0ed338d81feb4cf60955c3a821b2",
"assets/assets/images/down-arrow-2.png": "de203dedb01f2871b4ebbec490c20a6c",
"assets/assets/images/up-arrow.png": "d0c6457f5704962b99f0e6aa3e9b18e7",
"assets/fonts/MaterialIcons-Regular.otf": "e5882d14f52144f8162a0bc557718bb3",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "d7791ef376c159f302b8ad90a748d2ab",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "658b490c9da97710b01bd0f8825fce94",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "5070443340d1d8cceb516d02c3d6dee7",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "57d849d738900cfd590e9adc7e208250",
"assets/packages/flutter_feather_icons/fonts/feather.ttf": "a2bbdbf8ee3e7b49dc5c43e73e125ec0",
"assets/FontManifest.json": "a78f950d25c1e29b92a4a309465e60cd",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"assets/NOTICES": "d3a4a340168c9ea2faeef247a6c5cdb6",
"assets/AssetManifest.bin": "0ff9d4c7de739a78eee3f245464881ba",
"assets/AssetManifest.json": "68e685eacf0d0b1054bb1701669977e5",
".git/logs/refs/heads/main": "6eda4938b16839e16b9ac4dde5e82756",
".git/logs/refs/remotes/origin/main": "5f2c6473c18f5a981a97af9b3ea6aa00",
".git/logs/refs/remotes/origin/HEAD": "91a55ad5c35da0c022493a67d96a5652",
".git/logs/HEAD": "6eda4938b16839e16b9ac4dde5e82756",
".git/FETCH_HEAD": "ecd7578dcd4b73b554d3377ee531bc09",
".git/objects/4e/08f4f46c88b163ed3e16f5d54d138da0d9c7d8": "aa8befede7dcebb185d6f518b8435e34",
".git/objects/77/6fce4eba3bf45de6df5529d700e386c7643d6f": "05ab634aea5fae809548440b33634f40",
".git/objects/9d/646d9bb6032073991359392f080671edcb2531": "f56d6e4cd64e47fa194f8d198e04f000",
".git/objects/9d/d0d5bc649df8cdbb054e97278891c039ae19c6": "251c05a23a7bc10950b119feb5208102",
".git/objects/51/c37f5c4f71a9713db3f42122dcdb0bf55aee73": "01861298f3fe59d314e729211ddc8c88",
".git/objects/4a/14f5b3dbb8dba601f3f6444b8bd0ebdd47e4fb": "340e15e6dbc23bebb1b88a8cae705277",
".git/objects/af/30a1488e90bd3f8bb6afd4738d778d2a2f8a01": "e2e2b62ae9ce285664e4b552908a5d3b",
".git/objects/ea/83e50d485bc0587118fdeeb7248eb58b5a1f97": "c7adbae63c9f702c14c311254a0503cf",
".git/objects/3e/859fa3212746169ac3b4381ff8b1c967d2c3fe": "65d9c7ceaed673978e3d47ef1886d07a",
".git/objects/aa/e429e03796cec5c9aa7ced5c2bd05e29b6f7dc": "1ebc7bc32514ae404e20754a85f842e1",
".git/objects/2a/d114fefc90edfda6a1db171172064499aae6f6": "ccff9c736dfb547c4d603d4d138b4287",
".git/objects/ff/638b3876748e63b9f67cff017339cc6b2349f8": "afb16ec332968483da4128b3b7b40a2f",
".git/objects/3a/26702b755e2654d9c39688745461ff071587eb": "eb8dfdd2a9b681d3ca07dd7e7e551a97",
".git/objects/3a/e27625493cc5791e4071f652e65c7e9218b670": "d4dcad8d485606dc03241771c7676499",
".git/objects/c9/c2a52f74fc5ef27b5001532633941cfc19e37e": "71894b142e486fc8cf625328843d51d7",
".git/objects/5f/ba606b7825903a652948ecc3ef3062f37f2cdb": "e8192281c4bd48a314ec855fa2d8a6fc",
".git/objects/5f/8a4647b4a56995f2e4fbfee41bcd1271350ee1": "98bb08f17eca18bce52814f566707b62",
".git/objects/16/1fca7f2d2a126955a661f1b97717a186d90fcd": "fbb7cf0810a9ff7dc5cfd13516af7973",
".git/objects/cb/4d2fa06df1bd41198e43b629f352a445b264c9": "169826cbcae91e2d6e4bb8ee1874f877",
".git/objects/1f/686edd1465272558af328ca43cb7189a0059e6": "5e83820f6d3e5392693d45bc239b2b61",
".git/objects/cd/a136c86118db610bbda352d84d42056e597416": "ce6d6d8dee6895ba270b6cb0654c009c",
".git/objects/65/1e5411a739b25b40f71417d8ac4c6f9cb188d5": "bec88aa041f5219e5e283256a9e57a8c",
".git/objects/02/24c1d89523c2ff11225ea6c9f98335db0227b4": "3850046015fddff568c854c18d5469bf",
".git/objects/db/8271f3d1f0ec182bb6a32e7bde73c7656d0e55": "8d65706083355216a213389158b69220",
".git/objects/b5/25e7fe2730fd121e23b602cc58aa227b159f1c": "0be369883f219a089003e06cfa68beab",
".git/objects/07/03f0954725336c560d05e804fbace53ef2f4ff": "176a9c3cf98e36e03f97da6ff7af6b2c",
".git/objects/44/f3fb7195b6a0647c41afb28ef5884f1663022a": "ea0853871aadeead0a5d6838f002e1e5",
".git/objects/d9/b332cb5b6835dd5614ef83eb89f8eace5d76c4": "62c1064f19c208bedf2b140ea1259bb7",
".git/objects/d9/9e436148b8add8b5f81d529c8f22c4d1f9f36d": "9c64c7a6fbbdb41d2f128bf30a1c0bfa",
".git/objects/59/7d38c67ba8a00d1c3ad88c8950d59cff2cfaba": "38971d9e9ecb36b3c96e2b0b0d408651",
".git/objects/34/f0d5663d04079b3976ae0e0ed3d19dd5010c33": "e27a0405d505d880b8ab47fed8973a02",
".git/objects/cc/ae527686eaaeb5634df0a36e957513833cf494": "e88504805de3bf6fa0750509ca0882d3",
".git/objects/f4/2c2d971e6064583222357a41382a4d0b4e5f39": "8bcb3f952772411cea170f8e831364a0",
".git/objects/7b/4b8c1e963378465dfaf3f88943845c178f2789": "89ed4e28955d66785e8108d472892183",
".git/objects/72/9aa8f8a012da97cba40231d45a67fc33d58270": "56d837dbd43b868896c2c0b8ff69fa54",
".git/objects/90/2d839ccb5ec6fe516ad30aa06f1d8c41f20df0": "22b9c1058794fa38ec17a6b5265e0243",
".git/objects/fd/6cc4d9f4e04feb7c5492d05f29d0b7db0d84d7": "05ad72b00078bd3e7123e70127b863b7",
".git/objects/pack/pack-54a82192b504ad25535498b269e6692468ef568b.idx": "59a34bc28289c2dd10e863713e2a1dc0",
".git/objects/pack/pack-54a82192b504ad25535498b269e6692468ef568b.pack": "0fdbbd686bdabe4f3967d7848aa872c5",
".git/objects/ba/4fe7b2d0040d8f844beff8fb134bcf10f7e670": "3f4c5aa11a7e991b55656cf3fdc77f5b",
".git/objects/08/66d1a4199a35a57b788dbf170e1747c1c8bfe1": "3e2e8bbac8f20c0482e246a27d4190e9",
".git/objects/ab/818923f833377d1286d2eb296ba2e8880bb231": "d0a9da193b1b74ba5fecb610480558b6",
".git/objects/ab/fd1d05c3e35abbc617ee23f246854cd7a7213e": "43bf39361c8c6654d3ac498e639c129d",
".git/objects/53/8e59cf232f2ae7d1563a75cbf8b186e30a869e": "dbcc20cbd49d27f9aef595c16511cc80",
".git/objects/2d/ef71c840c0a9beadf626cdf283ccd3d168ba92": "673936f769b408f0a4f5fa47b3739930",
".git/objects/fc/0e61b19a45a93bb3efb9320f8448163c1b122c": "60869b73315e150029a0d39356bd7130",
".git/objects/9f/456ff18291d2771d1ad7cfbc9e722bc6697402": "b5431fdcf38209637236b6c4b52e17e5",
".git/objects/49/2239ba85bf2ace8793cd5a1dec79833b741f89": "bc1123e5b508bc873638793b11a19a74",
".git/objects/7a/e8bde4db9d09b67b384631b009b0c27aa00f90": "ce9c518edb53f860245212f25590b6a2",
".git/objects/67/9554c72212ccea6e87addabae79a1b763a4057": "03c375e9796a9d3e00abd8be5b41e19f",
".git/objects/24/5d175fabda993dd65cf4dbf422d3c8f6d614ab": "fdbf312302d772dbd32f1e9168ba48a6",
".git/objects/fe/68598937b9370900493c4607ad62567cc32995": "cc773fd61d282585890ea1f2d927b111",
".git/objects/f7/ae4d9403821e889dd77b67e52f76e4892925ec": "f4d8f323f0e93cfc90a20c6e035abaaf",
".git/objects/f7/f3833d9a47b7c774e7ba2088c62cc1be73f2e1": "00823545fa0bde0a7adb45804c97077b",
".git/objects/bb/e0f0df5ae7006446f09fb756454b26ce6a5303": "f35c36b5208bbede1996f8d446eae397",
".git/objects/2c/1ebc8916ebbeb386d97247d86c9271007c7607": "7ec82db2cd3869514b292533a0876393",
".git/objects/80/8048fafc59314b96ba795255708523203952a9": "05a3598bfe2ceab39aba2d651f801f55",
".git/objects/80/870c1f71039d2d852acbcab9b12c8f944ad369": "522c8ab959798835652f35a032fe3d86",
".git/objects/12/648eb2bf4565e4d997465ff6d9065101e08a09": "d1b1a21bff93a8b5d36658552088b97d",
".git/objects/83/7381c77c64e2f06c5825f98361b5c06db4845f": "af7597e705c1c14e240807bee5c373f5",
".git/objects/83/c281656672b36b74cc07cfc37f446e628dcfc9": "7f998025fa208010decf6a4d0b255d5b",
".git/objects/d3/c3d650fbc67de6f44d92298295ed4973d27f8d": "c16cc9e36eec7799fbaf9242e528b9bd",
".git/objects/dd/0166532faea47699f9d84478cf9b8873fecc89": "ac4fa416bd6573afc5acf08435557904",
".git/objects/96/3199d1645321edc97ee556eab7ea4a37ac7514": "75220096db885329911763bf12557644",
".git/index": "75368a819d41231fe2da5fd7f648e6b5",
".git/packed-refs": "773833e83e03bb9cc9dba2ceccbb0e93",
".git/refs/heads/main": "3c379aa0c900c9ea0c0e7f3a38675fa9",
".git/refs/remotes/origin/main": "3c379aa0c900c9ea0c0e7f3a38675fa9",
".git/refs/remotes/origin/HEAD": "98b16e0b650190870f1b40bc8f4aec4e",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/COMMIT_EDITMSG": "8cd2be1dda6eb2a1d54e1adbbbee81eb",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/config": "a32b75359bc8c03c67396f6af2ebacba",
"apple-icon-76x76.png": "8b6bc7cbc55eec00ef45a89ccbef5090",
"favicon.png": "b1e6e19cafa905308746bf2b29652cb7",
"main.dart.js": "ed553c816cedb55f1f9b55d17490d7ba",
"favicon-96x96.png": "14069518c7f4d0ead1e9d7d97c2bf210",
"favicon.ico": "d92da94026ef14b2470fc77e2df1767e",
"apple-icon-152x152.png": "cfb852814c77351c9a8e27743c525f5d",
"apple-icon-144x144.png": "d6922517e4760d2e17b75e5114efb2b9",
"apple-icon-precomposed.png": "869b1c354f0c580baedf511d46cd20d5",
"canvaskit/skwasm.js": "1df4d741f441fa1a4d10530ced463ef8",
"canvaskit/canvaskit.js": "76f7d822f42397160c5dfc69cbc9b2de",
"canvaskit/canvaskit.wasm": "f48eaf57cada79163ec6dec7929486ea",
"canvaskit/skwasm.wasm": "6711032e17bf49924b2b001cef0d3ea3",
"canvaskit/chromium/canvaskit.js": "8c8392ce4a4364cbb240aa09b5652e05",
"canvaskit/chromium/canvaskit.wasm": "fc18c3010856029414b70cae1afc5cd9",
"canvaskit/skwasm.worker.js": "19659053a277272607529ef87acf9d8a",
"apple-icon.png": "869b1c354f0c580baedf511d46cd20d5",
"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"index.html": "4d4c3267cf5edf351e89899bf5ab0213",
"/": "4d4c3267cf5edf351e89899bf5ab0213",
"ms-icon-144x144.png": "d6922517e4760d2e17b75e5114efb2b9",
"ms-icon-150x150.png": "922c023f6bfc6475abca02b0c9d69d16",
"ms-icon-310x310.png": "3df630d318acff6815630dd093df9e8f",
"manifest.json": "c22239d777022c8da38cfd274970f3fa",
"version.json": "746f1839bec6d90312d913e74a6ff2c4",
"favicon-16x16.png": "4b1cb3e295a3c89edaed9615e612ed2a",
"icons/android-icon-96x96.png": "14069518c7f4d0ead1e9d7d97c2bf210",
"icons/android-icon-144x144.png": "d6922517e4760d2e17b75e5114efb2b9",
"icons/android-icon-36x36.png": "0f5f99d87f8feb65b912ac3437a800b7",
"icons/android-icon-192x192.png": "950701d52f9d14cb902fc2f1b0e511ac",
"icons/android-icon-48x48.png": "e69d1303a06560441b0bd5d03a3fce05",
"icons/android-icon-72x72.png": "91c3b0b3f58f3276c6d776e836e8a2c4",
"favicon-32x32.png": "b1e6e19cafa905308746bf2b29652cb7"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
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
