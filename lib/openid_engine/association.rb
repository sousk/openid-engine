module OpenidEngine
  class Association
    def initialize(repository)
      @repository = repository
    end
    
    def find(options)
      @repository.find :first, options
    end
    
    def request(op_endpoint)
      
    end
  end
end
