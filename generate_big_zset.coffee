require 'colors'
redis = require 'redis'

client = redis.createClient()

###
begin = 1000000000
end   = 2000000000
###

begin = 100000000
end   = 200000000

batch_size = 10000
batches = Math.ceil((end - begin) / batch_size)

async_batch = (batch) ->
  batch_begin = batch * batch_size
  batch_end = (batch + 1) * batch_size - 1
  start = new Date().getTime()
  for i in [batch_begin..batch_end]
    do (i) ->
      client.zadd "test_zset", i, i, (err, result) ->
        if i is batch_end
          end = new Date().getTime()
          console.log "DONE inserting #{batch_end - batch_begin + 1} memebers to zset in #{parseFloat((end - start) / 1000).toFixed(2)}sec".blue

          if batch is batches
            console.log "DONE".red
            process.exit 0

          batch += 1
          async_batch batch

client.del "test_zset", (err, result) ->
  return process.exit 1 if err
  console.log "Cleaned up"
  async_batch(1)



