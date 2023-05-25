use starknet::ContractAddress;

trait IERC20 {
    fn name() -> felt252;
    fn symbol() -> felt252;
    fn decimals() -> u8;
    fn totalSupply() -> u256;
    fn balanceOf(account: ContractAddress) -> u256;
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(recipient: ContractAddress, amount: u256) -> bool;
    fn transferFrom(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    fn approve(spender: ContractAddress, amount: u256) -> bool;
}

#[contract]
mod SpiritStone {
    use super::IERC20;
    use integer::BoundedInt;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use zeroable::Zeroable;
    use starknet::contract_address::ContractAddressZeroable;

    const DECIMAL_PART: u128 = 1000000000000000000_u128;

    // mint arguments, with below values, the halve time will be about 231 days 
    const BLOCK_TIME: u64 = 100_u64; // seconds
    const BLOCK_HALVE_INTERVAL: u64 = 200000_u64; // blocks

    const MAX_SUPPLY: u128 = 4000000000000000000000000000_u128; // tokens


    struct Storage {
        _name: felt252,
        _symbol: felt252,
        _total_supply: u256,
        _balances: LegacyMap<ContractAddress, u256>,
        _allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
        _start_time: u64,
        _mint_count: u64,
    }

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, value: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, value: u256) {}

    impl SpiritStone of IERC20 {
        fn name() -> felt252 {
            _name::read()
        }

        fn symbol() -> felt252 {
            _symbol::read()
        }

        fn decimals() -> u8 {
            18_u8
        }

        fn totalSupply() -> u256 {
            _total_supply::read()
        }

        fn balanceOf(account: ContractAddress) -> u256 {
            _balances::read(account)
        }

        fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
            _allowances::read((owner, spender))
        }

        fn transfer(recipient: ContractAddress, amount: u256) -> bool {
            let sender = get_caller_address();
            _transfer(sender, recipient, amount);
            true
        }

        fn transferFrom(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            _spend_allowance(sender, caller, amount);
            _transfer(sender, recipient, amount);
            true
        }

