address immutable redeemTokenAddress;

struct Escrow {
address lender;
address borrower;
u64 escrowId;
u64 startBlock;
address nftAddress;
u64 nftId;
u128 amount;
u64 tenure;
u64 apy;
bool isInsured;
bool accepted;
bool completed;
}

struct LendingStates {
bool receivedFunds;
bool receivedRepayAmt;
bool receivedRedeemTokens;
bool completed;
}

resource GainxEscrow {
escrows: vector<Escrow>;
idToEscrow: map<u64, Escrow>;
idToLendingStates: map<u64, LendingStates>;
lenderToRepayAmt: map<address, u128>;
}

public fun initGainxEscrow(redeemToken: address): GainxEscrow {
GainxEscrow {
redeemTokenAddress = redeemToken,
escrows = empty,
idToEscrow = empty,
idToLendingStates = empty,
lenderToRepayAmt = empty,
}
}

public fun GainxEscrow_initEscrow(borrower: address, amount: u128, nftAddress: address, nftId: u64, tenure: u64, apy: u64) {
let escrowId = vec::length<Escrow>(self.escrows) as u64;
let startBlock = 0; 
let isInsured = false;
let accepted = false;
let completed = false;let newEscrow: Escrow = Escrow {
    lender: 0x0,
    borrower: borrower,
    escrowId: escrowId,
    startBlock: startBlock,
    nftAddress: nftAddress,
    nftId: nftId,
    amount: amount,
    tenure: tenure,
    apy: apy,
    isInsured: isInsured,
    accepted: accepted,
    completed: completed,
};

self.escrows = vector::push<Escrow>(self.escrows, newEscrow);
self.idToEscrow[escrowId] = newEscrow;
}

public fun GainxEscrow_withdrawNft(escrowId: u64) {
let lendingStates = self.idToLendingStates[escrowId];assert(!lendingStates.receivedFunds, 100);

}

public fun GainxEscrow_acceptOffer(escrowId: u64, isInsured: bool) {
let currEscrow = &mut self.idToEscrow[escrowId];
if isInsured {
    buyInsurance(move(currEscrow.borrower), currEscrow.amount, escrowId);
    currEscrow.isInsured = true;
}

let lendingStates = &mut self.idToLendingStates[escrowId];
lendingStates.receivedFunds = true;
currEscrow.accepted = true;
currEscrow.lender = move(currEscrow.borrower);

let repayAmt = currEscrow.amount + ((currEscrow.apy * currEscrow.amount) / 100);
self.lenderToRepayAmt[currEscrow.lender] = repayAmt;


}
public fun GainxEscrow_receiveRepayAmt(escrowId: u64) {

let lendingStates = &mut self.idToLendingStates[escrowId];
lendingStates.receivedRepayAmt = true;
lendingStates.completed = true;
self.idToEscrow[escrowId].completed = true;

}

public fun GainxEscrow_receiveRedeemAmt(escrowId: u64) {
let lendingStates = &mut self.idToLendingStates[escrowId];
lendingStates.receivedRedeemTokens = true;
self.idToEscrow[escrowId].completed = true;
let lender = move(self.idToEscrow[escrowId].lender);
let repayAmt = self.lenderToRepayAmt[lender];
}

public fun GainxEscrow_getExploreListings(): vector<Escrow> {
let totalItemCount = vector::length<Escrow>(self.escrows);
let mut items: vector<Escrow> = empty();

for i in 0..totalItemCount {
    let escrow = &self.escrows[i];
    if !escrow.accepted {
        items = vector::push<Escrow>(items, *escrow);
    }
}

items
}
public fun GainxEscrow_getLendersList(lender: address): vector<Escrow> {
let lenderEscrows = self.lendersList[lender];
let totalItemCount = vector::length<Escrow>(lenderEscrows);
let mut items: vector<Escrow> = empty();
for i in 0..totalItemCount {
    let escrowId = lenderEscrows[i].escrowId;
    let escrow = &self.idToEscrow[escrowId];
    items = vector::push<Escrow>(items, *escrow);
}

items
}
public fun GainxEscrow_getExploreListings(): vector<Escrow> {
let totalItemCount = vector::length<Escrow>(self.escrows);
let mut items: vector<Escrow> = empty();
for i in 0..totalItemCount {
    let escrow = &self.escrows[i];
    if !escrow.accepted {
        items = vector::push<Escrow>(items, *escrow);
    }
}

items
}
public fun GainxEscrow_getLendersList(lender: address): vector<Escrow> {
let lenderEscrows = self.lendersList[lender];
let totalItemCount = vector::length<Escrow>(lenderEscrows);
let mut items: vector<Escrow> = empty();
for i in 0..totalItemCount {
    let escrowId = lenderEscrows[i].escrowId;
    let escrow = &self.idToEscrow[escrowId];
    items = vector::push<Escrow>(items, *escrow);
}

items
}
public fun GainxEscrow_getBorrowersList(borrower: address): vector<Escrow> {
let borrowerEscrows = self.borrowersList[borrower];
let totalItemCount = vector::length<Escrow>(borrowerEscrows);
let mut items: vector<Escrow> = empty();
for i in 0..totalItemCount {
    let escrowId = borrowerEscrows[i].escrowId;
    let escrow = &self.idToEscrow[escrowId];
    items = vector::push<Escrow>(items, *escrow);
}

items
}

