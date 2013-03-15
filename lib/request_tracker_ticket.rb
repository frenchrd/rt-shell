class RequestTrackerTicket < RequestTrackerBase
  class << self
    def find(id)
      superclass.find("ticket/#{id}")
    end

    def find_history(id)
      superclass.find("ticket/#{id}/history?format=l")
    end

    def find_history_replys(id)
      results = superclass.find("ticket/#{id}/history?format=l")
      results.select{|t|t["Type"] == "EmailRecord"}
    end

    def find_by_requestor_email(email)
      url = URI.escape "search/ticket?query=Requestor.EmailAddress = '#{email}'&format=l"
      results = superclass.find(url)
    end
  end
end
