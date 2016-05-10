module ONIX
  # TEST
  require 'dbm'
  class ONIXDBM
    attr_accessor :db

    def initialize(db_file='store.dbm')
      @db = DBM.open(db_file)
    end

    def store(message, source=nil)
      refs=[]
      message.products.each do |p|
        p.identifiers.each do |id|
          @db["identifier_#{id.value}"]=p.record_reference
        end
        refs << p.record_reference
        @db["product_"+p.record_reference]=Marshal.dump(p)
      end
    end

    def find(id)
      Marshal.load(@db["product_"+@db["identifier_#{id}"]])
    end

    def close
      @db.close
    end

  end
end