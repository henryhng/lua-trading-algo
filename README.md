Ariware is a Lua automation helper for Roblox's Trade Tower game. I first created this in 2021 with the help of many other ROBLOX APIs. Below is the story of why I made this and what it was used for in the game.

Trade Tower was a game that had you click for currency and decide what to keep or sell. This helper, called AriWare, was built around making that a lot easier to manage. For example, it allows you to do repeated click upgrades, case purchases within a chosen price range, and selling items under a configured limit, all of which would benefit the user experience when playing this trading game.

Ariware also can help you read item values and recent average prices from the Trade Tower marketplace. It also supports auto buying and selling, so you choose a value range and list items for a percentage of their value, with a button to remove your listings.

One aspect that Ariware particularly excelled on was its jackpot mechanism. In jackpots, you must choose a combination of items that fits the available limits. Thus, Ariware's sum solver provides two methods of doing this: 1) an exhaustive search and 2) a quicker greedy search. The main script combines those results with the jackpot's current value along with a minimum chance setting before attempting an entry, to determine which items to enter into the jackpot.

While I no longer maintain Ariware (have not in five years), it has been a great memory. It was a good source of practice for my algorithmic skills and greatly developed my interest in computational work.