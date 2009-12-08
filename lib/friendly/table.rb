class Table
  attr_reader :datastore

  def initialize(datastore)
    @datastore = datastore
  end

  def table_name
    raise NotImplementedError, "#{self.class.name}#table_name is not implemented."
  end

  def create(document)
    raise NotImplementedError, "#{self.class.name}#create is not implemented."
  end

  def update(document)
    raise NotImplementedError, "#{self.class.name}#update is not implemented."
  end

  def first(conditions)
    raise NotImplementedError, "#{self.class.name}#first is not implemented."
  end

  def all(conditions)
    raise NotImplementedError, "#{self.class.name}#all is not implemented."
  end

  def satisfies?(conditions)
    raise NotImplementedError, "#{self.class.name}#satisfies? is not implemented."
  end
end

