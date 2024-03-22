//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


/// @title Simple Proactive Funding
/// @notice This contract allows for proactive funding of RPGF projects through donations in OP tokens.
///         Donors receive two types of NFTs as a token of appreciation: a project NFT and an early funder NFT.
/// @custom:version 1.0
/// @author captnseagraves (captnseagraves.eth)

contract SimpleProactiveFunding is
    Ownable,
    ReentrancyGuard,
    ERC721URIStorage
{
    using SafeERC20 for IERC20;

    /***** STATE VARIABLES *****/

    /// @notice The stored address for the token contract
    address public tokenAddress;

    /// @notice The nonce for the NFTs minted by this contract
    /// @dev increments by two for each donation, once for projectNFT, once for earlyFunderNFT
    uint256 private nftIdNonce;
    
    /// @notice Mapping for RPGF project and funding amount
    mapping(address => uint256) public fundingAmounts;

    /// @notice Mapping for RPGF project and funding amount received
    mapping(address => uint256) public fundingAmountsReceived;

    /***** EVENTS *****/

    /// @notice Emitted when the funding amount for a project is set or updated.
    /// @param projectAddress The address of the RPGF project.
    /// @param fundingAmount The maximum amount of OP tokens to be raised.
    event FundingAmountSet(address projectAddress, uint256 fundingAmount);

    /// @notice Emitted when a donation is made to a RPGF project.
    /// @param projectAddress The address of the RPGF project that received the donation.
    /// @param amount The amount of OP tokens donated.
    /// @param donor The address of the donor.
    event Donation(address projectAddress, uint256 amount, address donor);

    /***** ERRORS *****/

    /// @dev Reverts if the project address is not whitelisted for funding.
    error NotWhitelistedAddress(address projectAddress);

    /// @dev Reverts if the funding goal for the project has already been met.
    error MaxFundingMet(address projectAddress);

    /***** CONSTRUCTOR *****/

    constructor(string memory name, string memory symbol, address initialOwner, address _tokenAddress) 
        ERC721(name, symbol) 
        Ownable(initialOwner)
    {
        tokenAddress = _tokenAddress;
    }

    /***** ADMIN FUNCTIONS *****/

    /// @notice Sets the maximum funding amount for a specific RPGF project and whitelists it for donations.
    /// @param projectAddress The address of the RPGF project to be whitelisted.
    /// @param fundingAmount The maximum amount of OP tokens that can be raised for the project.
    function setFundingAmount(address projectAddress, uint256 fundingAmount) external onlyOwner {
        fundingAmounts[projectAddress] = fundingAmount;

        emit FundingAmountSet(projectAddress, fundingAmount);
    }

    /***** EXTERNAL FUNCTIONS *****/

    /// @notice Allows a donor to proactively donate OP tokens to a whitelisted RPGF project.
    /// @dev Mints a project NFT and an early funder NFT for the donor as a token of appreciation.
    /// @param projectAddress The address of the RPGF project to donate to.
    /// @param donationAmount The amount of OP tokens to donate.
    /// @param projectNFTMetadataURI The metadata URI for the project NFT.
    /// @param earlyFunderNFTMetadataURI The metadata URI for the early funder NFT.
    function donate(
        address projectAddress,
        uint256 donationAmount,
        string calldata projectNFTMetadataURI,
        string calldata earlyFunderNFTMetadataURI
    ) external nonReentrant {
        /*** CHECKS ***/
        // if projectAddress is not whitelisted, revert
        _requireIsWhitelistedAddress(projectAddress);
        // if projectAddress has met max funding, revert
        _requireFundingNotMet(projectAddress);
        // require donationAmount is not zero
        _requireAmountNotZero(donationAmount);        
        // require projectNFTMetadataURI is not empty
        _requireMetadataURINotEmpty(projectNFTMetadataURI);
        // require earlyFunderNFTMetadataURI is not empty
        _requireMetadataURINotEmpty(earlyFunderNFTMetadataURI);

        /*** EFFECTS ***/       
        // if donation amount is greater than remaining to be raised, transfer delta
        if (donationAmount > (fundingAmounts[projectAddress] - fundingAmountsReceived[projectAddress])) {
            IERC20(tokenAddress).safeTransferFrom(msg.sender, projectAddress, (fundingAmounts[projectAddress] - fundingAmountsReceived[projectAddress]));

            donationAmount = (fundingAmounts[projectAddress] - fundingAmountsReceived[projectAddress]);
        } else {
        // transfer full amount
            IERC20(tokenAddress).safeTransferFrom(msg.sender, projectAddress, donationAmount);
        }
        // mint project nft
        _safeMint(msg.sender, nftIdNonce);
        _setTokenURI(nftIdNonce, projectNFTMetadataURI);
        nftIdNonce++;

        // mint early funder nft
        _safeMint(msg.sender, nftIdNonce);
        _setTokenURI(nftIdNonce, earlyFunderNFTMetadataURI);
        nftIdNonce++;

        /*** INTERACTIONS ***/       
        // update fundingAmountsReceived with donationAmount
        fundingAmountsReceived[projectAddress] += donationAmount;

        // emit donation event
        emit Donation(projectAddress, donationAmount, msg.sender);
    }

    /***** INTERNAL FUNCTIONS *****/

    /// @dev Checks if the given project address is whitelisted for funding.
    /// @param projectAddress The address to check.
    function _requireIsWhitelistedAddress(address projectAddress) internal view {
        if (fundingAmounts[projectAddress] == 0) {
            revert NotWhitelistedAddress(projectAddress);
        }
    }

    /// @dev Checks if the funding goal for the given project address has been met.
    /// @param projectAddress The address to check.
    function _requireFundingNotMet(address projectAddress) internal view {
        if (fundingAmounts[projectAddress] == fundingAmountsReceived[projectAddress]) {
            revert MaxFundingMet(projectAddress);
        }
    }

    /// @dev Ensures the donation amount is not zero.
    /// @param amount The donation amount to check.
    function _requireAmountNotZero(uint256 amount) internal pure {
        require(amount > 0, "amount cannot equal 0");
    }

    /// @dev Ensures the provided metadata URI is not empty.
    /// @param metadataURI The metadata URI to check.
    function _requireMetadataURINotEmpty(string calldata metadataURI) internal pure {
        require(bytes(metadataURI).length > 0, "metadataURI cannot be empty");
    }

    /***** SECURITY BEST PRACTICE FUNCTIONS *****/

    // function to prevent owner from renouncing ownership
    function renounceOwnership() public view override onlyOwner {
        revert("Ownership cannot be renounced");
    }
    // Function to revert when contract receives ether with no data
    receive() external payable {
        revert("Contract cannot receive ETH");
    }

    // Fallback function to revert when contract receives ether with data or if no function matches the call
    fallback() external payable {
        revert("Contract cannot receive ETH");
    }
}
