# Nest

Object Oriented Keys for Redis.

## Description

If you are familiar with databases like [Redis](http://redis.io)
and libraries like [Ohm](http://ohm.keyvalue.org) you already know
how important it is to craft the keys that will hold the data.

```crystal
require "resp"

resp = Resp.new("redis://localhost:6379")
resp.call("SADD", "event:3:attendees", "Albert")
resp.call("SMEMBERS", "event:3:attendees") #=> ["Albert"]
```

It is a design pattern in key-value databases to use the key to
simulate structure, and you can read more about this in the [case
study for a Twitter clone](http://redis.io/topics/twitter-clone).

Nest helps you generate those keys by providing chainable namespaces
that are already connected to Redis:

```crystal
require "nest"

resp = Resp.new("redis://localhost:6379")

event = Nest.new("event", resp)
event[3][:attendees].call("SADD", "Albert")
event[3][:attendees].call("SMEMBERS") #=> ["Albert"]
```

You can also create the `Nest` instance without passing a `Resp`
client, and just provide it when invoking the `call` method:

```crystal
require "nest"

resp = Resp.new("redis://localhost:6379")

event = Nest.new("event")
event[3][:attendees].call(resp, "SADD", "Albert")
event[3][:attendees].call(resp, "SMEMBERS") #=> ["Albert"]
```

## Usage

To create a new namespace:

```crystal
ns = Nest.new("foo")

ns.to_s #=> "foo"

ns["bar"].to_s #=> "foo:bar"

ns["bar"]["baz"]["qux"].to_s #=> "foo:bar:baz:qux"
```

And you can use any object as a key, not only strings:

```crystal
ns[:bar][42].to_s #=> "foo:bar:42"
```

In a more realistic tone, lets assume you are working with Redis
and dealing with events:

```crystal
events = Nest.new("events", resp)

id = events[:id].call("INCR")

events[id][:attendees].call("SADD", "Albert")

meetup = events[id]

meetup[:attendees].call("SMEMBERS") #=> ["Albert"]
```

Nest allows you to execute all the Redis commands that expect a key
as the first parameter.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  nest:
    github: soveran/nest-crystal
    branch: master
```
