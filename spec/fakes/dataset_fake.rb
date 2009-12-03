class DatasetFake
  attr_accessor :where, :insert, :inserts, :first

  def initialize(opts = {})
    opts.each { |k,v| send("#{k}=", v) }
    @inserts ||= []
  end

  def where(conditions)
    @where[conditions]
  end

  def insert(attributes)
    inserts << attributes
    @insert
  end

  def first(conditions)
    @first[conditions]
  end
end

