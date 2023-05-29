# Spirit Stone Contracts for Cairo-1.0
This is an ERC-20 contract modified according to OpenZeppelin's [implementation](https://github.com/OpenZeppelin/cairo-contracts/blob/cairo-1/src/openzeppelin/token/erc20.cairo) and it features the following characteristics:

-  There is no initial allocation, all tokens are generated through minting.
-  Anyone can call the mint function of the contract.
-  A block can be minted every 50 seconds.
-  The reward for each block is fixed and will be halved after every 400,000 blocks.
-  Minting will stop when the total number of tokens reaches 8,000,000,000.

## Development

- Install [cairo-1.0](https://github.com/starkware-libs/cairo).

- Set `cairo-test`, `cairo-format` and `starknet-compile` in your $PATH.

- Run command in [Makefile](https://github.com/ccoincash/spirit_stone/blob/master/Makefile).