// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Tikets.sol";
import "../src/Ticketing.sol";

contract TicketsTest is Test {
    Tickets tickets;

    function setUp() public {
        tickets = new Tickets();
        tickets.addConcert(0, block.timestamp + 2 days, address(0x123), address(0x456), 1 ether);
    }



    function testUseTicket() public {
        // Ajouter un concert avec une adresse réelle pour l'artiste
        tickets.addConcert(0, block.timestamp + 2 days, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 1 ether);

        // Simuler que l'artiste émet un ticket
        vm.prank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        tickets.emitTicket(0, 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

        // Simuler l'utilisation du ticket
        vm.prank(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC); // L'utilisateur doit correspondre au propriétaire
        vm.warp(block.timestamp + 1 days + 23 hours); // Avancer dans le temps à 1h avant le concert
        tickets.useTicket(0);

        // Vérifier que le ticket a été marqué comme utilisé
        (, , bool used) = tickets.getTicket(0);
        assertTrue(used); // Le ticket doit être marqué comme utilisé
    }


    function testTicketValidity() public {
        // Ajouter un concert avec un artiste (address(0x123))
        tickets.addConcert(0, block.timestamp + 2 days, address(0x123), address(0x456), 1 ether);


        // Simuler un appel depuis l'artiste pour émettre un ticket
        vm.prank(address(0x123));
        tickets.emitTicket(0, address(this));

        // Avancer dans le temps à 1 jour avant le concert
        vm.warp(block.timestamp + 1 days + 1 hours);

        // Vérifier que le ticket est valide
        bool isValid = tickets.isTicketValid(0);
        assertTrue(isValid);
    }


    function testEmitTicket() public {
        // Ajouter un concert avec une adresse réelle pour l'artiste
        tickets.addConcert(0, block.timestamp + 2 days, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 1 ether);

        // Simuler un appel depuis l'adresse réelle de l'artiste
        vm.prank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        tickets.emitTicket(0, 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

        // Vérifier les données du ticket émis
        (uint256 concertId, address owner, bool used) = tickets.getTicket(0);
        assertEq(concertId, 0);
        assertEq(owner, 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        assertFalse(used);
    }
    function testUpdateTicketOwner() public {
        // Définir les adresses
        address initialOwner = address(this);
        address newOwner = address(0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65);

        // Simuler l'achat de ticket
        tickets.buyTicket{value: 1 ether}(0, initialOwner);

        // Vérifier que le propriétaire initial est correct
        (uint256 concertId, address owner, bool used) = tickets.getTicket(0);
        assertEq(owner, initialOwner, "Initial owner mismatch");

        // Mettre à jour le propriétaire du ticket
        tickets.updateTicketOwner(0, initialOwner, newOwner);

        // Vérifier que le propriétaire a été mis à jour
        (concertId, owner, used) = tickets.getTicket(0);
        assertEq(owner, newOwner, "New owner mismatch");
    }

}
