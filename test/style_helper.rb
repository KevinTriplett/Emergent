# ref https://medium.com/@TheSunwave/testing-your-css-styles-with-capybara-556022e0076d
# ./spec/support/style_helper.rb
module StyleHelper
  def computed_style(selector, pseudo = nil, prop)
    js = "window.getComputedStyle(document.querySelector(\"#{selector}\"), '#{pseudo}').getPropertyValue('#{prop}')"
    page.evaluate_script(js)
  end
end