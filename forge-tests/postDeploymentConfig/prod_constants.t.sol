pragma solidity 0.8.16;

contract PROD_CONSTANTS_USDY_MAINNET {
  // usdyHub Role members
  address public usdyhub_default_admin =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
  address public usdyhub_manager_admin =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
  address public usdyhub_pauser_admin =
    0x2e55b738F5969Eea10fB67e326BEE5e2fA15A2CC;
  address public usdyhub_price_id_setter_role =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
  address public usdyhub_relayer_role =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
  address public usdyhub_timestamp_setter_role =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;

  address public asset_sender = 0x5Eb3ac7D9B8220C484307a2506D611Cc759626Ca;
  address public asset_recipient = 0xbDa73A0F13958ee444e0782E1768aB4B76EdaE28;
  address public fee_recipient = 0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
  address public usdy_asset = 0x96F6eF951840721AdBF46Ac996b59E0235CB985C;
  address public usdy_pricer = 0x7fb0228c6338da4EC948Df7b6a8E22aD2Bb2bfB5;
  uint256 public min_deposit_amt = 500e6;
  uint256 public min_redeem_amt = 500e18;
  uint256 public mint_fee = 0;
  uint256 public redeem_fee = 0;
  address public collateral = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  uint256 public decimals_multiplier = 10 ** 12;
  uint256 public bps_denominator = 10_000;
  bool public instant_minting_paused = true;

  address public block_list = 0xd8c8174691d936E2C80114EC449037b13421B0a8;
  address public sanctions_list = 0x40C57923924B5c5c5455c48D93317139ADDaC8fb;

  // usdy Token proxy
  address public usdy_proxy_admin_address =
    0x3eD61633057da0Bc58F84b2B9002845E56f94c19;
  bytes32 public usdy_proxy_admin_bytes =
    bytes32(uint256(uint160(usdy_proxy_admin_address)));
  address public usdy_impl_address = 0xea0F7EEbDc2Ae40edFE33bf03D332F8A7f617528;
  bytes32 public usdy_impl_bytes = bytes32(uint256(uint160(usdy_impl_address)));

  // USDY
  uint256 public decimals = 18;
  bool public paused = false;
  address public usdy_allowlist = 0x13300511f43768a30bb2bf10b63B6d502D1F7FE5;
  address public usdy_blocklist = 0xd8c8174691d936E2C80114EC449037b13421B0a8;
  address public usdy_sanctionslist =
    0x40C57923924B5c5c5455c48D93317139ADDaC8fb;
  string public name = "Ondo U.S. Dollar Yield";
  string public symbol = "USDY";

  address public usdy_default_admin =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
  address public usdy_minter_role = 0x25A103A1D6AeC5967c1A4fe2039cdc514886b97e;
  address public usdy_pauser_role = 0x2e55b738F5969Eea10fB67e326BEE5e2fA15A2CC;
  address public usdy_burner_role = 0x2626fB9dEbd067B05659A0303dB498B1382593f2;
  address public usdy_list_config_role =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;

  // PA Owner USDY
  address public usdy_pa_owner = 0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;

  // allowlist proxy
  address public allow_proxy_admin_address =
    0xeAa659DC72B39c164cA61B3570044Fd0dcC160Db;
  bytes32 public allow_proxy_admin_bytes =
    bytes32(uint256(uint160(allow_proxy_admin_address)));
  address public allow_impl_address =
    0x196a4cd6c6A1441A46C5D884DE148Fe6e1E950F7;
  bytes32 public allow_impl_bytes =
    bytes32(uint256(uint160(allow_impl_address)));

  // allowlist
  address public allow_default_admin =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
  address public allow_allowlist_admin =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
  address public allow_allowlist_setter =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;

  // PA Owner Allowlist
  address public allow_pa_owner = 0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;

  // Blocklist
  address public block_owner = 0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;

  // Pricer
  address public pricer_default_admin =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
  address public pricer_price_update_role =
    0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;

  // rUSDY
  string public rUSDY_name = ""; /// @dev FILL OUT!
  string public rUSDY_symbol = ""; /// @dev FILL OUT!

  address public rusdy_default_admin =
    0x0000000000000000000000000000000000000000; /// @dev FILL OUT!
  address public rusdy_minter_role = 0x0000000000000000000000000000000000000000; /// @dev FILL OUT!
  address public rusdy_pauser_role = 0x0000000000000000000000000000000000000000; /// @dev FILL OUT!
  address public rusdy_burner_role = 0x0000000000000000000000000000000000000000; /// @dev FILL OUT!
  address public rusdy_list_config_role =
    0x0000000000000000000000000000000000000000; /// @dev FILL OUT!
  address public rusdy_oracle = 0x0000000000000000000000000000000000000000; /// @dev FILL OUT!

  // usdy Token proxy
  address public rusdy_proxy_admin_address =
    0x0000000000000000000000000000000000000000; /// @dev FILL OUT!
  bytes32 public rusdy_proxy_admin_bytes =
    bytes32(uint256(uint160(rusdy_proxy_admin_address)));
  address public rusdy_impl_address =
    0x0000000000000000000000000000000000000000; /// @dev FILL OUT!
  bytes32 public rusdy_impl_bytes =
    bytes32(uint256(uint160(usdy_impl_address)));

  // PA Owner rUSDY
  address public rusdy_pa_owner = 0x0000000000000000000000000000000000000000; /// @dev FILL OUT!

  // RWADynamicRateOracel
  address public dro_admin = 0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
  address public dro_setter = 0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
  address public dro_pauser = 0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;
}

