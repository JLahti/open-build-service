# ==============================================================================
# The WebPage class contains basic browsing functionality and common properties
# for all web-pages. 
#
class WebPage

  include Assertions
  
  
  # ============================================================================
  # @see #initialize
  #
  def self.new web_driver, options={}
    page = allocate
    page.send :initialize, web_driver, options
    page.restore
    page.validate_page
    page
  end
  
  
  # ============================================================================
  # @see #initialize_ready
  #
  def self.new_ready web_driver
    page = allocate
    page.send :initialize_ready, web_driver
    page.validate_page
    page
  end
  
  
  # ============================================================================
  # Validates that the content displayed by the browser
  # matches the expected page.
  #

  # ============================================================================
  # (see WebPage#validate_page)
  #
  def validate_page
    assert @driver != nil
  end
   
  
  # ============================================================================
  # Refreshes the web-page and sleeps for one second.
  #
  def refresh_page
    @driver.navigate.refresh
    sleep 1
  end
  
  
  # ============================================================================
  # Creates new web-page object and navigates 
  # @param [WebDriver] web_driver the browser object that will be used to create
  #   the webpage. Must be properly initialized before passed as argument.
  # @see #new
  #
  def initialize web_driver, options={}
    @driver = web_driver
  end
  
  
  # ============================================================================
  # Creates new web-page object from an initialized browser object.
  # @param [WebDriver] web_driver the browser object that will be used to create
  #   the webpage. Must be properly initialized before passed as argument.
  # @see #new_ready
  #
  def initialize_ready web_driver
    @driver = web_driver
  end
  
  
  def navigate_to page, options={}
    $page = page.new @driver, options 
  end
  
  
  def restore
  end
  
  
  def close
    @driver.quit
    @driver = nil
  end
  
  
  # ============================================================================
  # Saves a screenshot of the current web-page.
  # @param [String] path the path for the new screenshot.
  # @note Saves the whole canvas of the web-page, not just the part of it that's 
  # actually displayed on screen. So the actual size of the browser and the 
  # scrolling don't affect the screenshot.
  #
  def save_screenshot path
    @driver.save_screenshot path
  end
  
  
end
