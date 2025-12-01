# GaslessDonationTracker

A Solidity smart contract for tracking both ETH donations and gasless (non-monetary) contributions on the Ethereum blockchain.

## Overview

GaslessDonationTracker is designed for charities, crowdfunding campaigns, and community projects that need to track both financial contributions (ETH donations) and non-monetary support (volunteer hours, in-kind donations, etc.). The contract provides comprehensive tracking, statistics, and secure fund management.

## Features

### Dual Tracking System
- **ETH Donations**: Accept and track payable ETH contributions
- **Gasless Contributions**: Record non-monetary contributions without requiring transaction fees from contributors

### Donation Management
- Store detailed donation records including:
  - Donation amount
  - Custom message
  - Timestamp
  - Donor address
- Batch processing for gasless contributions
- Minimum donation threshold enforcement

### Donor Statistics
- Track individual donor metrics:
  - Total amount donated
  - Number of donations made
  - Gasless contribution count
- Retrieve top donors (limited to first 100)

### Beneficiary Controls
- Withdraw collected funds
- Update beneficiary address
- Modify minimum donation amount
- Complete ownership transfer capabilities

## Security Features

- **Access Control**: `onlyBeneficiary` modifier restricts sensitive functions
- **Custom Errors**: Gas-efficient error handling (e.g., `BelowMinimumDonation`, `InvalidAddress`)
- **Zero-Address Protection**: Prevents accidental fund loss
- **Reentrancy Safe**: Secure withdrawal pattern

## Key Functions

### Public Functions
```solidity
donate(string memory message) payable
// Make an ETH donation with optional message

recordGaslessContribution(address contributor, uint256 count, string memory description)
// Record a single gasless contribution (beneficiary only)

batchRecordGaslessContributions(...)
// Record multiple gasless contributions in one transaction (beneficiary only)
```

### View Functions
```solidity
getDonations() 
// Retrieve all donation records

getDonorStats(address donor)
// Get statistics for a specific donor

getContractBalance()
// Check total ETH held by contract

getTopDonors()
// Get list of top donors (first 100)
```

### Beneficiary Functions
```solidity
withdraw(uint256 amount)
// Withdraw ETH from contract

updateBeneficiary(address newBeneficiary)
// Transfer beneficiary rights

updateMinimumDonation(uint256 newMinimum)
// Adjust minimum donation requirement
```

## Use Cases

- **Charitable Organizations**: Track both monetary donations and volunteer hours
- **Crowdfunding Campaigns**: Record financial backing and community support
- **Community Projects**: Manage diverse contribution types (funds, materials, time)
- **DAOs**: Transparent contribution tracking for governance participation
- **Open Source Projects**: Acknowledge both financial sponsors and code contributors

## Getting Started

### Deployment
Deploy the contract with initial parameters:
```solidity
constructor(address _beneficiary, uint256 _minimumDonation)
```

### Making a Donation
Send ETH directly to the contract with an optional message:
```solidity
gaslessDonationTracker.donate{value: 1 ether}("Supporting this great cause!");
```

### Recording Gasless Contributions
Beneficiary can record non-monetary contributions:
```solidity
gaslessDonationTracker.recordGaslessContribution(
    contributorAddress,
    5, // count
    "Volunteered 5 hours"
);
```

## Events

The contract emits events for transparency and off-chain tracking:
- `DonationReceived`: Triggered on ETH donations
- `GaslessContributionRecorded`: Triggered when gasless contributions are logged
- `FundsWithdrawn`: Triggered when beneficiary withdraws funds
- `BeneficiaryUpdated`: Triggered on beneficiary address changes
- `MinimumDonationUpdated`: Triggered when minimum donation changes

## Best Practices

1. **Regular Withdrawals**: Beneficiaries should withdraw funds regularly to minimize contract balance
2. **Batch Processing**: Use batch functions for multiple gasless contributions to save gas
3. **Message Moderation**: Consider off-chain message filtering for inappropriate content
4. **Backup Records**: Monitor events off-chain for redundant record-keeping

## Contributing

Contributions, issues, and feature requests are welcome. Please ensure all code follows security best practices and includes appropriate tests.

## Support

For questions or support, please open an issue in the project repository.
