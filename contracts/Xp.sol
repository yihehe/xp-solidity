// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

/**
 * @title Xp
 * @dev Main interface for interacting with a profile
 */
contract Xp {
    
    mapping(address => Profile) profiles;
    
    address payable wallet;
    
    struct Profile {
        Experience[] _experiences;
        // int zxcv;
        mapping(address => Permission) _permissions;
    }
    
    struct Experience {
        uint256 _id;
        address _organization;
        string _somethingToPersist;
        bool _isCertified;
    }
    
    struct Permission {
        TimeRange latestTimeRange;
        TimeRange[] historyTimeRange;
    }
    
    struct TimeRange {
        uint256 startTime;
        uint256 endTime;
    }
    
    // takes the hash of an experience
    // currently is only "somethingToPersist", but can be a more complex object
    function hashExp(Experience memory exp) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(exp._somethingToPersist));
    }
    
    // called by candidate
    function propose(address _organization, string memory _somethingToPersist) external returns(bytes32) {
        // Profile calldata p = profiles[msg.sender];
        // verify candidate is not organization
        
        Experience memory experience = Experience(
            profiles[msg.sender]._experiences.length,
            _organization,
            _somethingToPersist,
            false
        );
        profiles[msg.sender]._experiences.push(experience);
        
        return hashExp(experience);
    }
    
    // called by organization
    function certify(address _candidate, bytes32 hash) external {
        bool certified;
        for (int i = int(profiles[_candidate]._experiences.length) - 1; i >= 0; i--) {
            if (
                !profiles[_candidate]._experiences[uint(i)]._isCertified &&
                profiles[_candidate]._experiences[uint(i)]._organization == msg.sender &&
                hashExp(profiles[_candidate]._experiences[uint(i)]) == hash) {
                    profiles[_candidate]._experiences[uint(i)]._isCertified = true;
                    certified = true;
                    return;
                    // event?
            }
        }
        require(certified, "no experience has matched hash");
    }
    
    // called by requesting organization
    function getHistory(address _candidate) external view returns(Experience[] memory) {
        // only return certified history
        // only if _permissions
        
        return profiles[_candidate]._experiences;
    }
}
