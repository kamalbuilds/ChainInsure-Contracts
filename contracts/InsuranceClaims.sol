// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/extension/Permissions.sol";

contract InsuranceClaims {
  enum ClaimStage {
    Submitted,
    AssessorApproved,
    InsuranceApproved,
    Compensated
  }

  struct Claim {
    address policyholder; // It is the user
    uint256 assetId; // The DNFT Id
    uint256 timestamp;
    bool validated;
    bool compensated;
    ClaimStage stage;
    string[] documentCIDs; // Array to store the CIDs of submitted documents
  }

  mapping(uint256 => Claim) public claims;
  mapping(address => uint256[]) public policyholderClaims;

  event ClaimSubmitted(
    uint256 indexed claimId,
    address indexed policyholder,
    uint256 indexed assetId,
    uint256 timestamp
  );
  event ClaimApproved(uint256 indexed claimId, ClaimStage indexed stage);
  event ClaimCompensated(uint256 indexed claimId);

  function submitClaim(uint256 claimId, uint256 assetId, string[] memory documentCIDs) external {
    // Perform necessary validations before submitting the claim

    require(claims[claimId].policyholder == address(0), "Claim already exists");

    // Create a new claim with the submitted document CIDs
    claims[claimId] = Claim({
      policyholder: msg.sender,
      assetId: assetId,
      timestamp: block.timestamp,
      validated: false,
      compensated: false,
      stage: ClaimStage.Submitted,
      documentCIDs: documentCIDs
    });

    policyholderClaims[msg.sender].push(claimId);

    emit ClaimSubmitted(claimId, msg.sender, assetId, block.timestamp);
  }

  function approveClaim(uint256 claimId) external {
    Claim storage claim = claims[claimId];

    // Perform necessary validations based on the claim stage and the role of the caller

    if (claim.stage == ClaimStage.Submitted) {
      // Assessor approves the claim
      // Perform assessor-specific validations

      // ...

      claim.stage = ClaimStage.AssessorApproved;
    } else if (claim.stage == ClaimStage.AssessorApproved) {
      // Insurance company approves the claim
      // Perform insurance company-specific validations

      // ...

      claim.stage = ClaimStage.InsuranceApproved;
    } else {
      revert("Invalid claim stage for approval");
    }

    emit ClaimApproved(claimId, claim.stage);

    if (claim.stage == ClaimStage.InsuranceApproved) {
      // If the claim is approved by both the assessor and the insurance company,
      // automatically initiate compensation
      compensateClaim(claimId);
    }
  }

  function compensateClaim(uint256 claimId) internal {
    Claim storage claim = claims[claimId];

    // Perform necessary validations and compensation calculations

    require(!claim.compensated, "Claim already compensated");

    // Perform compensation calculations and transfer funds to the policyholder

    // ...

    claim.compensated = true;

    emit ClaimCompensated(claimId);
  }
}