contract PROD_BRIDGE_MAINNET {
  // SRC Bridge
  address public src_bridge_token = 0x96F6eF951840721AdBF46Ac996b59E0235CB985C;
  address public src_bridge_axelar_gateway =
    0x4F4495243837681061C4743b74B3eEdf548D56A5;
  address public src_bridge_gas_receiver =
    0x2d5d7d31F671F86C782533cc367F14109a082712;
  uint256 public chainId = 1;
  string public src_approved_chain = "mantle";
  string public src_approved_contract_address =
    "0xd5235958c1f8a40641847a0e3bd51d04efe9ec28";
  bool public paused = false;
  address public src_owner = 0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;

  // DST Bridge
  address public dst_bridge_token = 0x96F6eF951840721AdBF46Ac996b59E0235CB985C;
  address public dst_axelar_gateway =
    0x4F4495243837681061C4743b74B3eEdf548D56A5;
  address public dst_allowlist = 0x13300511f43768a30bb2bf10b63B6d502D1F7FE5;
  address public dst_owner = 0x1a694A09494E214a3Be3652e4B343B7B81A73ad7;

  address[] approvers = [
    0x505ff4462bA5E62ed529FA836D768ECd7B85439c,
    0x8D52a385D19F13Ef5A544E0514c62f0A44ff31bf
  ];

  string public dst_approved_chain = "mantle";
  string public dst_approved_sender =
    "0x8Cbb8dB5CE28CF072776866F701368BBcf81F087";

  uint256[] public threshold_amounts = [100_000e18, 1_000_000e18];
  uint256[] public threshold_approvers = [2, 3];
  uint256 public mint_limit = 100_000e18;
}

