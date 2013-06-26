require 'onix/price'

module ONIX

  class MarketDate < Subset
    attr_accessor :role, :date
    def parse(market_date)
      @role = MarketDateRole.from_code(market_date.at("./MarketDateRole").text)
      @date = Helper.parse_date(market_date)
    end
  end

  class Market < Subset
    attr_accessor :territory


    def parse(market)
      if market.at("./Territory")
        @territory=Territory.from_xml(market.at("./Territory"))
      end
    end
  end

  class MarketPublishingDetail < Subset
    attr_accessor :publisher_representatives, :market_dates

    def initialize
      @publisher_representatives=[]
      @market_dates = []
    end

    def availability_date
      av=@market_dates.select{|sd| sd.role.human=="PublicationDate" || sd.role.human=="EmbargoDate"}.first
      if av
        av.date
      else
        nil
      end
    end

    def parse(market_publishing)

        @publisher_representatives=Agent.parse_entities(market_publishing,"./PublisherRepresentative")

        market_publishing.search("./MarketDate").each do |market_date|
        @market_dates << MarketDate.from_xml(market_date)
      end
    end

  end

  class SupplyDate < Subset
    attr_accessor :role, :date
    def parse(supply_date)
      @role = SupplyDateRole.from_code(supply_date.at("./SupplyDateRole").text)
      @date = Helper.parse_date(supply_date)
    end
  end

  class SupplyDetail < Subset
    attr_accessor :availability, :suppliers, :supply_dates, :prices

    def initialize
      @suppliers=[]
      @supply_dates=[]
      @prices=[]
    end

    def distributors
      @suppliers.select{|s| s.role.human=~/Distributor/}.uniq
    end

    def available?
      @availability.human=="Available"
    end

    def availability_date
      av=@supply_dates.select{|sd| sd.role.human=="ExpectedAvailabilityDate" || sd.role.human=="EmbargoDate"}.first
      if av
        av.date
      else
        nil
      end
    end

    def parse(supply)

      @suppliers = Supplier.parse_entities(supply, "./Supplier")

      if supply.at("./ProductAvailability")
        @availability=ProductAvailability.from_code(supply.at("./ProductAvailability").text)
      end

      supply.search("./SupplyDate").each do |supply_date|
        @supply_dates << SupplyDate.from_xml(supply_date)
      end

      supply.search("./Price").each do |pr|
        @prices << Price.from_xml(pr)
      end
    end
  end

  class ProductSupply < Subset
    attr_accessor :supply_details, :markets, :market_publishing_detail

    def initialize
      @supply_details=[]
      @markets=[]
    end

    def distributors
      @supply_details.map{|sd| sd.distributors}.flatten.uniq{|d| d.name}
    end

    def available_supply_details
      @supply_details.select{|sd| sd.available?}
    end

    def unavailable_supply_details
      @supply_details.delete_if{|sd| sd.available?}
    end

    def available?
      self.available_supply_details.length > 0
    end

    def parse(product_supply)
      product_supply.search("./SupplyDetail").each do |sd|
        @supply_details << SupplyDetail.from_xml(sd)
      end

      product_supply.search("./Market").each do |mk|
        @markets << Market.from_xml(mk)
      end


      market_publishing = product_supply.at("./MarketPublishingDetail")

      if market_publishing
        @market_publishing_detail = MarketPublishingDetail.from_xml(market_publishing)
      end
#      market = product_supply.at("./Market")
#      market_publishing = product_supply.at("./MarketPublishingDetail")

#      if market_publishing
#        market_publishing.search("./PublisherRepresentative").each do |representative|
#          @publisher_representatives << Agent.from_hash({:name => representative.at("./AgentName").text,
#                                        :role => AgentRole.from_code(representative.at("./AgentRole").text),
#                                        :identifiers => Identifier.parse_identifiers(representative, "Agent")})
#        end
#      end
#      {:type => status, :publisher_representatives => publisher_representatives, :suppliers => suppliers, :supply_dates => supply_dates, :prices => prices}
    end


  end

end