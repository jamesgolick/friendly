namespace :friendly do
  task :build_index do
    klass  = ENV['KLASS'].constantize
    fields = ENV['FIELDS'].split(',').map { |f| f.to_sym }
    Friendly::Indexer.populate(klass, *fields)
  end
end
