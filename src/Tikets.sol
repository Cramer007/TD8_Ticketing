// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/console.sol";


contract Tickets {
    address public owner;

    struct Ticket {
        uint256 concertId;
        address owner;
        bool used;
    }

    struct Concert {
        uint256 date; // Timestamp Unix de la date du concert
        address artistAddress;
        address venueAddress;
        uint256 totalTickets;
        uint256 ticketPrice; // Prix d'un ticket
    }

    mapping(uint256 => Concert) public concerts; // Mapping des concerts
    mapping(uint256 => Ticket) public tickets; // Mapping des tickets par ID
    uint256 public ticketCount; // Compteur global pour les IDs des tickets

    event TicketEmitted(uint256 ticketId, uint256 concertId, address indexed owner);
    event TicketUsed(uint256 ticketId, address indexed user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyConcertArtist(uint256 concertId) {
        require(
            concerts[concertId].artistAddress == msg.sender,
            "Only the artist of this concert can emit tickets"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Fonction pour émettre des tickets
    function emitTicket(uint256 concertId, address to) public onlyConcertArtist(concertId) {
        require(concerts[concertId].date > block.timestamp, "Concert date must be in the future");

        tickets[ticketCount] = Ticket({
            concertId: concertId,
            owner: to,
            used: false
        });

        concerts[concertId].totalTickets++;

        emit TicketEmitted(ticketCount, concertId, to);
        ticketCount++;
    }

    // Fonction pour utiliser un ticket
    function useTicket(uint256 ticketId) public {
        Ticket storage ticket = tickets[ticketId];
        Concert memory concert = concerts[ticket.concertId];

        require(ticket.owner == msg.sender, "You are not the owner of this ticket");
        require(!ticket.used, "Ticket has already been used");
        require(
            block.timestamp >= concert.date - 1 days && block.timestamp <= concert.date,
            "Tickets can only be used within 24 hours of the concert"
        );

        ticket.used = true;

        emit TicketUsed(ticketId, msg.sender);
    }

    // Fonction pour ajouter un concert
    function addConcert(
        uint256 concertId,
        uint256 date,
        address artistAddress,
        address venueAddress,
        uint256 ticketPrice
    ) public onlyOwner {
        require(date > block.timestamp, "Concert date must be in the future");
        require(ticketPrice > 0, "Ticket price must be greater than 0");

        concerts[concertId] = Concert({
            date: date,
            artistAddress: artistAddress,
            venueAddress: venueAddress,
            totalTickets: 0, // Ajout de la virgule ici
            ticketPrice: ticketPrice
        });
    }

    // Vérifier si un ticket est valide
    function isTicketValid(uint256 ticketId) public view returns (bool) {
        Ticket memory ticket = tickets[ticketId];
        Concert memory concert = concerts[ticket.concertId];

        return (
            !ticket.used &&
            ticket.owner != address(0) &&
            block.timestamp >= concert.date - 1 days &&
            block.timestamp <= concert.date
        );
    }

    // Fonction pour acheter un ticket
    function buyTicket(uint256 concertId, address buyer) public payable {
        Concert storage concert = concerts[concertId];
        require(concert.date > block.timestamp, "Concert date must be in the future");
        require(msg.value == concert.ticketPrice, "Incorrect ticket price");

        tickets[ticketCount] = Ticket({
            concertId: concertId,
            owner: buyer,
            used: false
        });

        concert.totalTickets++;
        emit TicketEmitted(ticketCount, concertId, buyer); // Ajouter un événement pour le suivi
        ticketCount++;
        // Debug: Loggez le propriétaire du ticket
        console.log("Ticket owner after purchase:", tickets[ticketCount - 1].owner);
        

    }
    function getTicket(uint256 ticketId) public view returns (uint256, address, bool) {
        Ticket memory ticket = tickets[ticketId];
        return (ticket.concertId, ticket.owner, ticket.used);
    }

    function updateTicketOwner(uint256 ticketId, address currentOwner, address newOwner) public {
        require(tickets[ticketId].owner == currentOwner, "You are not the owner of this ticket");
        require(newOwner != address(0), "New owner cannot be the zero address");

        tickets[ticketId].owner = newOwner;
        emit TicketTransferred(ticketId, currentOwner, newOwner);
    }



    function debugTicket(uint256 ticketId) public view returns (uint256, address, bool) {
    Ticket memory ticket = tickets[ticketId];
    return (ticket.concertId, ticket.owner, ticket.used);
}

    function debugConcert(uint256 concertId) public view returns (uint256, address, address, uint256, uint256) {
        Concert memory concert = concerts[concertId];
        return (
            concert.date,
            concert.artistAddress,
            concert.venueAddress,
            concert.totalTickets,
            concert.ticketPrice
        );
    }


    function transferTicket(uint256 ticketId, address to) public {
        Ticket storage ticket = tickets[ticketId];
        require(ticket.owner == msg.sender, "You are not the owner of this ticket");
        require(!ticket.used, "Used tickets cannot be transferred");
        require(to != address(0), "Cannot transfer to the zero address");

        address previousOwner = ticket.owner;
        ticket.owner = to;

        emit TicketTransferred(ticketId, previousOwner, to);
    }

    event TicketTransferred(uint256 ticketId, address indexed from, address indexed to);

}
