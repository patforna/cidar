require 'nokogiri'
require 'open-uri'
require 'sinatra' 

SERVER_URL = 'http://172.18.20.31:8153/go/cctray.xml'

get '/' do
  @doc = Nokogiri::XML(open(SERVER_URL))
  erb :index
end

helpers do
  def status_of(project)
    @status = Status.new(@doc.xpath("//Project[@name='#{project}']").first)
    erb 'status <%= if @status.success? then "success" else "failure" end %><%= " building" if @status.building? %>'
  end
  
  def commit_message(project)
    project_node = @doc.xpath("//Project[@name='#{project}']").first
    web_url = project_node['webUrl']
    message = get_commit_message_from_url(web_url)
    trimmed_message = (message.length < 30) ? message : message.slice(0, 27) + "..."
    erb "#{trimmed_message}"
  end
  
  def get_commit_message_from_url (url)
    web_html = Nokogiri::HTML(open(url))
    comments = web_html.css(".comment dl dd")
    return (comments && comments.length > 0) ? comments.first.text : ""
  end
end

class Status
  def initialize(node); @node = node end
  def success?; @node['lastBuildStatus'] == "Success" end
  def building?; @node['activity'] == "Building" end
  def buildLabel; strip_runs @node['lastBuildLabel'] end
  
  private
  def strip_runs(buildLabel); buildLabel.gsub(/\s.*/, '') end
end