        fn approve(spender: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            _approve(caller, spender, amount);
            true
        }
    }

    #[constructor]
    fn constructor(name: felt252, symbol: felt252) {
        initializer(name, symbol);
        _start_time::write(get_block_timestamp());
    }

    #[view]
    fn name() -> felt252 {
        SpiritStone::name()
    }

    #[view]
    fn symbol() -> felt252 {
        SpiritStone::symbol()
    }

    #[view]
    fn decimals() -> u8 {
        SpiritStone::decimals()
    }

    #[view]
    fn totalSupply() -> u256 {
        SpiritStone::totalSupply()
    }

    #[view]
    fn balanceOf(account: ContractAddress) -> u256 {
        SpiritStone::balanceOf(account)
    }

    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
        SpiritStone::allowance(owner, spender)
    }

    #[view]
    fn start_time() -> u64 {
        _start_time::read()
    }

    #[view]
    fn mint_count() -> u64 {
        _mint_count::read()
    }

    #[view]
    fn available_mint_count() -> u64 {
        let now = get_block_timestamp();
        let can_mint_count = (now - _start_time::read()) / BLOCK_TIME;
        let already_minted = _mint_count::read();
        can_mint_count - already_minted
    }

    #[view]
    fn block_time() -> u64 {
        BLOCK_TIME
    }

    #[view]
    fn max_supply() -> u256 {
        u256 { low: MAX_SUPPLY, high: 0 }
    }

    #[view]
    fn block_halve_interval() -> u64 {
        BLOCK_HALVE_INTERVAL
    }

    #[view]
    fn block_reward() -> u256 {
        let already_minted = _mint_count::read();
        let n = already_minted / BLOCK_HALVE_INTERVAL;
        if (n == 0_u64) {
            u256 { low: 10000000000000000000000_u128, high: 0_u128 }
        } else if (n == 1_u64) {
            u256 { low: 5000000000000000000000_u128, high: 0_u128 }
        } else if (n == 2_u64) {
            u256 { low: 2500000000000000000000_u128, high: 0_u128 }
        } else if (n == 3_u64) {
            u256 { low: 1250000000000000000000_u128, high: 0_u128 }
        } else if (n == 4_u64) {
            u256 { low: 625000000000000000000_u128, high: 0_u128 }
        } else if (n == 5_u64) {
            u256 { low: 312500000000000000000_u128, high: 0_u128 }
        } else if (n == 6_u64) {
            u256 { low: 156250000000000000000_u128, high: 0_u128 }
        } else if (n == 7_u64) {
            u256 { low: 78125000000000000000_u128, high: 0_u128 }
        } else if (n == 8_u64) {
            u256 { low: 39062500000000000000_u128, high: 0_u128 }
        } else if (n == 9_u64) {
            u256 { low: 19531250000000000000_u128, high: 0_u128 }
        } else {
            u256 { low: 10000000000000000000_u128, high: 0_u128 }
        }
    }

    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) -> bool {
        SpiritStone::transfer(recipient, amount)
    }

    #[external]
    fn transferFrom(sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool {
        SpiritStone::transferFrom(sender, recipient, amount)
    }

    #[external]
    fn approve(spender: ContractAddress, amount: u256) -> bool {
        SpiritStone::approve(spender, amount)
    }

    #[external]
    fn increase_allowance(spender: ContractAddress, added_value: u256) -> bool {
        _increase_allowance(spender, added_value)
    }

    #[external]
    fn decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool {
        _decrease_allowance(spender, subtracted_value)
    }

    #[external]
    fn mint(recipient: ContractAddress) {
        _mint(recipient)
    }

    ///
    /// Internals
    ///

    #[internal]
    fn initializer(name_: felt252, symbol_: felt252) {
        _name::write(name_);
        _symbol::write(symbol_);
    }

    #[internal]
    fn _increase_allowance(spender: ContractAddress, added_value: u256) -> bool {
        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) + added_value);
        true
    }

    #[internal]
    fn _decrease_allowance(spender: ContractAddress, subtracted_value: u256) -> bool {
        let caller = get_caller_address();
        _approve(caller, spender, _allowances::read((caller, spender)) - subtracted_value);
        true
    }

    #[internal]
    fn _mint(recipient: ContractAddress) {
        assert(!recipient.is_zero(), 'SpiritStone: mint to 0');

        // check available mint count
        assert(available_mint_count() > 0, 'mint limit reached');

        let block_reward = block_reward();

        // check max supply
        let max_supply = max_supply();
        assert(max_supply - _total_supply::read() >= block_reward, 'max supply reached');

        _total_supply::write(_total_supply::read() + block_reward);
        _balances::write(recipient, _balances::read(recipient) + block_reward);
        _mint_count::write(_mint_count::read() + 1_u64);

        Transfer(Zeroable::zero(), recipient, block_reward);
    }

    #[internal]
    fn _burn(account: ContractAddress, amount: u256) {
        assert(!account.is_zero(), 'SpiritStone: burn from 0');
        _total_supply::write(_total_supply::read() - amount);
        _balances::write(account, _balances::read(account) - amount);
        Transfer(account, Zeroable::zero(), amount);
    }

    #[internal]
    fn _approve(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        assert(!owner.is_zero(), 'SpiritStone: approve from 0');
        assert(!spender.is_zero(), 'SpiritStone: approve to 0');
        _allowances::write((owner, spender), amount);
        Approval(owner, spender, amount);
    }

    #[internal]
    fn _transfer(sender: ContractAddress, recipient: ContractAddress, amount: u256) {
        assert(!sender.is_zero(), 'SpiritStone: transfer from 0');
        assert(!recipient.is_zero(), 'SpiritStone: transfer to 0');
        _balances::write(sender, _balances::read(sender) - amount);
        _balances::write(recipient, _balances::read(recipient) + amount);
        Transfer(sender, recipient, amount);
    }

    #[internal]
    fn _spend_allowance(owner: ContractAddress, spender: ContractAddress, amount: u256) {
        let current_allowance = _allowances::read((owner, spender));
        if current_allowance != BoundedInt::max() {
            _approve(owner, spender, current_allowance - amount);
        }
    }
}
