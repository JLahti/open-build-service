# ==============================================================================
# 
#
class PackageRawConfigPage < PackagePage


  # ============================================================================
  # (see WebPage#validate_page)
  #
  def validate_page
    super
    assert @url.start_with? $data[:url] + "/package/meta"
  end
  

  # ============================================================================
  # (see WebPage#initialize)
  #
  def initialize web_driver, options={}
    super
    @url = $data[:url] + "/package/meta"
    @url += "?package=#{@package}&project=#{CGI.escape(@project)}"
  end
  

  # ============================================================================
  # (see WebPage#initialize_ready)
  #
  def initialize_ready web_driver
    super
    @url = @driver.current_url
  end

end
