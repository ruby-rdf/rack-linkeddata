$:.unshift "."
require 'spec_helper'
require 'rack/test'

describe Rack::LinkedData do
  include ::Rack::Test::Methods

  before(:each) { @options = {}; @headers = {} }
  def app
    target_app = mock("Target Rack Application", :call => [200, @headers, @results || "A String"])

    @app ||= Rack::LinkedData::ContentNegotiation.new(target_app, @options)
  end

  context "plain test" do
    it "returns text unchanged" do
      get '/'
      last_response.body.should == 'A String'
    end
  end
  
  context "serializes graphs" do
    before(:each) do
      @options.merge!(:standard_prefixes => true)
      @results = RDF::Graph.new
    end

    context "with format" do
      %w(ntriples ttl).map(&:to_sym).each do |fmt|
        context fmt do
          let!(:writer) {RDF::Writer.for(fmt)}
          before(:each) do
            @options[:format] = fmt
            writer.should_receive(:dump).and_return(fmt.to_s)
            get '/'
          end

          it "returns serialization" do
            last_response.body.should == fmt.to_s
          end

          it "sets content type to #{RDF::Format.for(fmt).content_type.first}" do
            last_response.content_type.should == RDF::Format.for(fmt).content_type.first
          end
          
          it "sets content length" do
            last_response.content_length.should_not == 0
          end
        end
      end
    end
    
    context "with Accept" do
      {
        :ntriples => "text/plain",
        :turtle   => "text/turtle"
      }.each do |fmt, content_types|
        context content_types do
          before(:each) do
            writer = RDF::Writer.for(fmt)
            writer.should_receive(:dump).
              and_return(content_types.split(/,\s+/).first)
              get '/', {}, {"HTTP_ACCEPT" => content_types}
          end

          it "returns serialization" do
            last_response.body.should == content_types.split(/,\s+/).first
          end

          it "sets content type to #{content_types}" do
            last_response.content_type.should == content_types
          end
          
          it "sets content length" do
            last_response.content_length.should_not == 0
          end
        end
      end
    end
  end
end