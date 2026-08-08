// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DrugAuthentication {

    // Only addresses in this mapping are allowed to register products.
    // This is how we control WHO can act as a manufacturer.
    mapping(address => bool) public isManufacturer;

    address public admin;

    // Core record for a product. We store the hash of its data,
    // not the raw data itself — keeps gas cost low and still lets us verify.
    struct Product {
        bytes32 dataHash;      // hash of (medicineName + batchNumber + mfgDate + expiryDate)
        address manufacturer;  // who registered it
        uint256 timestamp;     // when it was registered
        bool exists;           // to check if a batchNumber was ever registered
    }

    // batchNumber => Product. batchNumber is our unique key.
    mapping(string => Product) public products;

    event ProductRegistered(string batchNumber, bytes32 dataHash, address manufacturer);

    constructor() {
        admin = msg.sender;
        isManufacturer[msg.sender] = true; // deployer is a manufacturer by default, for testing
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can do this");
        _;
    }

    modifier onlyManufacturer() {
        require(isManufacturer[msg.sender], "Not an authorized manufacturer");
        _;
    }

    // Admin whitelists manufacturers. This is our access control —
    // stops random addresses from registering fake products.
    function addManufacturer(address _manufacturer) external onlyAdmin {
        isManufacturer[_manufacturer] = true;
    }

    // Called when a medicine batch is manufactured.
    // _dataHash is computed OFF-CHAIN (in JS) from the product details,
    // then passed in here to be stored immutably.
    function registerProduct(string memory _batchNumber, bytes32 _dataHash) external onlyManufacturer {
        require(!products[_batchNumber].exists, "Batch already registered");

        products[_batchNumber] = Product({
            dataHash: _dataHash,
            manufacturer: msg.sender,
            timestamp: block.timestamp,
            exists: true
        });

        emit ProductRegistered(_batchNumber, _dataHash, msg.sender);
    }

    // Called when retailer/customer scans a QR code.
    // They recompute the hash from the scanned data (in JS) and pass it here.
    // If it matches what's on-chain for that batch number, product is genuine.
    function verifyProduct(string memory _batchNumber, bytes32 _dataHashToCheck) external view returns (bool) {
        Product memory p = products[_batchNumber];
        if (!p.exists) {
            return false; // batch was never registered — definitely fake
        }
        return p.dataHash == _dataHashToCheck; // mismatch means tampered data
    }
}
