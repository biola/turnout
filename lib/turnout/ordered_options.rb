module Turnout
  class OrderedOptions < Hash
    alias_method :_get, :[] # preserve the original #[] method
    protected :_get # make it protected

    def initialize(constructor = {}, &block)
      if constructor.respond_to?(:to_hash)
        super()
        update(constructor, &block)
        hash = constructor.to_hash

        self.default = hash.default if hash.default
        self.default_proc = hash.default_proc if hash.default_proc
      else
        super()
      end
    end

    def update(other_hash)
      if other_hash.is_a? Hash
        super(other_hash)
      else
        other_hash.to_hash.each_pair do |key, value|
          if block_given?
            value = yield(key, value)
          end
          self[key] = value
        end
        self
      end
    end

    def []=(key, value)
      super(key.to_sym, value)
    end

    def [](key)
      super(key.to_sym)
    end

    def method_missing(name, *args)
      name_string = name.to_s
      if name_string.chomp!('=')
        self[name_string] = args.first
      else
        bangs = name_string.chomp!('!')

        if bangs
          value = fetch(name_string.to_sym)
          raise(RuntimeError.new("#{name_string} is blank.")) if value.nil? || value.empty?
          value
        else
          self[name_string]
        end
      end
    end

    def except(*keys)
      dup.except!(*keys)
    end

    def except!(*keys)
      keys.each { |key| delete(key) }
      self
    end


    def respond_to_missing?(name, include_private)
      true
    end
  end


  # +InheritableOptions+ provides a constructor to build an +OrderedOptions+
  # hash inherited from another hash.
  #
  # Use this if you already have some hash and you want to create a new one based on it.
  #
  #   h = ActiveSupport::InheritableOptions.new({ girl: 'Mary', boy: 'John' })
  #   h.girl # => 'Mary'
  #   h.boy  # => 'John'
  class InheritableOptions < Turnout::OrderedOptions
    def initialize(parent = nil)
      if parent.kind_of?(Turnout::OrderedOptions)
        # use the faster _get when dealing with OrderedOptions
        super(parent) {|key,value| parent._get(key) }
      elsif parent
        super(parent) { |key, value| parent[key] }
      else
        super(parent)
      end
    end

    def inheritable_copy
      self.class.new(self)
    end
  end
end
