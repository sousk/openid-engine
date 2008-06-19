require 'rexml/document'

module OpenidEngine
  class Yadis
    class Document < REXML::Document
      XRDS_NS = 'xri://$xrds'
      
      def initialize(xrds)
        super(xrds)
        raise Error, "Not a XRDS Document" unless xrds?
      end
      
      def xrds?
        !root.nil? and root.name == 'XRDS' and root.namespace == XRDS_NS
      end
            
      def services
        @services ||= each_element('/xrds:XRDS/XRD/Service') {|e| append_to_hash(e) }
      end
      
      private
      def append_to_hash(element)
        mth = lambda {
          def to_hash
            hash = {
              :priority => attribute('priority') ? attribute('priority').to_s : nil,
              :type => []
            }
            elements.each { |elm|
              if (n = elm.name) == 'Type'
                hash[:type] << elm.texts.first
              else
                hash[n.downcase.to_sym] = elm.texts.first
              end
            }
            hash
          end
        }
        element.instance_eval(&mth)
      end
    end
    
  end
end
