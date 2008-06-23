require 'open-uri'
require 'rubygems'
require 'openid'
require File.dirname(__FILE__) + '/../helper'

# Precondition steps / Given
steps_for :xrds_based_discovery do
  Given "$id as the user-supplied identifier" do |id|
    @supplied_identifier = id
  end
  Given "$mimetype to HTTP-Accept of the request" do |mimetype|
    @accept = mimetype
  end
end

# Action steps / When
steps_for :xrds_based_discovery do
  When "consumer tells to the provider" do
    @request = open(@supplied_identifier, "Accept" => @accept)
  end
  When "consumer gets response" do
    # @response = "<XRD /><URI>http://localhost:3000/server</URI>"#@request.read
    @response = @request.read.dup
  end
end

# Outcome steps / Then
steps_for :xrds_based_discovery do
  Then "response contains $elm1 with $value1 and $elm2 with $value2" do |elm1, value1, elm2, value2|
    r = @response.dup
    r.should have_tag(elm1, value1)
    r.should have_tag(elm2, value2)
  end
end
