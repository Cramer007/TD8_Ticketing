// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Tikets.sol";
import "../src/TicketMarketplace.sol";

contract TicketMarketplaceTest is Test {
    Tickets tickets;
    TicketMarketplace marketplace;

    function setUp() public {
    // Déployer le contrat Tickets
    tickets = new Tickets();

    // Ajouter un concert dans le contrat Tickets avec une adresse réelle pour l'artiste
    tickets.addConcert(0, block.timestamp + 2 days, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 1 ether);

    // Déployer le contrat TicketMarketplace
    marketplace = new TicketMarketplace(address(tickets));
}

    function testBuyTicket() public {
            // Simuler un achat de ticket
            vm.deal(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC, 1 ether); // Ajouter des fonds à une adresse d'Anvil
            vm.prank(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC); // Simuler l'appel depuis l'adresse
            marketplace.buyTicket{value: 1 ether}(0);

            // Récupérer les informations du ticket
            (uint256 concertId, address owner, bool used) = tickets.getTicket(0);

            // Vérifier que le ticket appartient à l'acheteur
            assertEq(owner, 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC, "Owner mismatch after ticket purchase");
            assertEq(concertId, 0, "Concert ID mismatch");
            assertFalse(used, "Ticket should not be marked as used");
        }
        function testTransferTicket() public {
        address buyer = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        address newOwner = address(0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65);

        vm.deal(buyer, 1 ether);

        // Simulez l'achat du ticket
        vm.prank(buyer);
        marketplace.buyTicket{value: 1 ether}(0);

        // Transférez le ticket
        vm.prank(buyer); // Le propriétaire actuel effectue le transfert
        marketplace.transferTicket(0, newOwner);

        // Vérifiez que le propriétaire est mis à jour
        (uint256 concertId, address updatedOwner, bool used) = tickets.getTicket(0);
        assertEq(updatedOwner, newOwner, "New owner mismatch after transfer");
    }




}