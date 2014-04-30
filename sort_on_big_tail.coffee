require 'colors'
redis = require 'redis'

client = redis.createClient()

###
begin = 1000000000
end   = 2000000000
###

batch_size = 10000
batches = 1

async_batch = (batch) ->
  batch_begin = batch * batch_size
  batch_end = (batch + 1) * batch_size - 1
  start = new Date().getTime()
  for i in [batch_begin..batch_end]
    do (i) ->
      client.zrevrangebyscore "test_zset", "+inf", "-inf", "limit", "0", "100", (err, result) ->
        if i is batch_end
          end = new Date().getTime()
          console.log "DONE sorting on big zset in #{parseFloat((end - start) / 1000).toFixed(2)}sec".blue

          if batch is batches
            console.log "DONE".red
            process.exit 0

          batch += 1
          async_batch batch

async_batch(1)



