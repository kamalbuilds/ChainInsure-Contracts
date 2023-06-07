// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/extension/Drop1155.sol";
import "@thirdweb-dev/contracts/base/ERC1155Base.sol";
import "@thirdweb-dev/contracts/lib/CurrencyTransferLib.sol";

/// This is an EXAMPLE of usage of `Drop1155` for distributing ERC1155 tokens.

contract DNFT is ERC1155Base, Drop1155 {
  /*//////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/

  constructor(
    string memory _name,
    string memory _symbol,
    address _royaltyRecipient,
    uint128 _royaltyBps
  ) ERC1155Base(_name, _symbol, _royaltyRecipient, _royaltyBps) {}

  /*//////////////////////////////////////////////////////////////
                        Internal (overrideable) functions
    //////////////////////////////////////////////////////////////*/

  /// @dev Collects and distributes the primary sale value of NFTs being claimed.
  function _collectPriceOnClaim(
    uint256 _tokenId,
    address _primarySaleRecipient,
    uint256 _quantityToClaim,
    address _currency,
    uint256 _pricePerToken
  ) internal virtual override {
    if (_pricePerToken == 0) {
      return;
    }

    uint256 totalPrice = _quantityToClaim * _pricePerToken;

    if (_currency == CurrencyTransferLib.NATIVE_TOKEN) {
      if (msg.value != totalPrice) {
        revert("Must send total price.");
      }
    }

    address saleRecipient = _primarySaleRecipient;
    CurrencyTransferLib.transferCurrency(_currency, msg.sender, saleRecipient, totalPrice);
  }

  /// @dev Transfers the tokens being claimed.
  function _transferTokensOnClaim(
    address _to,
    uint256 _tokenId,
    uint256 _quantityBeingClaimed
  ) internal virtual override {
    _mint(_to, _tokenId, _quantityBeingClaimed, "");
  }

  /// @dev Checks whether platform fee info can be set in the given execution context.
  function _canSetClaimConditions() internal view virtual override returns (bool) {
    return msg.sender == owner();
  }

  /// @dev Runs before every `claim` function call.
  function _beforeClaim(
    uint256 _tokenId,
    address _receiver,
    uint256 _quantity,
    address _currency,
    uint256 _pricePerToken,
    AllowlistProof calldata _allowlistProof,
    bytes memory _data
  ) internal virtual {}

  /// @dev Runs after every `claim` function call.
  function _afterClaim(
    uint256 _tokenId,
    address _receiver,
    uint256 _quantity,
    address _currency,
    uint256 _pricePerToken,
    AllowlistProof calldata _allowlistProof,
    bytes memory _data
  ) internal virtual {}
}
