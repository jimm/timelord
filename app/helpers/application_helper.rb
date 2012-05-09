# Note: if ApplicationHelper gets more methods, should probably extract
# money_str from that class instead of including everything in Invoice.

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

  def export_link(text, format, invoice)
    link_to text, :controller => invoice_path, :action => 'preview', :format => format, :year => invoice.year, :month => invoice.month, :discount_pct => invoice.discount_pct
  end
end
