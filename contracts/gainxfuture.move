module gainxfuture{
    address 0x1::Signer;
address 0x1::Mint;
use 0x1::LibraAccount;
use 0x1::Transfer;

resource struct Future {
    escrow_id: u64,
    apy: u64,
}

public fun lock_future_apy(escrow_id: u64, apy: u64) {
    let new_future: Future = Future {
        escrow_id: move(escrow_id),
        apy: move(apy),
    };
    let mut futures = borrow_global_mut<@Vector<Future>>(move_from<0x1::FuturesVector>(0));
    futures.push_back(move(new_future));
}

public fun get_future_apy(escrow_id: u64): u64 {
    let futures = borrow_global<@Vector<Future>>(move_from<0x1::FuturesVector>(0));
    for future in futures.iter() {
        if future.borrow().escrow_id == escrow_id {
            return future.borrow().apy;
        }
    }
    // If no future APY is found, return 0 as a default value
    return 0;
}

}