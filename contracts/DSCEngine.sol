// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DSCEngine
 * @author Alexandre Collette
 * 
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == 1$ peg
 * This stablecoin has the properties:
 * - Exogenous Collateral
 * - Dollar Pegged
 * - Algoritmically stable
 *
 * This is the contract meant to be owned by DSCEngine. It is a ERC20 token that can be minted and burned by the DSCEngine smart contract.
 *
 * It is similar to DAI if DAI had no governance, no fees, and was only backed by WETH and WBTC.
 *
 * Our DSC system should always be "overcollateralized". At no point, should the value of all collateral <= the $ backed value of all the DSC.
 *
 * @notice This contract is the core of the DSC system. It handles all the logic for minting and redeeming DSC,
 * as well as depositing and withdrawing collateral.
 * @notice This contract is VERY loosely based on the MakerDAO DSS (DAI) system.
 */

contract DSCEngine {
     function depositCollateralAndMintDsc() external {

     }

     function depositCollateral() external {

     }

     function redeemCollateralForDsc() external {

     }

     function redeemCollateral() external {}

     function mintDsc() external {}

     function burnDsc() external {}
     function liquidate() external {}
     function getHealthFactor() external view {}
     


}