$:.unshift "."
require 'spec_helper'
require 'rack/test'

describe Rack::LinkedData do
  include ::Rack::Test::Methods

  before(:each) { @options = {}; @headers = {} }
  def app
    target_app = double("Target Rack Application", :call => [200, @headers, @results || "A String"])

    @app ||= Rack::LinkedData::ContentNegotiation.new(target_app, @options)
  end

  context "plain test" do
    it "returns text unchanged" do
      get '/'
      expect(last_response.body).to eq 'A String'
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
            expect(writer).to receive(:dump).and_return(fmt.to_s)
            get '/'
          end

          it "returns serialization" do
            expect(last_response.body).to eq fmt.to_s
          end

          it "sets content type to #{RDF::Format.for(fmt).content_type.first}" do
            expect(last_response.content_type).to eq RDF::Format.for(fmt).content_type.first
          end
          
          it "sets content length" do
            expect(last_response.content_length).not_to eq 0
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
            expect(writer).to receive(:dump).
              and_return(content_types.split(/,\s+/).first)
              get '/', {}, {"HTTP_ACCEPT" => content_types}
          end

          it "returns serialization" do
            expect(last_response.body).to eq content_types.split(/,\s+/).first
          end

          it "sets content type to #{content_types}" do
            expect(last_response.content_type).to eq content_types
          end
          
          it "sets content length" do
            expect(last_response.content_length).not_to eq 0
          end
        end
      end
    end
  end
end