module ApplicationHelper

  def money_str(cents)
    return '' unless cents

    ms = '%03d' % cents
    dollars, cents = ms[0..-3], ms[-2..-1]
    cents = cents.to_i || 0
    dollars = dollars.reverse.gsub(/(\d\d\d)/, '\1,').reverse.sub(/^,/, '')
    dollars = '0' if dollars == ''
    "$#{dollars}.#{'%02d' % cents.to_i}"
  end
end
