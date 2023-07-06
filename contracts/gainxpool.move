module Gainxpool{
    use 0x1::Signer;
use 0x1::Mint;
use 0x1::LibraAccount;
use 0x1::Transfer;

public fun pool_balance(): u64 {
    let balance = LibraAccount::balance(move_from<0x1::PoolAddress>(0));
    return balance;
}

public fun receive_funds() {
    let amount: u64 = LibraAccount::balance(move_from<Signer::T>(0));
    let pool_address: address = move_from<0x1::PoolAddress>(0);
    Transfer::deposit_to_sender(move(amount), move(pool_address));
}

public fun send_funds(receiver: address, amount: u64) {
    let pool_balance = pool_balance();
    assert(pool_balance >= amount, 0x0);
    let pool_address: address = move_from<0x1::PoolAddress>(0);
    Transfer::withdraw_from_sender(move(amount), move(pool_address), move(receiver));
}

}