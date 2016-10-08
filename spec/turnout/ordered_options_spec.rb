require 'spec_helper'

describe Turnout::OrderedOptions do
  it 'tests usages' do
    a = Turnout::OrderedOptions.new

    expect(a[:not_set]).to be_nil

    a[:allow_concurrency] = true
    expect(a.size).to eq(1)
    expect(a[:allow_concurrency]).to be_truthy

    a[:allow_concurrency] = false
    expect(a.size).to eq(1)
    expect(a[:allow_concurrency]).to be_falsy

    a["else_where"] = 56
    expect(a.size).to eq(2)
    expect(a[:else_where]).to eq(56)
  end

  it 'tests looping' do
    a = Turnout::OrderedOptions.new

    a[:allow_concurrency] = true
    a["else_where"] = 56

    test = [[:allow_concurrency, true], [:else_where, 56]]

    a.each_with_index do |(key, value), index|
      expect(test[index].first).to eq(key)
      expect(test[index].last).to eq(value)
    end
  end

  it 'tests method access' do
    a = Turnout::OrderedOptions.new
    expect(a.not_set).to eq(nil)

    a.allow_concurrency = true
    expect(a.size).to eq(1)
    expect(a.allow_concurrency).to eq(true)

    a.allow_concurrency = false
    expect(a.size).to eq(1)
    expect(a.allow_concurrency).to eq(false)

    a.else_where = 56
    expect(a.size).to eq(2)
    expect(a.else_where).to eq(56)
  end
  it 'tests inheritable_options_continues_lookup_in_parent' do
    parent = Turnout::OrderedOptions.new
    parent[:foo] = true

    child = Turnout::InheritableOptions.new(parent)
    expect(child.foo).to eq(true)
  end

  it 'tests inheritable_options_can_override_parent' do
    parent = Turnout::OrderedOptions.new
    parent[:foo] = true

    child = Turnout::InheritableOptions.new(parent)
    child[:foo] = :baz
    expect(child.foo).to eq(:baz)
  end

  it 'tests inheritable_options_inheritable_copy' do
    original = Turnout::InheritableOptions.new
    copy     = original.inheritable_copy

    expect(copy.kind_of?(original.class)).to be_truthy
    expect(copy.object_id).to_not eq(original.object_id)
  end

  it 'tests inheritable_options_inheritable_copy from hash' do
    parent = {foo: true }
    child = Turnout::InheritableOptions.new(parent)
    expect(child.foo).to eq(true)
  end


  it 'tests introspection' do
    a = Turnout::OrderedOptions.new
    expect(a.respond_to?(:blah)).to be_truthy
    expect(a.respond_to?(:blah=)).to be_truthy
    expect(a.method(:blah=).call(42)).to eq(42)
    expect(a.method(:blah).call).to eq(42)
  end

  it 'tests test_raises_with_bang' do
    a = Turnout::OrderedOptions.new
    a[:foo] = :bar
    expect(a.respond_to?(:foo)).to be_truthy
    expect { a.foo! }.to_not raise_error
    expect(a.foo).to eq(a.foo!)

    expect {
      a.foo = nil
      a.foo!
    }.to raise_error(RuntimeError)
    expect { a.non_existing_key! }.to raise_error(KeyError)
  end


  it 'tests test_raises_with_bang' do
    hash = {key: :value}
    fake =  double(to_hash: hash)
    a = Turnout::OrderedOptions.new(fake) do |key, value|
      hash[key]
    end
    expect(a).to eq({:key=>:value})
  end
end
