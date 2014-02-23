require 'rubygems'
require 'mechanize'

class GettyScraper

  def initialize( config = { uagent: "Mac Safari" } )
    @config = config
    @agent = Mechanize.new do |a|
      a.user_agent_alias = config[:uagent]
      a.history.max_size = 1
    end
  end

  def download_image( id )
    # Formats Path for Getty's Cloudfront/S3 Bucket filenames
    path = sprintf('%06d', id.to_i) + '01.jpg'
    link = "http://d2hiq5kf5j4p5h.cloudfront.net/#{path}"
    puts "Getting Image at #{link}" # , number #{index} of #{ids.length}"
    return @agent.get(link) #.save "g-images/#{id}.jpg"
  end

  def save_image( mechanize_image, path )
    mechanize_image.save(path)
  end

  def load_info( id )
    begin
      link = "http://search.getty.edu/museum/records/musobject?objectid=#{id}"
      puts "Getting Info for #{id}"
      page = @agent.get link
    rescue Exception => e
      puts e
    else
      data = {}
      data["title"] = page.search("#cs-results-a h1").text.strip
      page.search('.cs-result-data.cs-result-data-brief tr').each do |tr|
        data[tr.search('.cs-label p').text.strip] = tr.search('.cs-value p').text.strip
      end
      data["ID"] = "#{id}"
      return data
    end
  end

end
