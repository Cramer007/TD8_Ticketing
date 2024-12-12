// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/console.sol";


import "../src/Tikets.sol";

contract TicketMarketplace {
    Tickets public tickets;

    event TicketBought(uint256 ticketId, uint256 concertId, address indexed buyer, uint256 price);
    event TicketTransferred(uint256 ticketId, address indexed from, address indexed to);

    constructor(address ticketsContract) {
        tickets = Tickets(ticketsContract);
    }

    // Fonction pour acheter un ticket
    function buyTicket(uint256 concertId) public payable {
        // Appeler la fonction buyTicket dans le contrat Tickets
        tickets.buyTicket{value: msg.value}(concertId, msg.sender);
        // Récupérer le ticketCount actuel
        uint256 ticketId = tickets.ticketCount() - 1;

        emit TicketBought(ticketId, concertId, msg.sender, msg.value);
    }

    // Fonction pour transférer un ticket
    function transferTicket(uint256 ticketId, address to) public {
        (uint256 concertId, address owner, bool used) = tickets.getTicket(ticketId);

        require(owner == msg.sender, "You are not the owner of this ticket");
        require(!used, "Used tickets cannot be transferred");
        require(to != address(0), "Cannot transfer to the zero address");

        // Ajoutez `msg.sender` comme `currentOwner`
        tickets.updateTicketOwner(ticketId, msg.sender, to);

        emit TicketTransferred(ticketId, owner, to);
    }


}
