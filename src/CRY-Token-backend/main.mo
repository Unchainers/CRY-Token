import None "mo:base/None";
import Float "mo:base/Float";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";

actor {
  // Define the relevant types for ICRC-1 transfer
  type Account = { owner : Principal; subaccount : ?[Nat8] };
  type TransferArg = {
    from_subaccount : ?[Nat8];
    to : Account;
    amount : Nat;
    fee : ?Nat;
    memo : ?Blob;
    created_at_time : ?Nat64;
  };

  type TransferResult = {
    #Ok : Nat;
    #Err : {
      #GenericError : { message : Text; error_code : Nat };
      #TemporarilyUnavailable;
      #BadBurn : { min_burn_amount : Nat };
      #Duplicate : { duplicate_of : Nat };
      #BadFee : { expected_fee : Nat };
      #CreatedInFuture : { ledger_time : Nat64 };
      #TooOld;
      #InsufficientFunds : { balance : Nat };
    };
  };

  // Reference to the ICP ledger canister
  let icp_ledger = actor("ryjl3-tyaaa-aaaaa-aaaba-cai") : actor {
    icrc1_transfer : shared TransferArg -> async TransferResult;
  };

  // Reference to your token ledger canister (replace with your canister ID)
  let my_token_ledger = actor("mxzaz-hqaaa-aaaar-qaada-cai") : actor {
    icrc1_transfer : shared TransferArg -> async TransferResult;
  };

  // Predefined price: 1 ICP = 100 MYT
  let price : Nat = 100;


  public shared({caller}) func swapICPForToken(icp_amount : Nat) : async Text {
    // 1. Check that the user has sent ICP to the canister's account (off-chain or via a deposit step)
    // 2. Calculate the amount of MYT to send
    let myt_amount = icp_amount * price;

    // 3. Transfer MYT from canister to user
    let transferArg : TransferArg = {
      from_subaccount = null;
      to = { owner = caller; subaccount = null };
      amount = myt_amount;
      fee = null;
      memo = null;
      created_at_time = null;
    };

    let result = await my_token_ledger.icrc1_transfer(transferArg);

    switch (result) {
      case (#Ok(_)) {
        return "Swap successful: sent " # Nat.toText(myt_amount) # " MYT for " # Nat.toText(icp_amount) # " ICP.";
      };
      case (#Err(e)) {
        return "Swap failed: " # debug_show(e);
      };
    };
  }
}

