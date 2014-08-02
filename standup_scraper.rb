require 'phantomjs' # <-- Not required if your app does Bundler.require automatically (e.g. when using Rails)
require 'rest-client'
require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'
require 'nokogiri'
require 'pry'
require 'active_support/all'
puts Phantomjs.path

phantom_options = {
  js_errors: false,
  debug: true,
  phantomjs: Phantomjs.path,
  phantomjs_options:  ['--ignore-ssl-errors=yes']
}

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantom_options)
end
Capybara.default_wait_time =10

Capybara.default_driver = :poltergeist
Capybara.run_server = false

class StandupFetcher
  include Capybara::DSL

  def initialize(url)
    @url = url
    @base_selector = ".TM-Calendar"
  end

  def parse_calendar(html)
    calendar_cells = Nokogiri::HTML(html).css('.TM-Calendar td')
    calendar_cells.each do |item|
     puts item.text.squish
    end
  end
  def get_site
    visit @url
    page_data = find(@base_selector)
    #this forces capybara to wait
    #till table loads
    parse_calendar(page.html)
  end

end

fetcher = StandupFetcher.new('http://www.standupny.com/calendar/')
fetcher.get_site
