// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

//standard test libs
import "../../../lib/forge-std/src/Test.sol";
import "../../../lib/forge-std/src/Vm.sol";

import {DSCEngine} from "../../../contracts/DSCEngine.sol";
import {DecentralizedStablecoin} from "../../../contracts/DecentralizedStablecoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DSCEngineTest is Test {
    // Contract instances
    DSCEngine dscEngine;
    DecentralizedStablecoin dsc;

    // Collateral addresses
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address[] public tokenAddresses;

    // Feed addresses
    address wethPriceFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address wbtcPriceFeed = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;
    address[] public priceFeedAddresses;

    // Users
    address public USER = makeAddr("user");

    // Amounts
    uint256 AMOUNT_COLLATERAL = 1_000 ether;

    function setUp() public {
        // setup arrays
        tokenAddresses.push(WETH);
        tokenAddresses.push(WBTC);

        priceFeedAddresses.push(wethPriceFeed);
        priceFeedAddresses.push(wbtcPriceFeed);

        // declare contract instance
        dsc = new DecentralizedStablecoin();
        dscEngine = new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));

        // Fund user with tokens
        deal(WETH, USER, 1_000 ether);
        deal(WBTC, USER, 1_000e18);
    }

    function test_dscEngine_init() public {
        assertEq(dscEngine.s_priceFeeds(WETH), wethPriceFeed);
    }

    //////////////////////////
    // Constructor tests
    //////////////////////////

    function test_RevertsIfTokenLengthDoesntMatchPriceFeeds() public {
        address[] memory tokenAddressesTest = new address[](1);
        address[] memory priceFeedAddressesTest = new address[](2);
        tokenAddressesTest[0] = WETH;
        priceFeedAddressesTest[0] = wethPriceFeed;
        priceFeedAddressesTest[1] = wbtcPriceFeed;

        vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch.selector);
        new DSCEngine(tokenAddressesTest, priceFeedAddressesTest, address(dsc));
    }

    //////////////////////////
    // Price Tests
    //////////////////////////

    function test_getUsdValue() public {
        uint256 ethAmount = 10 ether;
        uint256 actualUsd = dscEngine.getUsdValue(WETH, ethAmount);
        emit log_named_uint("USD value:", actualUsd);
    }

    function test_getTokenAmountFromUsd() public {
        uint256 usdAmount = 100 ether;
    }

    //////////////////////////
    // depositCollateral tests
    //////////////////////////

    function test_RevertsIfCollateralZero() public {
        uint256 amountCollateral = 10 ether;
        vm.startPrank(USER);
        IERC20(WETH).approve(address(dscEngine), amountCollateral);

        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        dscEngine.depositCollateral(WETH, 0);
        vm.stopPrank();
    }

    function test_RevertsWithUnapprovedCollateral() public {
        deal(LINK, USER, 1000 ether);
        vm.startPrank(USER);
        vm.expectRevert(DSCEngine.DSCEngine__TokenNotAllowed.selector);
        dscEngine.depositCollateral(LINK, 1000 ether);
        vm.stopPrank();
    }

    modifier depositedCollateral() {
        vm.startPrank(USER);
        IERC20(WETH).approve(address(dscEngine), AMOUNT_COLLATERAL);
        dscEngine.depositCollateral(WETH, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }

    function test_canDepositCollateralAndGetAccountInfo() public depositedCollateral {
        (uint256 totalDscMinted, uint256 collateralValueInUSD) = dscEngine.getAccountInformation(USER);
        uint256 expectedTotalDscMinted = 0;
        uint256 expectedDepositAmount = dscEngine.getTokenAmountFromUsd(WETH, collateralValueInUSD);
        assertEq(totalDscMinted, expectedTotalDscMinted);
        assertEq(AMOUNT_COLLATERAL, expectedDepositAmount);
    }
}
