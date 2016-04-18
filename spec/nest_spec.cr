require "./spec_helper"

before do
  c = Resp.new("localhost", 6379)
  c.call("FLUSHDB")
end

describe "foo" do
  it "should return the namespace" do
    n1 = Nest.new("foo")
    assert "foo" == n1.to_s
  end

  it "should prepend the namespace" do
    n1 = Nest.new("foo")
    assert "foo:bar" == n1["bar"].to_s
  end

  it "should work in more than one level" do
    n1 = Nest.new("foo")
    n2 = Nest.new(n1["bar"])
    assert "foo:bar:baz" == n2["baz"].to_s
  end

  it "should be chainable" do
    n1 = Nest.new("foo")
    assert "foo:bar:baz" == n1["bar"]["baz"].to_s
  end

  it "should accept symbols" do
    n1 = Nest.new(:foo)
    assert "foo:bar" == n1[:bar].to_s
  end

  it "should accept numbers" do
    n1 = Nest.new("foo")
    assert "foo:3" == n1[3].to_s
  end
  
  it "should accept redis commands" do
    n1 = Nest.new("foo")
    
    c = Resp.new("localhost", 6379)
    
    assert_equal "none", n1.call(c, "TYPE")
    assert_equal "OK",   n1.call(c, "SET", "42")
    assert_equal "42",   n1.call(c, "GET")
    
    n2 = Nest.new("bar", c as Resp)
     
    assert_equal "none", n2.call("TYPE")
    assert_equal "OK",   n2.call("SET", "42")
    assert_equal "42",   n2.call("GET")
  end

  it "should propagate the redis client" do
    c = Resp.new("localhost", 6379)

    n1 = Nest.new("foo", c)
    n2 = n1["bar"]

    assert_equal "none", n2.call("TYPE")
  end
end