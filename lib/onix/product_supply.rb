require 'onix/price'

module ONIX

  class MarketDate < Subset
    attr_accessor :role, :date
    def parse(market_date)
      @role = MarketDateRole.from_code(market_date.at_xpath("./MarketDateRole").text)
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

        market_publishing.xpath("./MarketDate").each do |market_date|
        @market_dates << MarketDate.from_xml(market_date)
      end
    end

  end

  class SupplyDate < Subset
    attr_accessor :role, :date
    def parse(supply_date)
      @role = SupplyDateRole.from_code(supply_date.at_xpath("./SupplyDateRole").text)
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

      if supply.at_xpath("./ProductAvailability")
        @availability=ProductAvailability.from_code(supply.at_xpath("./ProductAvailability").text)
      end

      supply.xpath("./SupplyDate").each do |supply_date|
        @supply_dates << SupplyDate.from_xml(supply_date)
      end

      supply.xpath("./Price").each do |pr|
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
      product_supply.xpath("./SupplyDetail").each do |sd|
        @supply_details << SupplyDetail.from_xml(sd)
      end

      product_supply.xpath("./Market").each do |mk|
        @markets << Market.from_xml(mk)
      end


      market_publishing = product_supply.at_xpath("./MarketPublishingDetail")

      if market_publishing
        @market_publishing_detail = MarketPublishingDetail.from_xml(market_publishing)
      end
    end


  end

end