contract PROD_CONSTANTS_USDY_MANTLE {
  // usdy Token proxy
  address public usdy_proxy_admin_address =
    0x201CDD34310A53915Ee55B0a229b5A4EB18D1448;
  bytes32 public usdy_proxy_admin_bytes =
    bytes32(uint256(uint160(usdy_proxy_admin_address)));
  address public usdy_impl_address = 0x3b355A7A25E75A320f631F9736afB3Dcc9F3Ef66;
  bytes32 public usdy_impl_bytes = bytes32(uint256(uint160(usdy_impl_address)));

  // USDY
  uint256 public decimals = 18;
  bool public paused = false;
  // address public usdy_allowlist = 0x13300511f43768a30bb2bf10b63B6d502D1F7FE5;
  address public usdy_blocklist = 0xdBd7a7d8807f0C98c9A58f7732f2799c8587e5c6;
  // address public usdy_sanctionslist =
  //   0x40C57923924B5c5c5455c48D93317139ADDaC8fb;
  string public name = "Ondo U.S. Dollar Yield";
  string public symbol = "USDY";

  address public usdy_default_admin =
    0xC8A7870fFe41054612F7f3433E173D8b5bFcA8E3;
  // address public usdy_minter_role = 0x25A103A1D6AeC5967c1A4fe2039cdc514886b97e;
  address public usdy_pauser_role = 0xC04E1818932f24Ec03457763deF23475D575A44C;
  // address public usdy_burner_role = 0x2626fB9dEbd067B05659A0303dB498B1382593f2;
  address public usdy_list_config_role =
    0xC8A7870fFe41054612F7f3433E173D8b5bFcA8E3;

  // PA Owner USDY
  address public usdy_pa_owner = 0xC8A7870fFe41054612F7f3433E173D8b5bFcA8E3;

  // Blocklist
  address public block_owner = 0xC8A7870fFe41054612F7f3433E173D8b5bFcA8E3;

  // rUSDY
  string public rUSDY_name = "Mantle USD"; /// @dev FILL OUT!
  string public rUSDY_symbol = "mUSD"; /// @dev FILL OUT!

  address public rusdy_default_admin =
    0xC8A7870fFe41054612F7f3433E173D8b5bFcA8E3; /// @dev FILL OUT!
  // address public rusdy_minter_role = 0x0000000000000000000000000000000000000000; /// @dev FILL OUT!
  address public rusdy_pauser_role = 0xC04E1818932f24Ec03457763deF23475D575A44C; /// @dev FILL OUT!
  // address public rusdy_burner_role = 0x0000000000000000000000000000000000000000; /// @dev FILL OUT!
  address public rusdy_list_config_role =
    0xC8A7870fFe41054612F7f3433E173D8b5bFcA8E3; /// @dev FILL OUT!
  address public rusdy_oracle = 0xA96abbe61AfEdEB0D14a20440Ae7100D9aB4882f; /// @dev FILL OUT!

  // usdy Token proxy
  address public rusdy_proxy_admin_address =
    0xE921Fc01BA2213e1C28D31E4Bf8B4D99FAe30A1d; /// @dev FILL OUT!
  bytes32 public rusdy_proxy_admin_bytes =
    bytes32(uint256(uint160(rusdy_proxy_admin_address)));
  address public rusdy_impl_address =
    0x907D8399d13cee098cEf486a8427933aaC7E6271; /// @dev FILL OUT!
  bytes32 public rusdy_impl_bytes =
    bytes32(uint256(uint160(rusdy_impl_address)));

  // PA Owner rUSDY
  address public rusdy_pa_owner = 0xC8A7870fFe41054612F7f3433E173D8b5bFcA8E3; /// @dev FILL OUT!

  // RWADynamicRateOracel
  address public dro_admin = 0xC8A7870fFe41054612F7f3433E173D8b5bFcA8E3; /// @dev FILL OUT!
  address public dro_setter = 0xC8A7870fFe41054612F7f3433E173D8b5bFcA8E3; /// @dev FILL OUT!
}

contract STAGING_CONSTANTS_OMMF_MAINNET {
  // ommfHub Role members
  address public ommfhub_default_admin =
    0x425291324577BDc7d557255864c65Ca1380269Bf; ///@dev UPDATE POST DEPLOYMENT
  address public ommfhub_manager_admin =
    0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public ommfhub_pauser_admin =
    0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public ommfhub_price_id_setter_role =
    0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public ommfhub_relayer_role =
    0x425291324577BDc7d557255864c65Ca1380269Bf;

  address public asset_sender = 0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public asset_recipient = 0x786A5b6B303453D4079C957895130302bAefcecC;
  address public fee_recipient = 0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public ommf_asset = 0x1dB541F00595B783957A0ED80eD70035Ad727E30;
  address public ommf_pricer = 0x0d269194548c874Ec1aC7a6bEb2A82BF7b78a07E;
  uint256 public min_deposit_amt = 1e6; ///@dev UPDATE POST DEPLOYMENT
  uint256 public min_redeem_amt = 1e18; ///@dev UPDATE POST DEPLOYMENT
  uint256 public mint_fee = 0; ///@dev UPDATE POST DEPLOYMENT
  uint256 public redeem_fee = 0; ///@dev UPDATE POST DEPLOYMENT
  address public collateral = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  uint256 public decimals_multiplier = 10 ** 12;
  uint256 public bps_denominator = 10_000;
  bool public instant_minting_paused = true;

  // ommf Token Proxy
  address public ommf_proxy_admin_address =
    0xC02f5d6Fd67e5Ba31DBd046e5F638379609F6Ea5;
  bytes32 public ommf_proxy_admin_bytes =
    bytes32(uint256(uint160(ommf_proxy_admin_address)));
  address public ommf_impl_address = 0xC5617F791F7BDB5e4d7fb03c17c42E744D8967E4;
  bytes32 public ommf_impl_bytes = bytes32(uint256(uint160(ommf_impl_address)));

  // OMMF
  uint256 public decimals = 18;
  bool public paused = false;
  address public kyc_registry = 0x730e077730BC25c1c92e2c078e3BaB2834775217;
  uint256 public kyc_requirement_group = 1;
  address public ommf_sanctions_list =
    0x40C57923924B5c5c5455c48D93317139ADDaC8fb;
  string public name = "Test Ondo Money Market Fund Token";
  string public symbol = "t-OMMF";

  address public ommf_default_admin =
    0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public ommf_minter_role = 0x533C5c15E073f56860B3091d7f7414f1cf6d4aE3;
  address public ommf_pauser_role = 0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public ommf_burner_role = 0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public ommf_rebase_setter_role =
    0x60eEC879cd31e47347058048433D9E381F510606;
  // @notice: add additional ommf specific roles
  // PA Owner ommf
  address public ommf_pa_owner = 0x425291324577BDc7d557255864c65Ca1380269Bf;
  // KYC Registry
  address public kyc_registry_sanctions_list =
    0x40C57923924B5c5c5455c48D93317139ADDaC8fb;

  /// WOMMF
  address public wommf_proxy_admin_address =
    0x6a8719f7E10Ff91A39460c6A9A8331e3052d43eB;
  bytes32 public wommf_proxy_admin_bytes =
    bytes32(uint256(uint160(wommf_proxy_admin_address)));
  address public wommf_impl_address =
    0xFB6996b54fdFC1679cE4a7bC2A304aa2f6f0bfFC;
  bytes32 public wommf_impl_bytes =
    bytes32(uint256(uint160(wommf_impl_address)));

  // wOMMF
  uint256 public wommf_decimals = 18;
  string public wommf_name = "Test Wrapped OMMF";
  string public wommf_symbol = "t-WOMMF";

  address public wommf_default_admin =
    0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public wommf_minter_role = 0x533C5c15E073f56860B3091d7f7414f1cf6d4aE3;
  address public wommf_pauser_role = 0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public wommf_burner_role = 0x425291324577BDc7d557255864c65Ca1380269Bf;

  // PA Owner ommf
  address public wommf_pa_owner = 0x425291324577BDc7d557255864c65Ca1380269Bf;

  // Pricer
  address public pricer_default_admin =
    0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public pricer_price_update_role =
    0x425291324577BDc7d557255864c65Ca1380269Bf;

  // Rebase Setter
  address public rebaseSetter_admin_role =
    0x425291324577BDc7d557255864c65Ca1380269Bf;
  address public rebaseSetter_setter_role =
    0x425291324577BDc7d557255864c65Ca1380269Bf;
}

