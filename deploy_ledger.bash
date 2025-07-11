#!/bin/bash
set -euo pipefail

# Import .env variables
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

ARG_PRESET_CANISTER_PRINCIPAL=""
if [ "${IS_LOCAL_DEV:-}" = "true" ]; then
    ARG_PRESET_CANISTER_PRINCIPAL="--specified-id ${PRESET_CANISTER_PRINCIPAL}"
fi

# dfx deploy icrc1_ledger_canister $ARG_PRESET_CANISTER_PRINCIPAL --argument "(
#   variant {Init =
#     record {
#       token_symbol = \"${TOKEN_SYMBOL}\";
#       token_name = \"${TOKEN_NAME}\";
#       minting_account = record { owner = principal \"${MINTER_ACCOUNT_ID}\" };
#       transfer_fee = ${TRANSFER_FEE};
#       metadata = vec {};
#       feature_flags = opt record{icrc2 = ${FEATURE_FLAGS}};
#       initial_balances = vec { record { record { owner = principal \"${DEPLOY_ID}\"; }; ${PRE_MINTED_TOKENS}; }; };
#       archive_options = record {
#         num_blocks_to_archive = ${NUM_OF_BLOCK_TO_ARCHIVE};
#         trigger_threshold = ${TRIGGER_THRESHOLD};
#         controller_id = principal \"${ARCHIVE_CONTROLLER}\";
#         cycles_for_archive_creation = opt ${CYCLE_FOR_ARCHIVE_CREATION};
#       };
#     }
#   }
# )"

dfx deploy --specified-id ryjl3-tyaaa-aaaaa-aaaba-cai icp_ledger_canister --argument "
  (variant {
    Init = record {
      minting_account = \"$MINTER_ACCOUNT_ID\";
      initial_values = vec {
        record {
          \"$DEV_ACCOUNT_ID\";
          record {
            e8s = 10_000_000_000 : nat64;
          };
        };
      };
      send_whitelist = vec {};
      transfer_fee = opt record {
        e8s = 10_000 : nat64;
      };
      token_symbol = opt \"LICP\";
      token_name = opt \"Local ICP\";
    }
  })
"

# dfx deploy cry-token-backend
