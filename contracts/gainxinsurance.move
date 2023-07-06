module gainxinsurance{
    use 0x1::Signer;
use 0x1::Mint;
use 0x1::LibraAccount;
use 0x1::Transfer;
use 0x1::NFT;

resource struct Escrow {
    escrow_id: u64,
    start_block: u64,
    nft_address: address,
    nft_id: u64,
    lender: address,
    borrower: address,
    amount: u128,
    tenure: u64,
    apy: u64,
    is_insured: bool,
    accepted: bool,
    completed: bool,
}

resource struct LendingStates {
    received_nft: bool,
    received_funds: bool,
    received_repay_amt: bool,
    received_redeem_tokens: bool,
    completed: bool,
}

resource struct Insurance {
    insurance_id: u64,
    lending_id: u64,
    buyer: address,
    amount: u128,
    claimed: bool,
}

public fun buy_insurance(buyer: address, amount: u128, lending_id: u64) {
    let insurance_id = 0; // Assign a unique insurance_id
    let new_insurance: Insurance = Insurance {
        insurance_id: insurance_id,
        lending_id: lending_id,
        buyer: move(buyer),
        amount: move(amount),
        claimed: false,
    };
    let mut insurances = borrow_global_mut<@Vector<Insurance>>(move_from<0x1::InsurancesVector>(0));
    insurances.push_back(move(new_insurance));
}

public fun claim_insurance(id: u64) {
    let mut insurances = borrow_global_mut<@Vector<Insurance>>(move_from<0x1::InsurancesVector>(0));
    let insurance_ref = insurances[id as usize].borrow_mut();
    insurance_ref.claimed = true;
    let buyer = move(insurance_ref.buyer);
    let amount = move(insurance_ref.amount);
    drop(insurance_ref);
    // Transfer the insurance amount to the buyer's account
    Transfer::transfer_coin(move(buyer), move(amount));
}

public fun get_insurance_details_by_id(id: u64): &Insurance {
    let insurances = borrow_global<@Vector<Insurance>>(move_from<0x1::InsurancesVector>(0));
    return &insurances[id as usize];
}

public fun get_all_insurances_by_address(user: address): vector<&Insurance> {
    let insurances = borrow_global<@Vector<Insurance>>(move_from<0x1::InsurancesVector>(0));
    let mut result: vector<&Insurance> = [];
    for insurance in insurances.iter() {
        if insurance.borrow().buyer == user {
            result.push(insurance.borrow());
        }
    }
    return result;
}

public fun get_insurance_details_by_lending_id(id: u64): &Insurance {
    let insurances = borrow_global<@Vector<Insurance>>(move_from<0x1::InsurancesVector>(0));
    let lending_id = move_from<0x1::LendingToInsurance>(id);
    return &insurances[lending_id as usize];
}

public fun get_total_insurances(): u64 {
    let insurances = borrow_global<@Vector<Insurance>>(move_from<0x1::InsurancesVector>(0));
    return insurances.size() as u64;
}

}