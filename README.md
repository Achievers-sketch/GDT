This is a GaslessDonationTracker smart contract that:

Tracks ETH donations (payable) and gasless contributions (non-payable).
Key Features:
Stores donation records (amount, message, timestamp, donor).
Tracks donor statistics (total donated, donation count, gasless contributions).
Supports batch gasless contribution tracking.
Allows beneficiary to withdraw funds and update settings.
Security & Best Practices:
Uses onlyBeneficiary modifier for restricted functions.
Custom errors for reverts (e.g., BelowMinimumDonation).
Prevents zero-address assignments.
View Functions:
Retrieve donations, donor stats, and contract balance.
Get top donors (limited to first 100).
Use Case: Charities, crowdfunding, or community projects needing both ETH and non-monetary contribution tracking.