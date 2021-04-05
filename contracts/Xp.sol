// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

/**
 * @title Xp History
 * @dev Main interface for interacting with a profile
 */
contract Xp {
    
    mapping(address => Profile) profiles;
    
    struct Profile {
        Experience[] _experiences;
        mapping(address => Permission) _permissions;
    }
    
    struct Experience {
        uint256 _id;
        address _organization;
        string _hash; // which hash? keccak256?
        bool _isCertified;
    }
    
    struct Permission {
        Grant _latestGrant;
        Grant[] _historyGrants;
    }
    
    struct Grant {
        uint256 _grantTime;
        string _encryptedHashes;
    }
    
    // called by candidate
    function propose(address _organization, string memory _hash) external {
        // verify candidate is not organization
        // dedupe
        
        Experience memory experience = Experience(
            profiles[msg.sender]._experiences.length,
            _organization,
            _hash,
            false
        );
        profiles[msg.sender]._experiences.push(experience);
    }
    
    // called by organization
    function certify(address _candidate, string memory _hash) external {
        bool certified;
        for (int i = int(profiles[_candidate]._experiences.length) - 1; i >= 0; i--) {
            if (
                !profiles[_candidate]._experiences[uint(i)]._isCertified &&
                profiles[_candidate]._experiences[uint(i)]._organization == msg.sender &&
                stringEqual(profiles[_candidate]._experiences[uint(i)]._hash, _hash)) {
                    profiles[_candidate]._experiences[uint(i)]._isCertified = true;
                    certified = true;
                    return;
                    // event?
            }
        }
        require(certified, "no experience has matched hash");
    }
    
    // called by candidate
    function grant(address _organization, string memory _encryptedHashes) external {
        if (profiles[msg.sender]._permissions[_organization]._latestGrant._grantTime != 0) {
            profiles[msg.sender]._permissions[_organization]._historyGrants.push(
                profiles[msg.sender]._permissions[_organization]._latestGrant
            );
        }
        
        profiles[msg.sender]._permissions[_organization]._latestGrant._grantTime = block.timestamp;
        profiles[msg.sender]._permissions[_organization]._latestGrant._encryptedHashes = _encryptedHashes;
    }
    
    // called by requesting organization
    function request(address _candidate) external view returns(Grant memory) {
        return profiles[_candidate]._permissions[msg.sender]._latestGrant;
    }
    
    // called by requesting organization
    // not efficient, but run off chain (view)
    function verify(address _candidate, string[] memory hashes) external view returns(bool) {
        for (uint i = 0; i < hashes.length; i++) {
            bool hashVerified = false;
            for (uint j = 0; j < profiles[_candidate]._experiences.length; j++) {
                if (
                    profiles[_candidate]._experiences[j]._isCertified &&
                    stringEqual(hashes[i], profiles[_candidate]._experiences[j]._hash)
                ) {
                    hashVerified = true;
                    break;
                }
            }
            // require(hashVerified, "hash could not be verified for candidate");
            if (!hashVerified) {
                return false;
            }
        }
        return true;
    }
    
    // takes the hash of an experience
    // not used?
    function hashExp(Experience memory exp) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(exp._hash));
    }
    
    // https://docs.soliditylang.org/en/latest/types.html#bytes-and-strings-as-arrays
    function stringEqual(string memory s1, string memory s2) internal pure returns(bool) {
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }
}
