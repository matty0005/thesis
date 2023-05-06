-- The NEORV32 RISC-V Processor: https://github.com/stnolting/neorv32
-- Auto-generated memory initialization file (for BOOTLOADER) from source file <bootloader/main.bin>
-- Size: 4020 bytes
-- MARCH: default
-- Built: 06.05.2023 17:21:35

-- prototype defined in 'neorv32_package.vhd'
package body neorv32_bootloader_image is

constant bootloader_init_image : mem32_t := (
x"30005073",
x"30401073",
x"00000097",
x"0e008093",
x"30509073",
x"80010117",
x"1e810113",
x"80010197",
x"7e418193",
x"00000213",
x"00000293",
x"00000313",
x"00000393",
x"00000413",
x"00000493",
x"00000813",
x"00000893",
x"00000913",
x"00000993",
x"00000a13",
x"00000a93",
x"00000b13",
x"00000b93",
x"00000c13",
x"00000c93",
x"00000d13",
x"00000d93",
x"00000e13",
x"00000e93",
x"00000f13",
x"00000f93",
x"00001597",
x"f3858593",
x"80010617",
x"f7c60613",
x"80010697",
x"f7468693",
x"00c58e63",
x"00d65c63",
x"0005a703",
x"00e62023",
x"00458593",
x"00460613",
x"fedff06f",
x"80010717",
x"f5070713",
x"80818793",
x"00f75863",
x"00072023",
x"00470713",
x"ff5ff06f",
x"00000513",
x"00000593",
x"060000ef",
x"30401073",
x"34051073",
x"10500073",
x"ffdff06f",
x"ff810113",
x"00812023",
x"00912223",
x"34202473",
x"02044663",
x"34102473",
x"00041483",
x"0034f493",
x"00240413",
x"34141073",
x"00300413",
x"00941863",
x"34102473",
x"00240413",
x"34141073",
x"00012403",
x"00412483",
x"00810113",
x"30200073",
x"fb010113",
x"04912223",
x"800004b7",
x"0004a223",
x"800007b7",
x"0007a023",
x"ffff17b7",
x"04112623",
x"04812423",
x"05212023",
x"03312e23",
x"03412c23",
x"03512a23",
x"03612823",
x"03712623",
x"03812423",
x"03912223",
x"03a12023",
x"01b12e23",
x"a1c78793",
x"30579073",
x"fe802783",
x"00080737",
x"00e7f7b3",
x"00078863",
x"fa002423",
x"10100793",
x"faf02423",
x"fe802783",
x"40000737",
x"00e7f7b3",
x"06078863",
x"f4002023",
x"f4002423",
x"000067b7",
x"f4002623",
x"20578793",
x"f4f02023",
x"f4002423",
x"f4002623",
x"f4002783",
x"00e7f7b3",
x"fe079ce3",
x"f4002783",
x"02000737",
x"00e7e7b3",
x"f4f02023",
x"f4002783",
x"08000737",
x"00e7e7b3",
x"f4f02023",
x"f4002783",
x"fe1fe737",
x"43f70713",
x"00e7f7b3",
x"00801737",
x"60070713",
x"00e7e7b3",
x"f4f02023",
x"fe802783",
x"00010737",
x"00e7f7b3",
x"00078863",
x"00100793",
x"fcf02423",
x"fc002623",
x"fa002023",
x"fe002683",
x"00232737",
x"ffdce637",
x"00000793",
x"7ff70713",
x"80060613",
x"00d76a63",
x"3fe00713",
x"00f76c63",
x"00000713",
x"0180006f",
x"00c686b3",
x"00178793",
x"fe5ff06f",
x"0017d793",
x"00100713",
x"fff78793",
x"000106b7",
x"00679793",
x"fff68693",
x"00371713",
x"00d7f7b3",
x"00e7e7b3",
x"0017e793",
x"faf02023",
x"fe802783",
x"00020737",
x"00e7f7b3",
x"02078663",
x"f8002823",
x"f8002a23",
x"fe002783",
x"0027d793",
x"f8f02c23",
x"f8002e23",
x"08000793",
x"30479073",
x"00800793",
x"3007a073",
x"ffff1537",
x"dac50513",
x"684000ef",
x"f1302573",
x"608000ef",
x"ffff1537",
x"de450513",
x"670000ef",
x"fe402503",
x"5f4000ef",
x"ffff1537",
x"dec50513",
x"65c000ef",
x"fe002503",
x"5e0000ef",
x"ffff1537",
x"df450513",
x"648000ef",
x"30102573",
x"5cc000ef",
x"ffff1537",
x"dfc50513",
x"634000ef",
x"fc002573",
x"5b8000ef",
x"ffff1537",
x"e0450513",
x"620000ef",
x"fe802503",
x"ffff1437",
x"ffff1937",
x"59c000ef",
x"ffff1537",
x"e0c50513",
x"604000ef",
x"ff802503",
x"588000ef",
x"e1440513",
x"5f4000ef",
x"ff002503",
x"578000ef",
x"ffff1537",
x"e2050513",
x"5e0000ef",
x"ffc02503",
x"564000ef",
x"e1440513",
x"5d0000ef",
x"ff402503",
x"554000ef",
x"da890513",
x"5c0000ef",
x"fe802783",
x"00020737",
x"00e7f7b3",
x"04078c63",
x"ffff1537",
x"e2850513",
x"5a4000ef",
x"290000ef",
x"fe002403",
x"00040a37",
x"00010ab7",
x"00341413",
x"00a409b3",
x"0089b433",
x"00b40433",
x"fe802783",
x"0147f7b3",
x"08078063",
x"fa002783",
x"0157f7b3",
x"06078a63",
x"ffff1537",
x"fa402783",
x"e5450513",
x"55c000ef",
x"ffff1a37",
x"e60a0513",
x"550000ef",
x"06c00a93",
x"07800b93",
x"07300c13",
x"06500c93",
x"ffff17b7",
x"ee078513",
x"534000ef",
x"fa002783",
x"00010737",
x"00e7f7b3",
x"fe078ae3",
x"fa402403",
x"0ff47413",
x"00040513",
x"488000ef",
x"da890513",
x"50c000ef",
x"07200793",
x"02f41a63",
x"ffff02b7",
x"00028067",
x"1e8000ef",
x"f685eae3",
x"00b41463",
x"f73566e3",
x"00100513",
x"718000ef",
x"da890513",
x"4dc000ef",
x"00000513",
x"069000ef",
x"19540863",
x"028ae463",
x"19940863",
x"06800793",
x"e60a0513",
x"02f40c63",
x"03f00793",
x"18f40c63",
x"ffff1537",
x"f8450513",
x"0240006f",
x"07500793",
x"02f40263",
x"17740c63",
x"ff8414e3",
x"0044a403",
x"02041063",
x"ffff1537",
x"ee850513",
x"484000ef",
x"f45ff06f",
x"00000513",
x"6ac000ef",
x"f39ff06f",
x"ffff1537",
x"f0450513",
x"468000ef",
x"00040513",
x"3ec000ef",
x"ffff1537",
x"f0c50513",
x"454000ef",
x"00400537",
x"3d8000ef",
x"ffff1537",
x"f2450513",
x"440000ef",
x"00010737",
x"fa002783",
x"00e7f7b3",
x"fe078ce3",
x"fa402983",
x"0ff9f993",
x"00098513",
x"394000ef",
x"07900793",
x"ecf99ee3",
x"2a0000ef",
x"00050663",
x"00300513",
x"460000ef",
x"ffff1537",
x"f3050513",
x"3fc000ef",
x"01045b13",
x"004009b7",
x"00010db7",
x"fff00d13",
x"220000ef",
x"150000ef",
x"0d800513",
x"0f4000ef",
x"00098513",
x"104000ef",
x"0d4000ef",
x"224000ef",
x"00157513",
x"fe051ce3",
x"fffb0b13",
x"01b989b3",
x"fdab18e3",
x"ff002683",
x"004009b7",
x"00000d13",
x"00000d93",
x"00c98793",
x"00dd0733",
x"00072583",
x"00fd0533",
x"00d12623",
x"00bd8db3",
x"26c000ef",
x"004007b7",
x"004d0d13",
x"00c12683",
x"00c78793",
x"fc8d6ce3",
x"4788d5b7",
x"afe58593",
x"00400537",
x"248000ef",
x"00040593",
x"00498513",
x"23c000ef",
x"00898513",
x"41b005b3",
x"230000ef",
x"ffff1537",
x"d9050513",
x"ec1ff06f",
x"00100513",
x"ec5ff06f",
x"0044a783",
x"e4079ee3",
x"ffff1537",
x"f4050513",
x"ea5ff06f",
x"00100513",
x"e4dff06f",
x"ffff1537",
x"f5050513",
x"e91ff06f",
x"f9402583",
x"f9002503",
x"f9402783",
x"fef59ae3",
x"00008067",
x"fa800713",
x"00072783",
x"fbf7f793",
x"00f72023",
x"00008067",
x"faa02623",
x"fa802783",
x"fe07cee3",
x"fac02503",
x"0ff57513",
x"00008067",
x"ff010113",
x"00812423",
x"00050413",
x"01055513",
x"0ff57513",
x"00112623",
x"fd1ff0ef",
x"00845513",
x"0ff57513",
x"fc5ff0ef",
x"0ff47513",
x"00812403",
x"00c12083",
x"01010113",
x"fb1ff06f",
x"fa800713",
x"00072783",
x"f877f793",
x"0407e793",
x"00f72023",
x"00008067",
x"fd010113",
x"02912223",
x"03212023",
x"01312e23",
x"01412c23",
x"01512a23",
x"02112623",
x"02812423",
x"00050913",
x"00058993",
x"00000493",
x"00010ab7",
x"00400a13",
x"04091a63",
x"fa002783",
x"0157f7b3",
x"fe078ce3",
x"fa402403",
x"0ff47413",
x"00c10793",
x"009787b3",
x"00878023",
x"00148493",
x"fd449ce3",
x"02c12083",
x"02812403",
x"00c12503",
x"02412483",
x"02012903",
x"01c12983",
x"01812a03",
x"01412a83",
x"03010113",
x"00008067",
x"f61ff0ef",
x"00300513",
x"00998433",
x"f01ff0ef",
x"00040513",
x"f11ff0ef",
x"00000513",
x"ef1ff0ef",
x"00050413",
x"ed5ff0ef",
x"f9dff06f",
x"ff010113",
x"00112623",
x"f2dff0ef",
x"00600513",
x"ed1ff0ef",
x"00c12083",
x"01010113",
x"eb1ff06f",
x"fe010113",
x"00112e23",
x"f0dff0ef",
x"00500513",
x"eb1ff0ef",
x"00000513",
x"ea9ff0ef",
x"00a12623",
x"e8dff0ef",
x"01c12083",
x"00c12503",
x"02010113",
x"00008067",
x"ff010113",
x"00112623",
x"ed9ff0ef",
x"0ab00513",
x"e7dff0ef",
x"e65ff0ef",
x"f95ff0ef",
x"fb1ff0ef",
x"00257793",
x"fff00513",
x"02078063",
x"eb5ff0ef",
x"00400513",
x"e59ff0ef",
x"e41ff0ef",
x"f91ff0ef",
x"01e51513",
x"41f55513",
x"00c12083",
x"01010113",
x"00008067",
x"fd010113",
x"02812423",
x"02912223",
x"01312e23",
x"02112623",
x"03212023",
x"01412c23",
x"00050493",
x"00b12623",
x"00000413",
x"00400993",
x"00c10793",
x"008787b3",
x"0007ca03",
x"f21ff0ef",
x"e51ff0ef",
x"00200513",
x"df5ff0ef",
x"00848933",
x"00090513",
x"e01ff0ef",
x"000a0513",
x"de1ff0ef",
x"dc9ff0ef",
x"f19ff0ef",
x"00157513",
x"fe051ce3",
x"00140413",
x"fb341ee3",
x"02c12083",
x"02812403",
x"02412483",
x"02012903",
x"01c12983",
x"01812a03",
x"03010113",
x"00008067",
x"00200737",
x"fa002783",
x"00e7f7b3",
x"fe079ce3",
x"faa02223",
x"00008067",
x"fe010113",
x"01212823",
x"00050913",
x"03000513",
x"00112e23",
x"00812c23",
x"00912a23",
x"01312623",
x"fc9ff0ef",
x"07800513",
x"ffff14b7",
x"fbdff0ef",
x"01c00413",
x"f9048493",
x"ffc00993",
x"008957b3",
x"00f7f793",
x"00f487b3",
x"0007c503",
x"ffc40413",
x"f99ff0ef",
x"ff3414e3",
x"01c12083",
x"01812403",
x"01412483",
x"01012903",
x"00c12983",
x"02010113",
x"00008067",
x"ff010113",
x"00812423",
x"01212023",
x"00112623",
x"00912223",
x"00050413",
x"00a00913",
x"00044483",
x"00140413",
x"00049e63",
x"00c12083",
x"00812403",
x"00412483",
x"00012903",
x"01010113",
x"00008067",
x"01249663",
x"00d00513",
x"f2dff0ef",
x"00048513",
x"f25ff0ef",
x"fc9ff06f",
x"ff010113",
x"00812423",
x"00050413",
x"ffff1537",
x"d4850513",
x"00112623",
x"f91ff0ef",
x"00241793",
x"ffff1537",
x"008787b3",
x"fa050513",
x"00f50533",
x"f79ff0ef",
x"00800793",
x"3007b073",
x"fe802783",
x"00010737",
x"00e7f7b3",
x"00078863",
x"00100793",
x"fcf02423",
x"fc002623",
x"0000006f",
x"fb010113",
x"04112623",
x"04512423",
x"04612223",
x"04712023",
x"02812e23",
x"02912c23",
x"02a12a23",
x"02b12823",
x"02c12623",
x"02d12423",
x"02e12223",
x"02f12023",
x"01012e23",
x"01112c23",
x"01c12a23",
x"01d12823",
x"01e12623",
x"01f12423",
x"342024f3",
x"800007b7",
x"00778793",
x"0af49663",
x"fe802783",
x"00010737",
x"00e7f7b3",
x"00078863",
x"fc802783",
x"0017c793",
x"fcf02423",
x"fe802783",
x"00020737",
x"00e7f7b3",
x"02078863",
x"bb5ff0ef",
x"fe002783",
x"fff00713",
x"f8e02c23",
x"0027d793",
x"00a78533",
x"00f537b3",
x"00b787b3",
x"f8f02e23",
x"f8a02c23",
x"00000013",
x"03c12403",
x"04c12083",
x"04812283",
x"04412303",
x"04012383",
x"03812483",
x"03412503",
x"03012583",
x"02c12603",
x"02812683",
x"02412703",
x"02012783",
x"01c12803",
x"01812883",
x"01412e03",
x"01012e83",
x"00c12f03",
x"00812f83",
x"05010113",
x"30200073",
x"00700793",
x"00f49c63",
x"800007b7",
x"0007a783",
x"00078663",
x"00100513",
x"e89ff0ef",
x"34102473",
x"fe802783",
x"00040737",
x"00e7f7b3",
x"04078263",
x"ffff1537",
x"d5050513",
x"e11ff0ef",
x"00048513",
x"d95ff0ef",
x"02000513",
x"d75ff0ef",
x"00040513",
x"d85ff0ef",
x"02000513",
x"d65ff0ef",
x"34302573",
x"d75ff0ef",
x"ffff1537",
x"da850513",
x"dddff0ef",
x"00440413",
x"34141073",
x"f39ff06f",
x"fd010113",
x"01612823",
x"00100793",
x"80000b37",
x"02812423",
x"02112623",
x"02912223",
x"03212023",
x"01312e23",
x"01412c23",
x"01512a23",
x"01712623",
x"01812423",
x"00fb2023",
x"00050413",
x"02051863",
x"ffff1537",
x"d5c50513",
x"d85ff0ef",
x"004005b7",
x"00040513",
x"afdff0ef",
x"4788d7b7",
x"afe78793",
x"04f50863",
x"00000513",
x"0380006f",
x"ffff1537",
x"d7c50513",
x"d59ff0ef",
x"00400537",
x"cddff0ef",
x"ffff1537",
x"d8850513",
x"d45ff0ef",
x"fe802783",
x"00080737",
x"00e7f7b3",
x"00079663",
x"00300513",
x"d85ff0ef",
x"bb5ff0ef",
x"fa0502e3",
x"ff1ff06f",
x"004009b7",
x"00498593",
x"00040513",
x"a95ff0ef",
x"00050a13",
x"00898593",
x"00040513",
x"a85ff0ef",
x"ff002c03",
x"00050a93",
x"ffca7b93",
x"00000913",
x"00000493",
x"00c98993",
x"013905b3",
x"05791c63",
x"015484b3",
x"00200513",
x"fa0494e3",
x"ffff1537",
x"d9050513",
x"cc9ff0ef",
x"02c12083",
x"02812403",
x"800007b7",
x"0147a223",
x"000b2023",
x"02412483",
x"02012903",
x"01c12983",
x"01812a03",
x"01412a83",
x"01012b03",
x"00c12b83",
x"00812c03",
x"03010113",
x"00008067",
x"00040513",
x"a09ff0ef",
x"012c07b3",
x"00a484b3",
x"00a7a023",
x"00490913",
x"f8dff06f",
x"ff010113",
x"00112623",
x"00812423",
x"00800793",
x"3007b073",
x"ff002403",
x"00050463",
x"40400437",
x"ffff1537",
x"d9450513",
x"c45ff0ef",
x"00040513",
x"bc9ff0ef",
x"ffff1537",
x"da450513",
x"c31ff0ef",
x"fa002783",
x"fe07cee3",
x"000400e7",
x"52450a07",
x"00005f52",
x"5252450a",
x"4358455f",
x"00000020",
x"69617741",
x"676e6974",
x"6f656e20",
x"32337672",
x"6578655f",
x"6e69622e",
x"202e2e2e",
x"00000000",
x"64616f4c",
x"20676e69",
x"00004028",
x"2e2e2e29",
x"0000000a",
x"00004b4f",
x"746f6f42",
x"20676e69",
x"6d6f7266",
x"00000020",
x"0a2e2e2e",
x"0000000a",
x"3c0a0a0a",
x"454e203c",
x"3356524f",
x"6f422032",
x"6f6c746f",
x"72656461",
x"0a3e3e20",
x"444c420a",
x"4d203a56",
x"20207961",
x"30322036",
x"480a3332",
x"203a5657",
x"00000020",
x"4449430a",
x"0020203a",
x"4b4c430a",
x"0020203a",
x"53494d0a",
x"00203a41",
x"5349580a",
x"00203a41",
x"434f530a",
x"0020203a",
x"454d490a",
x"00203a4d",
x"74796220",
x"40207365",
x"00000000",
x"454d440a",
x"00203a4d",
x"7475410a",
x"6f6f626f",
x"6e692074",
x"2e733820",
x"65725020",
x"61207373",
x"6b20796e",
x"74207965",
x"6261206f",
x"2e74726f",
x"0000000a",
x"726f6241",
x"2e646574",
x"00000a0a",
x"69617641",
x"6c62616c",
x"4d432065",
x"0a3a7344",
x"203a6820",
x"706c6548",
x"3a72200a",
x"73655220",
x"74726174",
x"3a75200a",
x"6c705520",
x"0a64616f",
x"203a7320",
x"726f7453",
x"6f742065",
x"616c6620",
x"200a6873",
x"4c203a6c",
x"2064616f",
x"6d6f7266",
x"616c6620",
x"200a6873",
x"42203a78",
x"20746f6f",
x"6d6f7266",
x"616c6620",
x"28206873",
x"29504958",
x"3a65200a",
x"65784520",
x"65747563",
x"00000000",
x"444d430a",
x"00203e3a",
x"65206f4e",
x"75636578",
x"6c626174",
x"76612065",
x"616c6961",
x"2e656c62",
x"00000000",
x"74697257",
x"00002065",
x"74796220",
x"74207365",
x"5053206f",
x"6c662049",
x"20687361",
x"00002040",
x"7928203f",
x"20296e2f",
x"00000000",
x"616c460a",
x"6e696873",
x"2e2e2e67",
x"00000020",
x"65206f4e",
x"75636578",
x"6c626174",
x"00002e65",
x"20296328",
x"53207962",
x"68706574",
x"4e206e61",
x"69746c6f",
x"670a676e",
x"75687469",
x"6f632e62",
x"74732f6d",
x"746c6f6e",
x"2f676e69",
x"726f656e",
x"00323376",
x"61766e49",
x"2064696c",
x"00444d43",
x"33323130",
x"37363534",
x"62613938",
x"66656463",
x"00455845",
x"5a495300",
x"48430045",
x"4600534b",
x"0048534c"
);

end neorv32_bootloader_image;
