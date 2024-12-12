// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Ticketing.sol";

contract TicketingTest is Test {
    Ticketing ticketing;

    function setUp() public {
        ticketing = new Ticketing();
    }

    function testCreateArtist() public {
        ticketing.createOrModifyArtist(address(0x123), "Artist 1", "Singer", 0);
        (string memory name, string memory artistType, uint256 totalTicketsSold) = ticketing.getArtist(address(0x123));
        assertEq(name, "Artist 1");
        assertEq(artistType, "Singer");
        assertEq(totalTicketsSold, 0);
    }

    function testModifyArtist() public {
        ticketing.createOrModifyArtist(address(0x123), "Artist 1", "Singer", 0);
        ticketing.createOrModifyArtist(address(0x123), "Artist 1 Updated", "Musician", 50);
        (string memory name, string memory artistType, uint256 totalTicketsSold) = ticketing.getArtist(address(0x123));
        assertEq(name, "Artist 1 Updated");
        assertEq(artistType, "Musician");
        assertEq(totalTicketsSold, 50);
    }
}
