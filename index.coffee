require 'colors'

cuid   = require 'cuid'
Recore = require 'recore'
Redism = require 'redism'

random_string = (len) ->
  buf = []
  chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  charlen = chars.length

  for i in [0..len]
    idx = Math.floor(Math.random() * (charlen - 1))
    buf.push(chars[idx])

  return buf.join('')

Recore.meta = false

User = Recore.model 'User',
  idGenerator: 'increment'
  properties:
    guid:
      type: 'string'
      unique: true
      defaultValue: -> cuid()
    name:
      type: 'string'
      index: true
      defaultValue: -> random_string(10)
    email:
      type: 'string'
      unique: true
      defaultValue: -> random_string(15)
    created_at:
      type: 'timestamp'
      index: true
      defaultValue: -> Date.now()
    updated_at:
      type: 'timestamp'
      index: true
      defaultValue: -> Date.now()

Recore.configure
  redis: new Redism
    servers: [
      [":hash:", ["redis://localhost:6379"]]
      ["redis://localhost:6379/4"]
    ]
  prefix: "test"


total   = 10
counter = 0

start = new Date().getTime()

add_user = ->
  user = Recore.factory 'User'
  user.save (err) ->
    console.log @errors if err
    counter += 1
    if counter is total
      end = new Date().getTime()
      console.log "Done inserting #{total} users in #{parseFloat((end - start) / 1000).toFixed(2)} sec"
      return process.exit 0
    return add_user()

add_user()
