require 'fileutils'
require 'pathname'
require 'tempfile'
require "digest/sha1"
require "uri"


module OpenidEngine::Store
  class Filesystem
    DIRNAME = {
      :nonce => 'nonces', :assoc => 'assocs', :tmp => 'tmp'
    }
    # FIELD_ORDER =
    #   [:version, :handle, :secret, :issued, :lifetime, :assoc_type,]
    
    def initialize(dir)
      @dir = Pathname.new(dir)
      # make dir
      [:nonce, :assoc, :tmp].each { |what| FileUtils::mkdir_p dir_of(what) }
    end
    
    def dir_of(key)
      @dir.join DIRNAME[key]
    end
    
    def assocfilepath(op_endpoint, assoc_handle=nil)
      u = URI.parse op_endpoint
      dir_of(:assoc).join
        [u.scheme, u.host, hash(op_endpoint), (assoc_handle ? hash(assoc_handle) : '')].join('-')
    end
    
    def hash(s)
      Digest::SHA1.hexdigest(s)
    end
    
    def store_assoc(op_endpoint, assoc)
      # serialized = assoc.serialize
      tmp = Tempfile.new 'tmp', dir_of(:tmp)
      begin
        tmp.write("serialized assoc") #FIXME
        tmp.fsync
      ensure
        tmp.close
      end
      File.rename f.path, assocfilepath(op_endpoint, assoc.handle) #FIXME
    end
    
    def get_assoc(op_endpoint, assoc_handle=nil)
      raise "not implemented yet"
    end

  end
end
