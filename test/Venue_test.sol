// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Ticketing.sol";

contract VenueTest is Test {
    Ticketing ticketing;

    function setUp() public {
        // Initialise une instance du contrat Ticketing
        ticketing = new Ticketing();
    }

    function testCreateVenue() public {
        // Créer une salle avec des données initiales
        ticketing.createOrModifyVenue(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, "Venue 1", 500, 25);

        // Vérifier les données de la salle
        (string memory name, uint256 spaceAvailable, uint256 revenueShare) = ticketing.getVenue(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        assertEq(name, "Venue 1");
        assertEq(spaceAvailable, 500);
        assertEq(revenueShare, 25);
    }


    function testModifyVenue() public {
        // Créer une salle
        ticketing.createOrModifyVenue(address(0xABC), "Venue 1", 500, 25);

        // Modifier les données de la salle
        ticketing.createOrModifyVenue(address(0xABC), "Venue Updated", 1000, 30);

        // Vérifier les nouvelles données
        (string memory name, uint256 spaceAvailable, uint256 revenueShare) = ticketing.getVenue(address(0xABC));
        assertEq(name, "Venue Updated");
        assertEq(spaceAvailable, 1000);
        assertEq(revenueShare, 30);
    }

    function testInvalidRevenueShare() public {
        // Vérifier qu'une salle avec un partage des revenus invalide échoue
        vm.expectRevert("Revenue share must be between 0 and 100");
        ticketing.createOrModifyVenue(address(0xDEF), "Invalid Venue", 500, 120);
    }

    function testRetrieveNonExistentVenue() public {
        // Vérifier qu'une salle non créée retourne des données vides
        (string memory name, uint256 spaceAvailable, uint256 revenueShare) = ticketing.getVenue(address(0x123));
        assertEq(name, "");
        assertEq(spaceAvailable, 0);
        assertEq(revenueShare, 0);
    }
}
