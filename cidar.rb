require 'nokogiri'
require 'open-uri'
require 'sinatra' 
require 'json'


SERVER_URL = 'http://172.18.20.31:8153/go/cctray.xml'
CLOJURE_SERVER_URL = 'http://localhost:9876'

get '/git/*' do
  url = CLOJURE_SERVER_URL + request.url.scan(/git(\/.*)/).first.first
  open(url).read
end

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
  def buildLabel; strip_runs @node['lastBuildLabel'] end
  
  def commit_message
    puts "Getting message for "+@node['webUrl']
    get_commit_message_from_url(@node['webUrl'])  
  end
  
  def commiters
    puts "Getting commiters for "+commit_message
    commitersJson = open(URI.escape(CLOJURE_SERVER_URL + '/commiters.json?message="' + commit_message + '"')).read
    JSON.parse(commitersJson)
  end
  
  
  private
  def strip_runs(buildLabel); buildLabel.gsub(/\s.*/, '') end
  
  def get_commit_message_from_url (url)
    web_html = Nokogiri::HTML(open(url))
    comments = web_html.css(".comment dl dd")
    return (comments && comments.length > 0) ? comments.first.text : ""
  end
  
end
