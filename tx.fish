## USAGE:
#
# source tx.fish
#
# miner 2  # sets the current miner to geth2
# unlock   # unlocks the current miner's account
# tx       # sends a single tx
# txes 10  # sends 10 txes in parallel

function geth_id
  geth --exec "eth.accounts[0]" attach ipc:gdata/geth$GETH/geth.ipc | sed 's/0x//' | sed 's/"//g'
end

set -g TO 0000000000000000000000000000000000000000

function tx
  curl -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "id":      1,
    "jsonrpc": "2.0",
    "method":  "eth_sendTransaction",
    "params":  [
      {
        "from": "'$FROM'",
        "to": "'$TO'"
      }
    ]
  }' "http://localhost:4040$GETH/"
end

function txes # TAKES A NUMBER OF TXES
  echo curl -s -X POST -H "'Content-Type: application/json'" -d '\'{ "id": 1, "jsonrpc": "2.0", "method":  "eth_sendTransaction", "params":  [ { "from": "'$FROM'", "to": "'$TO'" } ] }\'' "http://localhost:4040$GETH/" >/tmp/cmd.txt
  parallel -j 8 :::: (for x in (seq $argv); cat /tmp/cmd.txt; end | psub)
end

function unlock
  geth --exec "personal.unlockAccount(eth.accounts[0], 'abcd')" attach ipc:gdata/geth$GETH/geth.ipc
end

function miner # TAKES A GETH NUMBER (e.g. 2)
  set -g GETH $argv
  set -g FROM (geth_id < /dev/null)
end

function clean
  rm -r raft-*-{wal,snap}
end