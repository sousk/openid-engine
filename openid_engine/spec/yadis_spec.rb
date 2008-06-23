require File.dirname(__FILE__) + '/helpers/rp_helper'

describe OpenidEngine::Yadis do
    
  before(:each) do
    @yadis = OpenidEngine::Yadis
    
    @agent = OpenidEngine::Agent.new
    @yadis.stub!(:agent).and_return(@agent)
    
    @yadis_id = 'http://yadis_id.example.com/'
    @rd_url = @yadis_id + 'xrds'
    @xrds = XRDSDATA[:doc]
  end
  
  describe "#new" do
    it {
      yadis = @yadis.new(@xrds)
      yadis.should be_an_instance_of(@yadis)
      yadis.document.should be_an_instance_of(@yadis::Document)
    }
    it {
      lambda {
        d = @yadis.new("<invalid-xrds />")
      }.should raise_error(@yadis::Error)
    }
  end
  
  describe "#services" do
    before(:each) do
      @services = @yadis.new(@xrds).services
    end
    
    it "should be an array of hash" do
      @services.should be_an_instance_of(Array)
      @services.each { |s|
        s.should be_kind_of(Hash)
        s[:type].should be_kind_of(Array)
      }
    end
    
    it "should be sorted to descending order by priority attribute" do
      prev_p = '-1'
      @services.each { |s|
        if s[:priority]
          s[:priority].should > prev_p
        end
      }
    end
    
    it "should be hash made from each service-elements" do
      samples = XRDSDATA[:hashed_services] # converted manually
      @services.each_with_index { |hashed, i|
        hashed.each { |k, v|
          if v.kind_of? Array            
            v.each_with_index{ |type, type_index| 
              type.should == samples[i][k][type_index] }
          else
            v.should == samples[i][k]
          end
        }
      }
    end
  end
  
  describe "#id2rd" do
    it "should find Resource Descriptor URL from given URL" do
      @agent.should_receive(:get).and_return(mock_response(200, :x_xrds_location => @rd_url))
      @yadis.id2rd(@yadis_id).should == @rd_url
    end
  end
  
  describe "#rd2xrds" do
    before(:each) do
    end
    
    it "should get XRDS from given URL" do
      @agent.should_receive(:get_xrds).and_return(mock_response(200){ @xrds })
      @yadis.rd2xrds(@rd_url).should be_an_instance_of(@yadis::Document)
    end
    
    it do
      @agent.should_receive(:get_xrds).and_return(mock_response(200){ "<html />"})
      lambda { @yadis.rd2xrds(@rd_url) }.should raise_error(@yadis::Error)
    end
  end
  
  describe "#initiate" do
    describe "when success" do
      it "should get an instance of Yadis" do
        @yadis.should_receive(:id2rd).and_return(@rd_url)
        @yadis.should_receive(:rd2xrds).and_return(@xrds)
        @yadis.initiate(@yadis_id).should be_an_instance_of(@yadis)
      end
    end
    
    describe "when failed" do
      it "should raise error when status code is 404" do
        response = mock_response(404)
        @agent.should_receive(:request).and_return(response)
        lambda{
          @yadis.initiate(@yadis_id)
        }.should raise_error(@yadis::Error)
      end
    end
    
  end
end


describe OpenidEngine::Yadis::Document do
  before(:each) do
    @yadis = OpenidEngine::Yadis
    @doc = @yadis::Document.new(XRDSDATA[:doc])
  end
  
  describe "initialize" do
    it { @yadis::Document.new(XRDSDATA[:doc]).should be_an_instance_of(@yadis::Document)}
    it { lambda { @yadis::Document.new("<xml />") }.should raise_error(@yadis::Error) }
  end
  
  describe "#services" do
    before(:each) do
      @services = @doc.services
      @s = @services.first unless @services.empty?
    end
    it "should returns an array of serivec element" do
      @services.should be_kind_of(Array)
      @s.should be_kind_of(REXML::Element)
    end
    
    it "should append to_hash method to its member" do
      @s.should respond_to(:to_hash)
    end
    
  end
end