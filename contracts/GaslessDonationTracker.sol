// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title GaslessDonationTracker
 * @dev Tracks both ETH donations and gasless contribution records
 * @notice Demonstrates payable vs non-payable functions and state management
 */
contract GaslessDonationTracker {
    
    // ============ Structs ============
    
    /// @notice Individual donation record
    struct Donation {
        address donor;
        uint256 amount;
        uint256 timestamp;
        string message;
        bool isPaid; // true for ETH, false for gasless tracking
    }
    
    /// @notice Donor statistics
    struct DonorStats {
        uint256 totalDonated;
        uint256 donationCount;
        uint256 gaslessCount;
        uint256 lastDonationTime;
    }
    
    // ============ State Variables ============
    
    /// @notice Contract owner/beneficiary
    address public beneficiary;
    
    /// @notice Total ETH donated
    uint256 public totalEthDonated;
    
    /// @notice Total number of donations (ETH + gasless)
    uint256 public totalDonations;
    
    /// @notice Total gasless contributions tracked
    uint256 public totalGaslessContributions;
    
    /// @notice Minimum donation amount (0.001 ETH)
    uint256 public minDonation = 0.001 ether;
    
    /// @notice Array of all donations
    Donation[] public donations;
    
    /// @notice Mapping from donor address to their stats
    mapping(address => DonorStats) public donorStats;
    
    /// @notice Mapping to track top donors
    address[] public donors;
    mapping(address => bool) private isDonor;
    
    // ============ Events ============
    
    /// @notice Emitted when ETH donation is received
    event DonationReceived(
        address indexed donor,
        uint256 amount,
        uint256 timestamp,
        string message
    );
    
    /// @notice Emitted when gasless contribution is tracked
    event GaslessContribution(
        address indexed contributor,
        uint256 timestamp,
        string message
    );
    
    /// @notice Emitted when beneficiary withdraws funds
    event FundsWithdrawn(
        address indexed beneficiary,
        uint256 amount
    );
    
    /// @notice Emitted when minimum donation is updated
    event MinDonationUpdated(uint256 newMinimum);
    
    /// @notice Emitted when beneficiary is changed
    event BeneficiaryChanged(
        address indexed oldBeneficiary,
        address indexed newBeneficiary
    );
    
    // ============ Errors ============
    
    error BelowMinimumDonation();
    error OnlyBeneficiary();
    error WithdrawalFailed();
    error NoFundsToWithdraw();
    error InvalidAddress();
    
    // ============ Modifiers ============
    
    /// @notice Restricts function to beneficiary only
    modifier onlyBeneficiary() {
        if (msg.sender != beneficiary) revert OnlyBeneficiary();
        _;
    }
    
    // ============ Constructor ============
    
    /// @notice Initialize contract with beneficiary
    /// @param _beneficiary Address that can withdraw funds
    constructor(address _beneficiary) {
        if (_beneficiary == address(0)) revert InvalidAddress();
        beneficiary = _beneficiary;
    }
    
    // ============ Payable Functions (ETH Donations) ============
    
    /// @notice Donate ETH with optional message
    /// @param message Optional message from donor
    function donate(string calldata message) external payable {
        if (msg.value < minDonation) revert BelowMinimumDonation();
        
        _recordDonation(msg.sender, msg.value, message, true);
        
        emit DonationReceived(msg.sender, msg.value, block.timestamp, message);
    }
    
    /// @notice Quick donate without message
    function quickDonate() external payable {
        if (msg.value < minDonation) revert BelowMinimumDonation();
        
        _recordDonation(msg.sender, msg.value, "", true);
        
        emit DonationReceived(msg.sender, msg.value, block.timestamp, "");
    }
    
    /// @notice Fallback to receive ETH
    receive() external payable {
        if (msg.value < minDonation) revert BelowMinimumDonation();
        
        _recordDonation(msg.sender, msg.value, "Direct transfer", true);
        
        emit DonationReceived(msg.sender, msg.value, block.timestamp, "Direct transfer");
    }
    
    // ============ Non-Payable Functions (Gasless Tracking) ============
    
    /// @notice Track contribution without ETH (gasless)
    /// @param message Contribution message or commitment
    /// @dev Used for tracking non-monetary contributions
    function trackContribution(string calldata message) external {
        _recordDonation(msg.sender, 0, message, false);
        
        donorStats[msg.sender].gaslessCount++;
        totalGaslessContributions++;
        
        emit GaslessContribution(msg.sender, block.timestamp, message);
    }
    
    /// @notice Batch track multiple gasless contributions
    /// @param messages Array of contribution messages
    function batchTrackContributions(string[] calldata messages) external {
        for (uint256 i = 0; i < messages.length; i++) {
            _recordDonation(msg.sender, 0, messages[i], false);
            totalGaslessContributions++;
        }
        
        donorStats[msg.sender].gaslessCount += messages.length;
        
        emit GaslessContribution(msg.sender, block.timestamp, "Batch contribution");
    }
    
    // ============ Internal Functions ============
    
    /// @notice Internal function to record donation/contribution
    function _recordDonation(
        address donor,
        uint256 amount,
        string memory message,
        bool isPaid
    ) internal {
        // Create donation record
        donations.push(Donation({
            donor: donor,
            amount: amount,
            timestamp: block.timestamp,
            message: message,
            isPaid: isPaid
        }));
        
        // Update donor stats
        if (isPaid) {
            donorStats[donor].totalDonated += amount;
            totalEthDonated += amount;
        }
        donorStats[donor].donationCount++;
        donorStats[donor].lastDonationTime = block.timestamp;
        totalDonations++;
        
        // Track unique donors
        if (!isDonor[donor]) {
            donors.push(donor);
            isDonor[donor] = true;
        }
    }
    
    // ============ View Functions ============
    
    /// @notice Get total number of donations
    function getDonationCount() external view returns (uint256) {
        return donations.length;
    }
    
    /// @notice Get donation by index
    function getDonation(uint256 index) external view returns (
        address donor,
        uint256 amount,
        uint256 timestamp,
        string memory message,
        bool isPaid
    ) {
        require(index < donations.length, "Invalid index");
        Donation memory d = donations[index];
        return (d.donor, d.amount, d.timestamp, d.message, d.isPaid);
    }
    
    /// @notice Get latest N donations
    function getLatestDonations(uint256 count) external view returns (Donation[] memory) {
        uint256 total = donations.length;
        uint256 returnCount = count > total ? total : count;
        
        Donation[] memory latest = new Donation[](returnCount);
        
        for (uint256 i = 0; i < returnCount; i++) {
            latest[i] = donations[total - 1 - i];
        }
        
        return latest;
    }
    
    /// @notice Get donor statistics
    function getDonorStats(address donor) external view returns (
        uint256 totalDonated,
        uint256 donationCount,
        uint256 gaslessCount,
        uint256 lastDonationTime
    ) {
        DonorStats memory stats = donorStats[donor];
        return (
            stats.totalDonated,
            stats.donationCount,
            stats.gaslessCount,
            stats.lastDonationTime
        );
    }
    
    /// @notice Get my donation statistics
    function myStats() external view returns (DonorStats memory) {
        return donorStats[msg.sender];
    }
    
    /// @notice Get top donors (limited to first 100)
    function getTopDonors(uint256 limit) external view returns (
        address[] memory topAddresses,
        uint256[] memory amounts
    ) {
        uint256 donorCount = donors.length;
        uint256 returnCount = limit > donorCount ? donorCount : limit;
        
        // Create arrays to return
        address[] memory addresses = new address[](returnCount);
        uint256[] memory donationAmounts = new uint256[](returnCount);
        
        // Simple implementation - return first N donors
        // In production, you'd want to sort by amount
        for (uint256 i = 0; i < returnCount; i++) {
            addresses[i] = donors[i];
            donationAmounts[i] = donorStats[donors[i]].totalDonated;
        }
        
        return (addresses, donationAmounts);
    }
    
    /// @notice Get contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /// @notice Get donation statistics summary
    function getStats() external view returns (
        uint256 totalEth,
        uint256 totalDonationCount,
        uint256 gaslessCount,
        uint256 uniqueDonors,
        uint256 averageDonation
    ) {
        uint256 paidDonations = totalDonations - totalGaslessContributions;
        uint256 avg = paidDonations > 0 ? totalEthDonated / paidDonations : 0;
        
        return (
            totalEthDonated,
            totalDonations,
            totalGaslessContributions,
            donors.length,
            avg
        );
    }
    
    // ============ Beneficiary Functions ============
    
    /// @notice Withdraw all funds to beneficiary
    function withdraw() external onlyBeneficiary {
        uint256 balance = address(this).balance;
        if (balance == 0) revert NoFundsToWithdraw();
        
        (bool success, ) = beneficiary.call{value: balance}("");
        if (!success) revert WithdrawalFailed();
        
        emit FundsWithdrawn(beneficiary, balance);
    }
    
    /// @notice Withdraw specific amount
    function withdrawAmount(uint256 amount) external onlyBeneficiary {
        require(amount <= address(this).balance, "Insufficient balance");
        
        (bool success, ) = beneficiary.call{value: amount}("");
        if (!success) revert WithdrawalFailed();
        
        emit FundsWithdrawn(beneficiary, amount);
    }
    
    /// @notice Update minimum donation amount
    function setMinDonation(uint256 newMinimum) external onlyBeneficiary {
        minDonation = newMinimum;
        emit MinDonationUpdated(newMinimum);
    }
    
    /// @notice Change beneficiary address
    function changeBeneficiary(address newBeneficiary) external onlyBeneficiary {
        if (newBeneficiary == address(0)) revert InvalidAddress();
        
        address oldBeneficiary = beneficiary;
        beneficiary = newBeneficiary;
        
        emit BeneficiaryChanged(oldBeneficiary, newBeneficiary);
    }
    
    // ============ Helper Functions ============
    
    /// @notice Check if address has donated
    function hasDonated(address donor) external view returns (bool) {
        return isDonor[donor];
    }
    
    /// @notice Get donations by specific donor
    function getDonationsByDonor(address donor) external view returns (uint256[] memory) {
        uint256 count = 0;
        
        // Count donations by this donor
        for (uint256 i = 0; i < donations.length; i++) {
            if (donations[i].donor == donor) {
                count++;
            }
        }
        
        // Create array of indices
        uint256[] memory indices = new uint256[](count);
        uint256 currentIndex = 0;
        
        for (uint256 i = 0; i < donations.length; i++) {
            if (donations[i].donor == donor) {
                indices[currentIndex] = i;
                currentIndex++;
            }
        }
        
        return indices;
    }
}