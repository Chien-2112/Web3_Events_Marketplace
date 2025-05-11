// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0 < 0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DappEvents is Ownable, ReentrancyGuard, ERC721 {
	using Counters for Counters.Counter;
	Counters.Counter private _totalEvents;
	Counters.Counter private _totalTokens;

	struct EventStruct {
		uint256 id;
		string title;
		string imageUrl;
		string description;
		address owner;
		uint256 sales;
		uint256 ticketCost;
		uint256 capacity;
		uint256 seats;
		uint256 startsAt;
		uint256 endsAt;
		uint256 timestamp;
		bool deleted;
		bool paidOut;
		bool refunded;
		bool minted;
	}

	struct TicketStruct {
		uint256 id;
		uint256 eventId;
		address owner;
		uint256 ticketCost;
		uint256 timestamp;
		bool refunded;
		bool minted;
	}

	uint256 public balance;
	uint256 private servicePct;

	mapping(uint256 => EventStruct) events;
	mapping(uint256 => TicketStruct[]) tickets;
	mapping(uint256 => bool) eventExists;

	constructor(uint256 _pct) ERC721('Event C', 'EVC') {
		servicePct = _pct;
	}

	// FEATURE 1 - CREATE EVENT: ALLOWS A USER TO CREATE A NEW EVENT.
	function createEvent(
		string memory title,
		string memory description,
		string memory imageUrl,
		uint256 capacity,
		uint256 ticketCost,
		uint256 startsAt,
		uint256 endsAt
	) public {
		require(ticketCost > 0 ether, "TicketCost must be greater than zero");
		require(capacity > 0, "Capacity must be greater than zero");
		require(bytes(title).length > 0, "Title cannot be empty");
		require(bytes(description).length > 0, "Description cannot be empty");
		require(bytes(imageUrl).length > 0, "ImageUrl cannot be empty");
		require(startsAt > 0, "Start date must be greater than zero");
		require(endsAt > startsAt, "End date must be greater than start date");

		_totalEvents.increment();
		EventStruct memory eventC;

		eventC.id = _totalEvents.current();
		eventC.title = title;
		eventC.description = description;
		eventC.imageUrl = imageUrl;
		eventC.capacity = capacity;
		eventC.ticketCost = ticketCost;
		eventC.startsAt = startsAt;
		eventC.endsAt = endsAt;
		eventC.owner = msg.sender;
		eventC.timestamp = currentTime();

		eventExists[eventC.id] = true;
		events[eventC.id] = eventC;
	}

	// FEATURE 2 - UPDATE EVENT: ALLOWS THE EVENT OWNER TO UPDATE THE DETAILS OF AN EXISTING EVENT.
	function updateEvent(
		uint256 eventId,
		string memory title,
		string memory description,
		string memory imageUrl,
		uint256 capacity,
		uint256 ticketCost,
		uint256 startsAt,
		uint256 endsAt
	) public {
		require(eventExists[eventId], "Event not found");
		require(events[eventId].owner == msg.sender, "Unauthorized entity");
		require(ticketCost > 0 ether, "TicketCost must be greater than zero");
		require(capacity > 0, "capacity must be greater than zero");
		require(bytes(title).length > 0, "Title cannot be empty");
		require(bytes(description).length > 0, "Description cannot be empty");
		require(bytes(imageUrl).length > 0, "ImageUrl cannot be empty");
		require(startsAt > 0, "Start date must be greater than zero");
		require(endsAt > startsAt, "End date must be greater than start date");

		events[eventId].title = title;
		events[eventId].description = description;
		events[eventId].imageUrl = imageUrl;
		events[eventId].capacity = capacity;
		events[eventId].ticketCost = ticketCost;
		events[eventId].startsAt = startsAt;
		events[eventId].endsAt = endsAt;
	}

	// FEATURE 3 - DELETE EVENT: ALLOWS THE EVENT OWNER OR CONTRACT OWNER TO DELETE AN EVENT.
	function deleteEvent(uint256 eventId) public {
		require(eventExists[eventId], "Event not found");
		require(events[eventId].owner == msg.sender || msg.sender == owner(), "Unauthorized entity");
		require(!events[eventId].paidOut, "Event already paid out");
		require(!events[eventId].refunded, "Event already refunded");
		require(!events[eventId].deleted, "Event already deleted");
		require(refundTickets(eventId), "Event failed to refund");

		events[eventId].deleted = true;
	}

	// FEATURE 4 - GET EVENTS: RETURNS ALL EXISTING EVENTS.
	function getEvents() public view returns(EventStruct[] memory Events) {
		uint256 available;

		for(uint256 i = 1; i < _totalEvents.current(); i++) {
			if(!events[i].deleted) {
				available++;
			}
		}

		Events = new EventStruct[](available);
		uint256 index;

		for(uint256 i = 1; i <= _totalEvents.current(); i++) {
			if(!events[i].deleted) {
				Events[index++] = events[i];
			}
		}
	}

	// FEATURE 5 - GET MYEVENTS: RETURNS ALL EVENTS CREATED BY THE CALLER.
	function getMyEvents() public view returns(EventStruct[] memory Events) {
		uint256 available;

		for(uint256 i = 1; i <= _totalEvents.current(); i++) {
			if(!events[i].deleted && events[i].owner == msg.sender) {
				available++;
			}
		}

		Events = new EventStruct[](available);
		uint256 index;

		for(uint256 i = 1; i <= _totalEvents.current(); i++) {
			if(!events[i].deleted && events[i].owner == msg.sender) {
				Events[index++] = events[i];
			}
		}
	}

	// FEATURE 6 - GET SINGLE EVENT: RETURNS A SINGLE EVENT BY ITS ID.
	function getSingleEvent(uint256 eventId) public view returns(EventStruct memory) {
		return events[eventId];
	}

	// FEATURE 7 - BUY TICKETS: ALLOWS A USER TO BUY TICKETS FOR AN EVENT.
	function buyTickets(uint256 eventId, uint256 numOfticket) public payable {
		require(eventExists[eventId], "Event not found");
		require(msg.value >= events[eventId].ticketCost * numOfticket, "Insufficient amount");
		require(numOfticket > 0, "NumOfticket must be greater than zero");
		require(
			events[eventId].seats + numOfticket <= events[eventId].capacity,
			"Out of seating capacity"
		);

		for(uint i = 0; i < numOfticket; i++) {
			TicketStruct memory ticket;
			ticket.id = tickets[eventId].length;
			ticket.eventId = eventId;
			ticket.owner = msg.sender;
			ticket.ticketCost = events[eventId].ticketCost;
			ticket.timestamp = currentTime();
			tickets[eventId].push(ticket);
		}
		events[eventId].seats += numOfticket;
		balance += msg.value;
	}

	// FEATURE 8 - GET TICKETS: RETURNS ALL TICKETS FOR A SPECIFIC EVENT.
	function getTickets(uint256 eventId) public view returns(TicketStruct[] memory Tickets) {
		return tickets[eventId];
	}

	// FEATURE 9 - REFUNDED TICKETS: REFUNDS ALL TICKETS FOR A SPECIFIC EVENT.
	function refundTickets(uint256 eventId) internal returns(bool) {
		for(uint i = 0; i < tickets[eventId].length; i++) {
			tickets[eventId][i].refunded = true;
			payTo(tickets[eventId][i].owner, tickets[eventId][i].ticketCost);
			balance -= tickets[eventId][i].ticketCost;
		}

		events[eventId].refunded = true;
		return true;
	}

	// FEATURE 10 - PAYOUT: ALLOWS THE EVENT OWNER OR CONTRACT OWNER TO PAYOUT AFTER AN EVENT.
	function payout(uint256 eventId) public {
		require(eventExists[eventId], "Event not found");
		require(!events[eventId].paidOut, "Event already paid out");
		require(currentTime() > events[eventId].endsAt, "Event still ongoing");
		require(events[eventId].owner == msg.sender || msg.sender == owner(), "Unauthorized entity");
		require(mintTickets(eventId), "Event failed to mint");

		uint256 revenue = events[eventId].ticketCost * events[eventId].seats;
		uint256 feePct = (revenue * servicePct) / 100;

		payTo(events[eventId].owner, revenue - feePct);
		payTo(owner(), feePct);

		events[eventId].paidOut = true;
		balance -= revenue;
	}

	// FEATURE 11 - MINT TICKETS: MINTS NFT TICKETS FOR AN EVENT.
	function mintTickets(uint256 eventId) internal returns(bool) {
		for(uint i = 0; i < tickets[eventId].length; i++) {
			_totalTokens.increment();
			tickets[eventId][i].minted = true;
			_mint(tickets[eventId][i].owner, _totalTokens.current());
		}

		events[eventId].minted = true;
		return true;
	}

	function payTo(address to, uint256 amount) internal {
		(bool success, ) = payable(to).call{value: amount}('');
		require(success);
	}

	function currentTime() internal view returns(uint256) {
		return (block.timestamp * 1000) + 1000;
	}
}