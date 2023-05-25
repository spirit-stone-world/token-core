# Spirit Stone Contracts for Cairo-1.0
This is an ERC-20 contract, featuring the following characteristics:

-  There is no initial allocation, all tokens are generated through minting.
-  Anyone can call the mint function of the contract.
-  A block can be minted every 100 seconds.
-  The reward for each block is fixed and will be halved after every 200,000 blocks.
-  Minting will stop when the total number of mints reaches 4,000,000,000.

## Development

- Install [cairo-1.0](https://github.com/starkware-libs/cairo).

- Set `cairo-test`, `cairo-format` and `starknet-compile` in your $PATH.

- Run command in [Makefile](https://github.com/ccoincash/spirit_stone/blob/master/Makefile).