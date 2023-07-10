// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {DecentralizedStablecoin} from "./DecentralizedStablecoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title DSCEngine
/// @author Alexandre Collette
/// The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == 1$ peg
/// This stablecoin has the properties:
/// - Exogenous Collateral
/// - Dollar Pegged
/// - Algoritmically stable
///
/// This is the contract meant to be owned by DSCEngine. It is a ERC20 token that can be minted and burned
/// by the DSCEngine smart contract.
///
/// It is similar to DAI if DAI had no governance, no fees, and was only backed by WETH and WBTC.
///
/// Our DSC system should always be "overcollateralized".
/// At no point, should the value of all collateral <= the $ backed value of all the DSC.
///
/// @notice This contract is the core of the DSC system. It handles all the logic for minting and redeeming DSC,
/// as well as depositing and withdrawing collateral.
/// @notice This contract is VERY loosely based on the MakerDAO DSS (DAI) system.
contract DSCEngine is ReentrancyGuard {
    ///////////////////
    // Errors
    ///////////////////
    error DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenNotAllowed(address token);
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint256 healthFactorValue);
    error DSCEngine__MintFailed();
    error DSCEngine__HealthFactorOk();
    error DSCEngine__HealthFactorNotImproved();

    ///////////////////
    // Types
    ///////////////////

    ///////////////////
    // State Variables
    //////////////////
    DecentralizedStablecoin private immutable i_dsc;

    mapping(address => address) private s_priceFeeds; // token to pricefee
    mapping(address => mapping(address => uint256)) private s_collateralDeposited; // user => token => amount

    ///////////////////
    // Events
    ///////////////////

    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    ///////////////////
    // Modifiers
    ///////////////////

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed(token);
        }
        _;
    }

    ///////////////////
    // Constructor
    ///////////////////

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }

        i_dsc = DecentralizedStablecoin(dscAddress);
    }

    ///////////////////
    // Functions
    ///////////////////

    /// @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
    /// @param amountCollateral: The amount of collateral you're depositing
    /// @notice This function will deposit your collateral and mint DSC in one transaction
    function depositCollateralAndMintDsc(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
    {}

    /// @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
    /// @param amountCollateral: The amount of collateral you're depositing
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}
    function liquidate() external {}
    function getHealthFactor() external view {}
}