contract PROD_CONSTANTS_OMMF_MAINNET {
  // ommfHub Role members
  address public ommfhub_default_admin =
    0xAEd4caF2E535D964165B4392342F71bac77e8367;
  address public ommfhub_manager_admin =
    0xAEd4caF2E535D964165B4392342F71bac77e8367;
  address public ommfhub_pauser_admin =
    0x2e55b738F5969Eea10fB67e326BEE5e2fA15A2CC;
  address public ommfhub_price_id_setter_role =
    0xc99b6cABd6ea0269b403eb4F7DaC8cdbeF3DbA01;
  address public ommfhub_relayer_role =
    0xc99b6cABd6ea0269b403eb4F7DaC8cdbeF3DbA01;
  address public ommfhub_redemption_prover_role =
    0xc99b6cABd6ea0269b403eb4F7DaC8cdbeF3DbA01;

  address public asset_sender = 0xc99b6cABd6ea0269b403eb4F7DaC8cdbeF3DbA01;
  address public asset_recipient = 0x599C5276F94153Aed4Abfe267eFc719b524F3aAA;
  address public fee_recipient = 0xc99b6cABd6ea0269b403eb4F7DaC8cdbeF3DbA01;
  address public ommf_asset = 0xE00e79c24B9Bd388fbf1c4599694C2cf18166102;
  address public ommf_pricer = 0x41dF1cDD31Bc5054fDf638f6b0192B1dC28C1a33;
  uint256 public min_deposit_amt = 10e6;
  uint256 public min_redeem_amt = 10e18;
  uint256 public mint_fee = 0;
  uint256 public redeem_fee = 0;
  address public collateral = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  uint256 public decimals_multiplier = 10 ** 12;
  uint256 public bps_denominator = 10_000;
  bool public instant_minting_paused = true;

  // ommf Token Proxy
  address public ommf_proxy_admin_address =
    0xF1A01fC93d8816b99F0Fe96a70810f20339F1362;
  bytes32 public ommf_proxy_admin_bytes =
    bytes32(uint256(uint160(ommf_proxy_admin_address)));
  address public ommf_impl_address = 0xF5FfCeD59b44A50d79DD26caf7329f8AadBcd554;
  bytes32 public ommf_impl_bytes = bytes32(uint256(uint160(ommf_impl_address)));

  // OMMF
  uint256 public decimals = 18;
  bool public paused = false;
  address public kyc_registry = 0x7cE91291846502D50D635163135B2d40a602dc70;
  uint256 public kyc_requirement_group = 1;
  address public ommf_sanctions_list =
    0x40C57923924B5c5c5455c48D93317139ADDaC8fb;
  string public name = "Ondo US Money Markets";
  string public symbol = "OMMF";

  address public ommf_default_admin =
    0xAEd4caF2E535D964165B4392342F71bac77e8367;
  address public ommf_minter_role = 0x1d01be0296B99aAdeE94116e285CDb2C40bE7929;
  address public ommf_pauser_role = 0x2e55b738F5969Eea10fB67e326BEE5e2fA15A2CC;
  ///@dev Left un-granted
  // address public ommf_burner_role = address(0x987);
  address public ommf_rebase_setter_role =
    0x5e95Db2dd76DDeeaB34a4d510Db5FC6e6C45d4fA;
  // @notice: add additional ommf specific roles

  // PA Owner ommf
  address public ommf_pa_owner = 0xAEd4caF2E535D964165B4392342F71bac77e8367;

  /// WOMMF
  address public wommf_proxy_admin_address =
    0x39934500B481e2C8A3ec43B1a357e65D6f0894cc;
  bytes32 public wommf_proxy_admin_bytes =
    bytes32(uint256(uint160(wommf_proxy_admin_address)));
  address public wommf_impl_address =
    0xF7a4477e754DBb621f0E1D9B274AB9Dc0431BeA3;
  bytes32 public wommf_impl_bytes =
    bytes32(uint256(uint160(wommf_impl_address)));

  // wOMMF
  uint256 public wommf_decimals = 18;
  string public wommf_name = "Wrapped OMMF";
  string public wommf_symbol = "wOMMF";

  address public wommf_default_admin =
    0xAEd4caF2E535D964165B4392342F71bac77e8367;
  address public wommf_minter_role = 0x1d01be0296B99aAdeE94116e285CDb2C40bE7929;
  address public wommf_pauser_role = 0x2e55b738F5969Eea10fB67e326BEE5e2fA15A2CC;
  ///@dev Left un-granted
  // address public wommf_burner_role = address(0x987); ///@dev UPDATE POST DEPLOYMENT

  // PA Owner ommf
  address public wommf_pa_owner = 0xAEd4caF2E535D964165B4392342F71bac77e8367;

  // KYC Registry
  address public kyc_registry_sanctions_list =
    0x40C57923924B5c5c5455c48D93317139ADDaC8fb;

  // Pricer
  address public pricer_default_admin =
    0xAEd4caF2E535D964165B4392342F71bac77e8367;
  address public pricer_price_update_role =
    0xAEd4caF2E535D964165B4392342F71bac77e8367;

  // Rebase Setter
  address public rebaseSetter_admin_role =
    0xAEd4caF2E535D964165B4392342F71bac77e8367;
  address public rebaseSetter_setter_role =
    0xAEd4caF2E535D964165B4392342F71bac77e8367;
}

