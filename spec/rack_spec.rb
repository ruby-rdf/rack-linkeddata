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

  describe "#parse_accept_header" do
    {
      "application/n-triples" => %w(application/n-triples),
      "application/n-triples,  text/turtle" => %w(application/n-triples text/turtle),
      "text/turtle;q=0.5, application/n-triples" => %w(application/n-triples text/turtle),
    }.each do |accept, content_types|
      it "returns #{content_types.inspect} given #{accept.inspect}" do
        expect(app.send(:parse_accept_header, accept)).to eq content_types
      end
    end
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
        "application/n-triples"                           => :ntriples,
        "application/n-triples,  text/turtle"             => :ntriples,
        "text/turtle;q=0.5, application/n-triples"        => :ntriples,
        "text/turtle;q=0.5, application/json"             => :jsonld,
        "text/*, appication/*;q=0.5"                      => :ttl,
        "text/turtle;q=0.5, application/xml"              => :rdfxml,
      }.each do |accepts, fmt|
        context accepts do
          before(:each) do
            writer = RDF::Writer.for(fmt)
            expect(writer).to receive(:dump).
              and_return(accepts.split(/,\s+/).first)
            get '/', {}, {"HTTP_ACCEPT" => accepts}
          end
          let(:content_type) {app.send(:parse_accept_header, accepts).first}

          it "sets content type" do
            expect(last_response.content_type).to eq content_type
          end

          it "returns serialization" do
            expect(last_response.body).to eq accepts.split(/,\s+/).first
          end
        end
      end

      context "with writer errors" do
        it "continues to next writer if first fails" do
          nq, nt = RDF::Writer.for(:nquads), RDF::Writer.for(:ntriples)
          expect(nq).to receive(:dump).and_raise(RDF::WriterError)
          expect(nt).to receive(:dump).and_return("<a> <b> <c> .")
          get '/', {}, {"HTTP_ACCEPT" => "application/n-quads,  application/n-triples"}
        end
      end
    end
  end
end