module Invoice::NumberGuesser
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # In addition to a simple enumeration we support most patterns of the form
    # year + separator + code (or its reverse), including
    #
    #   0003/2007, used by ana
    #   07_0003,   used by pei
    #   F4-2007,   used by cabreramc
    #   2007/3,    used by fxn
    #
    # The basic heuristic is to try to identify the year first, and then
    # apply our custom String#isucc to the other part, see environment.rb.
    # It would be too confusing to explain the details here, please follow
    # the code.
    #
    # This is tested in test/unit/number_guesser_test.rb, please maintain
    # that test suite if unknown patterns arise and we add support for them.
    def guess_next_number(account)
      invoices = account.last_invoices(2)
      invoices.pop if invoices.size == 2 && invoices.first.year != invoices.last.year
      logger.debug("guessing next invoice from #{invoices.map(&:number).join(" and ")}.")
      guess_next_number_aux(invoices.map(&:number))
    end

    private

    # Expects an array of invoice numbers, always as strings, most recent first.
    def guess_next_number_aux(numbers)
      current_year = Date.today.year.to_s

      # This is our default if the account has no invoices.
      return "#{current_year}_0001" if numbers.empty?

      # Convenience array for include? testing below.
      years = []
      0.upto(3) {|i| years << current_year[i..3]}

      # Break the number in parts and select the numeric ones as strings.
      parts = numbers.first.scan(INVOICE_NUMBER_REGEXP)
      ints = []
      parts.each_with_index {|p, i| ints << [p, i] if p =~ /^\d+$/}

      case ints.length
      when 0
        # Unlikely, this means there's no digit and there are separators, as in FG-HT.
        return numbers.first.isucc
      when 1
        # Increment that number as string.
        parts[ints[0][1]].isucc!
        return parts.join('')
      when 2
        if years.include?(ints[0][0]) && !years.include?(ints[1][0])
          parts[ints[1][1]].isucc!
          return parts.join('')
        elsif !years.include?(ints[0][0]) && years.include?(ints[1][0])
          parts[ints[0][1]].isucc!
          return parts.join('')
        elsif !years.include?(ints[0][0]) && !years.include?(ints[1][0])
          parts[ints[1][1]].isucc! # TODO: can we do better?
          return parts.join('')
        else
          parts2 = numbers.last.scan(INVOICE_NUMBER_REGEXP)
          ints2 = []
          parts2.each_with_index {|p, i| ints2 << [p, i] if p =~ /^\d+$/}
          if 2 == ints.length
            if ints[0][0] == ints2[0][0] # year in first integer
              parts[ints[1][1]].isucc!
              return parts.join('')
            elsif ints[1][0] == ints2[1][0] # year in second integer
              parts[ints[0][1]].isucc!
              return parts.join('')
            end
          end
        end
      end
      return nil
    end

  end # ClassMethods
end # InvoiceNumberGuesser
