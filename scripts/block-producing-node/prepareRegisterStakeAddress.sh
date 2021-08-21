#!/bin/bash

# Prepares block-producing node to create transaction, which will later be signed and submitted to register the stake address
# NOTE: To be run in $NODE_HOME directory

# Get current slot
currentSlot=$('./getCurrentSlot.sh')

# Find balance and UTXOs
if [ $NODE_CONFIG = 'mainnet' ]
then
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out
else
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --testnet-magic 1097911063 > fullUtxo.out
fi

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

echo "current balance (utxo):"
cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}

# Find stake address deposit value from params (fee for registering cert)
stakeAddressDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakeAddressDeposit')
echo stakeAddressDeposit : $stakeAddressDeposit

# Build a transaction for the deposit fee
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+0 \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --out-file tx.tmp \
    --certificate stake.cert

# Calculate current min fee
if [ $NODE_CONFIG = 'mainnet' ]
then
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --mainnet \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
else
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --testnet-magic 1097911063 \
    --witness-count 2 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
fi
echo fee: $fee

# Calculate change output
txOut=$((${total_balance}-${stakeAddressDeposit}-${fee}))
echo Change Output: ${txOut}

# Build actual transaction (tx.raw output to be sent to air gapped node to sign transaction)
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file stake.cert \
    --out-file tx.raw