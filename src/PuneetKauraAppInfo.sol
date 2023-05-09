// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {console} from "forge-std/console.sol";

contract PuneetKauraAppinfo is Ownable {
    mapping(string => bool) public unlockedDomain; // Check which domain has been unlocked
    mapping(string => string) private applicationInfo; // Updated by owner only with resume and notion
    mapping(address => bool) public allowedAddress;
    mapping(string => address) public unlocker;
    // mapping(address => bool) public dontLike;
    // mapping(string => bool) public allowedDomain;

    string[] private domainList;

    constructor() {}

    function getApplicationInfo() public view returns (string[] memory) {
        // Owner or AllowedAddress
        require(
            msg.sender == owner() || allowedAddress[msg.sender] == true,
            "Msg sender access is not Unlocked- Call Unlock first"
        );
        string[] memory _applicationInfo = new string[](2);
        _applicationInfo[0] = applicationInfo["resume"];
        _applicationInfo[1] = applicationInfo["notionTLDR"];
        return _applicationInfo;
    }

    function getApplicationInfo(
        string memory _domain
    ) public view returns (string[] memory) {
        // How can this be calldata
        // Owner or AllowedAddress or Allowed domain as input
        if (
            msg.sender == owner() ||
            allowedAddress[msg.sender] == true ||
            unlockedDomain[_domain]
        ) {
            string[] memory _applicationInfo = new string[](2);
            _applicationInfo[0] = applicationInfo["resume"];
            _applicationInfo[1] = applicationInfo["notionTLDR"];
            return _applicationInfo;
        } else {
            revert("Msg sender access is not Unlocked- Call Unlock first");
        }
    }

    function setInfo(string memory key, string memory url) public onlyOwner {
        applicationInfo[key] = url;
    }

    function unlockAccess(
        string memory _domain
    ) public returns (string memory) {
        for (uint i = 0; i < domainList.length; i++) {
            if (keccak256(bytes(_domain)) == keccak256(bytes(domainList[i]))) {
                unlockedDomain[_domain] = true;
                allowedAddress[msg.sender] = true;
                return "Domain unlocked, use getApplicationInfo";
            }
        }
        revert(
            "Domain Not allowed - please enter the correct domain, domain is not in the allowed list"
        );
    }

    function inspectDomainLock(
        string memory _domain
    ) public view onlyOwner returns (bool) {
        // return unlockedDomain[keccak256(bytes(_domain))];
        return unlockedDomain[_domain];
    }

    function modifyDomainLock(
        string memory _domain,
        bool _domainStatus
    ) public onlyOwner {
        unlockedDomain[_domain] = _domainStatus;
    }

    function addDomain(string memory _domain) public onlyOwner {
        domainList.push(_domain);
    }

    function removeDomain(string memory _domain) public onlyOwner {
        for (uint i; i < domainList.length; i++) {
            if (
                keccak256(abi.encodePacked(_domain)) ==
                keccak256(abi.encodePacked(domainList[i]))
            ) {
                domainList[i] = domainList[domainList.length - 1];
                domainList.pop();
                allowedAddress[unlocker[_domain]] = false;
                return;
            }
        }
        revert("Domain not found");
    }

    function checkDomainList() public view onlyOwner returns (string[] memory) {
        return domainList;
    }

    function DontLikeTheCTFShowInfo() public view returns (string[] memory) {
        string[] memory _applicationInfo = new string[](2);
        _applicationInfo[0] = applicationInfo["resume"];
        _applicationInfo[1] = applicationInfo["notionTLDR"];
        return _applicationInfo;
    }
}
