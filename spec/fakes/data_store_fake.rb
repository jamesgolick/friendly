class DataStoreFake
  attr_writer :insert, :all, :first
  attr_reader :inserts

  def initialize(opts = {})
    opts.each { |k,v| send("#{k}=", v) }
    @inserts = []
  end

  def insert(*args)
    @inserts << args
    @insert
  end

  def all(*args)
    @all[args]
  end

  def first(*args)
    @first[args]
  end
end

