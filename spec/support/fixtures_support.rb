def view
  # if @view
  #   @view
  # else
    @view ||= ActionView::Base.new("spec/fixtures")
  #   class << @view
  #
  #   end
  # end
end

def render_template_and_compare_to_fixture(partial, locals={})
  rendered = view.render partial: partial.to_s, locals: locals
  expected = view.render partial: "rendered/#{partial}", locals: locals
  expect(rendered).to closely_resemble_html(expected)

  rendered
end