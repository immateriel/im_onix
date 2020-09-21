module ONIX
  # flattened supplies extractor
  module ProductSuppliesExtractor
    # class must define a product_supplies returning an Array of objects responding to :
    # - availability_date (Date)
    # - countries (country code Array)

    # @!group High level

    # flattened supplies with prices
    #
    # supplies is a hash symbol array in the form :
    #   [{:available=>bool,
    #     :availability_date=>date,
    #     :including_tax=>bool,
    #     :currency=>string,
    #     :territory=>string,
    #     :suppliers=>[Supplier,...],
    #     :prices=>[{:amount=>int,
    #                :from_date=>date,
    #                :until_date=>date,
    #                :tax=>{:amount=>int, :rate_percent=>float}}]}]
    def supplies(keep_all_prices_dates = false)
      supplies = []

      # add territories if missing
      if self.product_supplies
        self.product_supplies.each do |ps|
          ps.supply_details.each do |sd|
            sd.prices.each do |p|
              supply = {}
              supply[:suppliers] = sd.suppliers
              supply[:available] = sd.available?
              supply[:availability_date] = sd.availability_date

              unless supply[:availability_date]
                if ps.availability_date
                  supply[:availability_date] = ps.market_publishing_detail.availability_date
                end
              end
              supply[:price] = p.amount
              supply[:qualifier] = p.qualifier.human if p.qualifier
              supply[:including_tax] = p.including_tax?
              if !p.territory or p.territory.countries.length == 0
                supply[:territory] = []
                supply[:territory] = ps.countries

                if supply[:territory].length == 0
                  if @publishing_detail
                    supply[:territory] = self.countries_rights
                  end
                end
              else
                supply[:territory] = p.territory.countries
              end
              supply[:from_date] = p.from_date
              supply[:until_date] = p.until_date
              supply[:currency] = p.currency
              supply[:tax] = p.tax

              unless supply[:availability_date]
                if @publishing_detail
                  supply[:availability_date] = @publishing_detail.publication_date
                end
              end

              supplies << supply
            end
          end
        end
      end

      grouped_supplies = {}
      supplies.each do |supply|
        supply[:territory].each do |territory|
          pr_key = "#{supply[:available]}_#{supply[:including_tax]}_#{supply[:currency]}_#{territory}"
          grouped_supplies[pr_key] ||= []
          grouped_supplies[pr_key] << supply
        end
      end

      nb_suppliers = supplies.map { |s| s[:suppliers][0].name }.uniq.length
      # render prices sequentially with dates
      grouped_supplies.each do |ksup, supply|
        if supply.length > 1
          global_price = supply.select { |p| not p[:from_date] and not p[:until_date] }
          global_price = global_price.first

          if global_price
            if nb_suppliers > 1
              grouped_supplies[ksup] += self.prices_with_periods(supply, global_price)
            else
              grouped_supplies[ksup] = self.prices_with_periods(supply, global_price)
            end
            grouped_supplies[ksup].uniq!
          else
            # remove explicit from date
            explicit_from = supply.select { |p| p[:from_date] and not supply.select { |sp| sp[:until_date] and sp[:until_date] <= p[:from_date] }.first }.first
            if explicit_from
              explicit_from[:from_date] = nil unless keep_all_prices_dates
            end
          end
        else
          supply.each do |s|
            if s[:from_date] and s[:availability_date] and s[:from_date] >= s[:availability_date]
              s[:availability_date] = s[:from_date]
            end
            s[:from_date] = nil unless keep_all_prices_dates
          end
        end
      end

      # merge by territories
      grouped_territories_supplies = {}
      grouped_supplies.each do |ksup, supply|
        fsupply = supply.first
        pr_key = "#{fsupply[:available]}_#{fsupply[:including_tax]}_#{fsupply[:currency]}"
        supply.each do |s|
          pr_key += "_#{s[:price]}_#{s[:from_date]}_#{s[:until_date]}"
        end
        grouped_territories_supplies[pr_key] ||= []
        grouped_territories_supplies[pr_key] << supply
      end

      supplies = []

      grouped_territories_supplies.each do |ksup, supply|
        fsupply = supply.first.first
        supplies << {:including_tax => fsupply[:including_tax], :currency => fsupply[:currency],
                     :territory => supply.map { |fs| fs.map { |s| s[:territory] } }.flatten.uniq,
                     :available => fsupply[:available],
                     :availability_date => fsupply[:availability_date],
                     :suppliers => fsupply[:suppliers],
                     :prices => supply.first.map { |s|

                       s[:amount] = s[:price]
                       s.delete(:price)
                       s.delete(:available)
                       s.delete(:currency)
                       s.delete(:availability_date)
                       s.delete(:including_tax)
                       s.delete(:territory)
                       s
                     }}
      end

      supplies
    end

    # add missing periods when they can be guessed
    def prices_with_periods(supplies, global_supply)
      complete_supplies = supplies.select { |supply| supply[:from_date] && supply[:until_date] }.sort_by { |supply| supply[:from_date] }
      missing_start_period_supplies = supplies.select { |supply| supply[:from_date] && !supply[:until_date] }.sort_by { |supply| supply[:from_date] }
      missing_end_period_supplies = supplies.select { |supply| !supply[:from_date] && supply[:until_date] }.sort_by { |supply| supply[:until_date] }

      return [global_supply] if [complete_supplies, missing_start_period_supplies, missing_end_period_supplies].all? { |supply| supply.empty? }

      return self.add_missing_periods(complete_supplies, global_supply) unless complete_supplies.empty?

      without_start = missing_start_period_supplies.length == 1 && complete_supplies.empty? && missing_end_period_supplies.empty?
      without_end = missing_end_period_supplies.length == 1 && complete_supplies.empty? && missing_start_period_supplies.empty?

      return self.add_starting_period(missing_start_period_supplies.first, global_supply) if without_start
      return self.add_ending_period(missing_end_period_supplies.first, global_supply) if without_end

      [global_supply]
    end

    def add_missing_periods(supplies, global_supply)
      new_supplies = []

      supplies.each.with_index do |supply, index|
        new_supplies << global_supply.dup.tap { |start_sup| start_sup[:until_date] = supply[:from_date] - 1 } if index == 0

        if index > 0 && index != supplies.length
          new_supplies << global_supply.dup.tap do |missing_supply|
            missing_supply[:from_date] = supplies[index - 1][:until_date] + 1
            missing_supply[:until_date] = supply[:from_date] - 1
          end
        end

        new_supplies << supply

        new_supplies << global_supply.dup.tap { |end_sup| end_sup[:from_date] = supply[:until_date] + 1 } if index == supplies.length - 1
      end

      new_supplies
    end

    def add_starting_period(supply, global_supply)
      missing_supply = global_supply.dup
      missing_supply[:until_date] = supply[:from_date] - 1

      [missing_supply, supply]
    end

    def add_ending_period(supply, global_supply)
      missing_supply = global_supply.dup
      missing_supply[:from_date] = supply[:until_date] + 1

      [supply, missing_supply]
    end

    # flattened supplies only including taxes
    def supplies_including_tax
      self.supplies.select { |p| p[:including_tax] }
    end

    # flattened supplies only excluding taxes
    def supplies_excluding_tax
      self.supplies.select { |p| not p[:including_tax] }
    end

    # flattened supplies with default tax (excluding tax for US and CA, including otherwise)
    def supplies_with_default_tax
      self.supplies_including_tax + self.supplies_excluding_tax.select { |s| ["CAD", "USD"].include?(s[:currency]) }
    end

    # flattened supplies for country
    def supplies_for_country(country, currency = nil)
      country_supplies = self.supplies
      if currency
        country_supplies = country_supplies.select { |s| s[:currency] == currency }
      end
      country_supplies.select { |s|
        if s[:territory].include?(country)
          true
        else
          false
        end
      }
    end

    # price amount for given +currency+ and country at time
    def at_time_price_amount_for(time, currency, country = nil)
      sups = self.supplies_with_default_tax.select { |p| p[:currency] == currency }
      if country
        sups = sups.select { |p| p[:territory].include?(country) }
      end
      if sups.length > 0
        # exclusive
        sup = sups.first[:prices].select { |p|
          (!p[:from_date] or p[:from_date].to_date <= time.to_date) and
              (!p[:until_date] or p[:until_date].to_date > time.to_date)
        }.first

        if sup
          sup[:amount]
        else
          # or inclusive
          sup = sups.first[:prices].select { |p|
            (!p[:from_date] or p[:from_date].to_date <= time.to_date) and
                (!p[:until_date] or p[:until_date].to_date >= time.to_date)
          }.first

          if sup
            sup[:amount]
          else
            nil
          end
        end

      else
        nil
      end
    end

    # current price amount for given +currency+ and country
    def current_price_amount_for(currency, country = nil)
      at_time_price_amount_for(Time.now, currency, country)
    end

    # @!endgroup
  end
end