# DappEvents Project Documentation

![Events Marketplace](./screenshots/0.png)

![Events Marketplace](./screenshots/1.png)

## Key Features

- `createEvent`: Allows a user to create a new event.
- `updateEvent`: Allows the event owner to update the details of an existing event.
- `deleteEvent`: Allows the event owner or contract owner to delete an event.
- `getEvents`: Returns all existing events.
- `getMyEvents`: Returns all events created by the caller.
- `getSingleEvent`: Returns a single event by its ID.
- `buyTickets`: Allows a user to buy tickets for an event.
- `getTickets`: Returns all tickets for a specific event.
- `refundTickets`: Refunds all tickets for a specific event.
- `payout`: Allows the event owner or contract owner to payout after an event.
- `mintTickets`: Mints NFT tickets for an event.

## Running the Application

Supply the following keys in your `.env` variable:

```sh
NEXT_PUBLIC_RPC_URL=http://127.0.0.1:8545
NEXT_PUBLIC_ALCHEMY_ID=<YOUR_ALCHEMY_PROJECT_ID>
NEXT_PUBLIC_PROJECT_ID=<WALLET_CONNECT_PROJECT_ID>
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=somereallysecretsecret
```

Follow these steps to run the application:

1. Install the package modules by running the command: `yarn install`
2. Start the Hardhat server: `yarn blockchain`
3. Run the contract deployment script: `yarn deploy`
4. Run the contract seeding script: `yarn seed`
5. Spin up the Next.js development server: `yarn dev`

## 📚 Key Technologies

- 🌐 Next.js: A React framework for building server-side rendered and static websites.
- 📘 TypeScript: A statically typed superset of JavaScript.
- 📦 Hardhat: A development environment for Ethereum smart contracts.
- 🌐 EthersJs: A library for interacting with Ethereum and Ethereum-like blockchains.
- 📚 Redux-Toolkit: A library for managing application state.
- 🎨 Tailwind CSS: A utility-first CSS framework.
- 🌈 @rainbow-me/rainbowkit-siwe-next-auth: A library for authentication in Ethereum dApps.
- 📝 React-Toastify: A library for adding toast notifications to your React application.
- 📜 Swiper: A modern mobile touch slider.
- 📚 Wagmi: A library for building Ethereum dApps.