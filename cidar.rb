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
end

class Status
  def initialize(node); @node = node end
  def success?; @node['lastBuildStatus'] == "Success" end
  def building?; @node['activity'] == "Building" end  
end
