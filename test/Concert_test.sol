// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Ticketing.sol";

contract TicketingTest is Test {
    Ticketing ticketing;

    function setUp() public {
        ticketing = new Ticketing();
        ticketing.createOrModifyArtist(address(0x123), "Artist 1", "Singer", 0);
        ticketing.createOrModifyVenue(address(0x456), "Venue 1", 500, 20);
    }

    function testCreateConcert() public {
        ticketing.createConcert(block.timestamp + 1 days, address(0x123), address(0x456));
        (uint256 date, address artist, address venue, bool artistConfirmed, bool venueConfirmed) = ticketing.concerts(0);
        assertEq(date, block.timestamp + 1 days);
        assertEq(artist, address(0x123));
        assertEq(venue, address(0x456));
        assertFalse(artistConfirmed);
        assertFalse(venueConfirmed);
    }

    function testConfirmConcert() public {
        ticketing.createConcert(block.timestamp + 1 days, address(0x123), address(0x456));
        vm.prank(address(0x123));
        ticketing.confirmConcert(0);
        vm.prank(address(0x456));
        ticketing.confirmConcert(0);
        assertTrue(ticketing.isConcertConfirmed(0));
    }
}
