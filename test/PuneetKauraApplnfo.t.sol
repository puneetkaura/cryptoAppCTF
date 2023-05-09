// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PuneetKauraAppinfo.sol";

contract BaseSetup is Test {
    PuneetKauraAppinfo public appInfo;
    address public admin = vm.addr(1);
    address public nonAdmin = vm.addr(2);
    address public nonAdmin2 = vm.addr(3);

    function setUp() public {
        vm.startPrank(admin);
        appInfo = new PuneetKauraAppinfo();
        // Set the resume and Notion via setInfo
        appInfo.setInfo(
            "notion",
            "https://pkaura.notion.site/Puneet-Timeswap-2f31e1f44a7343dab95b9a696ed2afe9"
        );
        appInfo.setInfo(
            "resume",
            "https://pkaura.notion.site/Puneet-Timeswap-2f31e1f44a7343dab95b9a696ed2afe9"
        );
        vm.stopPrank();
    }
}

contract PuneeKauraAppInfoTest is BaseSetup {
    function testAdminAccess() public {
        vm.startPrank(admin);
        // Admin is able to setInfo
        appInfo.setInfo(
            "notion",
            "https://pkaura.notion.site/Puneet-Timeswap-2f31e1f44a7343dab95b9a696ed2afe9"
        );

        // Admin if able to call getApplicationInfo
        appInfo.getApplicationInfo();

        vm.stopPrank();

        // Non Admin should not be able to setInfo
        vm.startPrank(nonAdmin);
        vm.expectRevert();
        appInfo.getApplicationInfo();

        // Non admin can't use setInfo
        vm.expectRevert();
        appInfo.setInfo(
            "resume",
            "https://pkaura.notion.site/Puneet-Timeswap-2f31e1f44a7343dab95b9a696ed2afe9"
        );
    }

    function testEasyUnlock() public {
        // Add domain timeswap - timeswap.io
        vm.startPrank(admin);
        appInfo.addDomain("timeswap.io");
        vm.stopPrank();

        // Nonadmin can't add domain
        vm.prank(nonAdmin);
        vm.expectRevert();
        appInfo.addDomain("timeswap.io");

        //
        vm.prank(nonAdmin);
        vm.expectRevert();
        appInfo.unlockAccess("abc.io");

        // Nonadmin calls unlock
        vm.prank(nonAdmin);
        appInfo.unlockAccess("timeswap.io");

        vm.prank(nonAdmin2);
        vm.expectRevert();
        appInfo.getApplicationInfo("timeswap1.io");

        appInfo.getApplicationInfo("timeswap.io");

        vm.prank(nonAdmin);
        appInfo.getApplicationInfo("timeswap.io");
        vm.expectRevert();
        appInfo.getApplicationInfo("timeswap123.io");

        // DontLikeTheCTFShowInfo should work
        vm.prank(nonAdmin);
        appInfo.DontLikeTheCTFShowInfo();

        // assertEq(appInfo.getApplicationInfo(), ["https://pkaura.notion.site/Puneet-Timeswap-2f31e1f44a7343dab95b9a696ed2afe9", "https://pkaura.notion.site/Puneet-Timeswap-2f31e1f44a7343dab95b9a696ed2afe9"]);
    }

    // function testSetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
