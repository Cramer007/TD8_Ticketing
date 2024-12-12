// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ticketing {
    address public owner;

    struct Artist {
        string name;
        string artistType; // Type d'artiste (ex. Musicien, Comédien, etc.)
        uint256 totalTicketsSold;
    }

    struct Venue {
        string name;
        uint256 spaceAvailable;
        uint256 revenueShare; // % du prix du billet allant à la salle (en pourcentage, ex: 20 pour 20%)
    }

    struct Concert {
        uint256 date; // Date du concert (timestamp Unix)
        address artistAddress;
        address venueAddress;
        bool artistConfirmed;
        bool venueConfirmed;
    }

    mapping(address => Artist) public artists; // Associe une adresse à un profil d'artiste
    mapping(address => Venue) public venues; // Associe une adresse à un profil de salle
    mapping(uint256 => Concert) public concerts; // Associe un ID unique à un concert
    uint256 public concertCount;


    event ArtistCreated(address indexed artistAddress, string name, string artistType);
    event ArtistModified(address indexed artistAddress, string name, string artistType, uint256 totalTicketsSold);
    event VenueCreated(address indexed venueAddress, string name, uint256 spaceAvailable, uint256 revenueShare);
    event VenueModified(address indexed venueAddress, string name, uint256 spaceAvailable, uint256 revenueShare);
    event ConcertCreated(uint256 concertId, address artistAddress, address venueAddress, uint256 date);
    event ConcertConfirmed(uint256 concertId, address confirmer);



    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Fonction pour créer ou modifier un profil d'artiste
    function createOrModifyArtist(
        address artistAddress,
        string memory name,
        string memory artistType,
        uint256 totalTicketsSold
    ) public {
        Artist storage artist = artists[artistAddress];
        artist.name = name;
        artist.artistType = artistType;
        artist.totalTicketsSold = totalTicketsSold;

        if (bytes(artist.name).length == 0) {
            emit ArtistCreated(artistAddress, name, artistType);
        } else {
            emit ArtistModified(artistAddress, name, artistType, totalTicketsSold);
        }
    }

    // Fonction pour créer ou modifier un profil de salle
    function createOrModifyVenue(
        address venueAddress,
        string memory name,
        uint256 spaceAvailable,
        uint256 revenueShare
    ) public {
        require(revenueShare <= 100, "Revenue share must be between 0 and 100");
        
        Venue storage venue = venues[venueAddress];
        venue.name = name;
        venue.spaceAvailable = spaceAvailable;
        venue.revenueShare = revenueShare;

        if (bytes(venue.name).length == 0) {
            emit VenueCreated(venueAddress, name, spaceAvailable, revenueShare);
        } else {
            emit VenueModified(venueAddress, name, spaceAvailable, revenueShare);
        }
    }

    // Fonction pour créer un concert
    function createConcert(
        uint256 date,
        address artistAddress,
        address venueAddress
    ) public {
        require(date > block.timestamp, "Concert date must be in the future");
        require(bytes(artists[artistAddress].name).length > 0, "Artist does not exist");
        require(bytes(venues[venueAddress].name).length > 0, "Venue does not exist");

        concerts[concertCount] = Concert({
            date: date,
            artistAddress: artistAddress,
            venueAddress: venueAddress,
            artistConfirmed: false,
            venueConfirmed: false
        });

        emit ConcertCreated(concertCount, artistAddress, venueAddress, date);
        concertCount++;
    }

    // Fonction pour récupérer les informations d'un artiste
    function getArtist(address artistAddress) public view returns (string memory, string memory, uint256) {
        Artist memory artist = artists[artistAddress];
        return (artist.name, artist.artistType, artist.totalTicketsSold);
    }

    // Fonction pour récupérer les informations d'une salle
    function getVenue(address venueAddress) public view returns (string memory, uint256, uint256) {
        Venue memory venue = venues[venueAddress];
        return (venue.name, venue.spaceAvailable, venue.revenueShare);
    }

    // Fonction pour confirmer un concert (par l'artiste ou la salle)
    function confirmConcert(uint256 concertId) public {
        Concert storage concert = concerts[concertId];
        require(concert.date > block.timestamp, "Concert already occurred");
        require(concert.artistAddress == msg.sender || concert.venueAddress == msg.sender, "Not authorized to confirm");

        if (concert.artistAddress == msg.sender) {
            concert.artistConfirmed = true;
        }

        if (concert.venueAddress == msg.sender) {
            concert.venueConfirmed = true;
        }

        emit ConcertConfirmed(concertId, msg.sender);
    }

    // Vérifie si le concert est confirmé par les deux parties
    function isConcertConfirmed(uint256 concertId) public view returns (bool) {
        Concert memory concert = concerts[concertId];
        return concert.artistConfirmed && concert.venueConfirmed;
    }
}
