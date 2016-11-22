RSpec::Matchers.define :closely_resemble_html do |expected|
  def trim_html(html, xpath_removals: [], css_removals: [])
    doc = Nokogiri::HTML(html.gsub(/&nbsp;/i,""))
    xpath_removals.each do |xpath|
      doc.xpath(xpath).remove
    end
    css_removals.each do |css|
      doc.css(css).remove
    end

    # Sort css classes alphabetically in case order differs
    doc.css("*").each do |element|
      classes = element.attribute("class").try(:value)
      next unless classes
      element.set_attribute("class", classes.split(" ").sort.join(" "))
    end
    doc.css("img").each do |element|
      src = element.attribute("src").try(:value)
      next unless src
      element.set_attribute("src", src.split("/").last.split("?").first)
    end
    doc.css("meta").each do |element|
      content = element.attribute("content").try(:value)
      next unless content
      element.set_attribute("content", content.split("/").last.split("?").first)
    end
    html = doc.to_s
    html.gsub("\n", "").gsub("<", "\n<").gsub(/ +/, " ").gsub(/\s$/, "")
  end

  match do |actual|
    @actual = trim_html(actual, xpath_removals: @xpath_removals.to_a,
                                css_removals: @css_removals.to_a)
    @expected = trim_html(expected, xpath_removals: (@other_xpath_removals || @xpath_removals).to_a,
                                    css_removals: (@other_css_removals || @css_removals).to_a)
    @expected == @actual
  end

  description do
    "closely_resemble_html(#{@expected})"
  end

  failure_message do |text|
    "expected #{@actual} \n\n\nto closely resemble\n\n\n #{@expected}"
  end

  failure_message_when_negated do |text|
    "expected #{@actual} \n\n\nto not closely resemble\n\n\n #{@expected}"
  end

  def diffable?
    true
  end

  chain(:with_css_removals) { |receiver| @css_removals = receiver }
  chain(:with_xpath_removals) { |receiver| @xpath_removals = receiver }
  chain(:and_css_removals) {|receiver| @other_css_removals = receiver }
  chain(:and_xpath_removals) {|receiver| @other_xpath_removals = receiver }

end