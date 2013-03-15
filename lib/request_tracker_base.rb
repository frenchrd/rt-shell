class RequestTrackerBase
  class << self
    def login(username, password)
      r = RestClient.post 'https://rt.ccs.ornl.gov/', :user => username, :pass => password
      raise "Error logging in" if r.include? "Your username or password is incorrect"
      cookie = r.headers[:set_cookie].first
      @resource = RestClient::Resource.new("https://rt.ccs.ornl.gov/REST/1.0",
        :verify_ssl => OpenSSL::SSL::VERIFY_NONE,
        :headers    => { "Cookie" => cookie }
      )
    end

    def resource
      if defined?(@resource)
        @resource
      elsif superclass != Object && superclass.resource
        superclass.resource
      else
        @resource ||= {}
      end
    end

    def find(url)
      to_hash(resource[url].get)
    end

    def to_hash(response)
      results = [ Hash.new ]
      last_key = ""
      response.split("\n").each do |l|
        if l =~ /^(\S*?):(.*)/
          key   = $1.strip
          value = $2.strip
          last_key = key
          results.last[key]=value

          #time = Time.parse(value) rescue nil
          #results.last[key]=time if time.class == Time
        else
          next if l =~ /^RT\//
          next if l.empty?
          next if l =~ /^#/
          if l =~ /^--$/
            results << {}
            next
          end

          results.last[last_key] << "\n"+l
        end
      end
      return results
    end
  end

end
