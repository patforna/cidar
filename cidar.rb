require 'nokogiri'
require 'open-uri'
require 'sinatra' 
require 'json'


SERVER_URL = 'http://172.18.20.31:8153/go/cctray.xml'
CLOJURE_SERVER_URL = 'http://172.18.20.40:9876'

get '/git/*' do
  url = CLOJURE_SERVER_URL + request.url.scan(/git(\/.*)/).first.first
  open(url).read
end

get '/' do
  @doc = Nokogiri::XML(open(SERVER_URL))
  @end_to_end_times = JSON.parse(open(CLOJURE_SERVER_URL + "/end-to-end-times.json").read)
  erb :index
end

helpers do
  def status_of(project)
    # puts "getting status for #{project}."    
    @status = Status.new(@doc.xpath(".//Project[regex(., '^#{project}$')]", Class.new {
      def regex node_set, regex
        node_set.find_all { |node| node['name'] =~ /#{regex}/ }
      end
    }.new), @end_to_end_times)
    erb 'status <%= if @status.success? then "success" else "failure" end %><%= " building" if @status.building? %>'
  end
  
end

class Status
  def initialize(nodes, end_to_end_times)
    # puts "nodes: #{nodes}"    
    @nodes = nodes
    @end_to_end_times = end_to_end_times
  end
  
  def success?
    @nodes.all? { |node| node['lastBuildStatus'] == "Success" }
  end
  
  def building?
    @nodes.any? { |node| node['activity'] == "Building" }
  end
  
  def buildLabel
    strip_runs @nodes.first['lastBuildLabel']
  end
  
  def commit_message
    get_commit_message_from(@nodes.first['webUrl'])  
  end
  
  def commiters
    commitersJson = open(URI.escape(CLOJURE_SERVER_URL + '/commiters.json?message="' + commit_message + '"')).read
    JSON.parse(commitersJson).take(2)
  end
  
  def fastest_time(pipeline)
    seconds = @end_to_end_times[pipeline]["fastest"]["time"]
    format('%02d:%02d', seconds/60, seconds%60)
  end
  
  
  private
  def strip_runs(buildLabel)
    buildLabel.gsub(/\s.*/, '')
  end
  
  def get_commit_message_from(url)
    web_html = Nokogiri::HTML(open(url))
    comments = web_html.css(".comment dl dd")
    return (comments && comments.length > 0) ? comments.first.text : ""
  end
  
end