contract PROD_BRIDGE_MANTLE {
  // SRC Bridge
  address public src_bridge_token = 0x5bE26527e817998A7206475496fDE1E68957c5A6;
  address public src_bridge_axelar_gateway =
    0xe432150cce91c13a887f7D836923d5597adD8E31;
  address public src_bridge_gas_receiver =
    0x2d5d7d31F671F86C782533cc367F14109a082712;
  uint256 public chainId = 5000;
  string public src_approved_chain = "Ethereum";
  string public src_approved_contract_address =
    "0xbd8fb563a325dc853741907ae06e5f3c02c9235c";
  bool public paused = false;
  address public src_owner = 0xC8A7870fFe41054612F7f3433E173D8b5bFcA8E3;

  // DST Bridge
  address public dst_bridge_token = 0x5bE26527e817998A7206475496fDE1E68957c5A6;
  address public dst_axelar_gateway =
    0xe432150cce91c13a887f7D836923d5597adD8E31;
  address public dst_allowlist = address(0);
  address public dst_owner = 0xC8A7870fFe41054612F7f3433E173D8b5bFcA8E3;

  address[] approvers = [
    0xbe75D85Df93D7734b327F1A5C2B1F3258a0fa5B6,
    0xbf8446d58986b4b4941429A129C35581e98FF43b
  ];

  string public dst_approved_chain = "Ethereum";
  string public dst_approved_sender =
    "0xD89655ECf4800251880f8f6BA9038970AD9813dB";

  uint256[] public threshold_amounts = [100_000e18, 1_000_000e18];
  uint256[] public threshold_approvers = [2, 3];
  uint256 public mint_limit = 100_000e18;
}
