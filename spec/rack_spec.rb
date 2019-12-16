$:.unshift "."
require 'spec_helper'
require 'rack/test'

describe Rack::LinkedData do
  include ::Rack::Test::Methods

  before(:each) { @options = {}; @headers = {} }
  def app
    target_app = double("Target Rack Application", :call => [200, @headers, @results || "A String"])

    @app ||= Rack::LinkedData::ContentNegotiation.new(target_app, **@options)
  end

  describe "#parse_accept_header" do
    {
      "application/n-triples" => %w(application/n-triples),
      "application/n-triples,  text/turtle" => %w(application/n-triples text/turtle),
      "text/turtle;q=0.5, application/n-triples" => %w(application/n-triples text/turtle),
      "application/ld+json, application/ld+json;profile=http://www.w3.org/ns/json-ld#compacted" =>
        %w(application/ld+json;profile=http://www.w3.org/ns/json-ld#compacted application/ld+json),
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
        %(application/ld+json;profile="http://www.w3.org/ns/json-ld#compacted http://example.org/white-listed") => :jsonld
      }.each do |accepts, fmt|
        context accepts do
          before(:each) do
            writer = RDF::Writer.for(fmt)
            expect(writer).to receive(:dump).
              and_return(accepts.split(/,\s+/).first)
            get '/', {}, {"HTTP_ACCEPT" => accepts}
          end
          let(:content_type) {app.send(:parse_accept_header, accepts).first.split(';').first.strip}

          it "sets content type" do
            expect(last_response.content_type).to eq content_type
          end

          it "returns serialization" do
            expect(last_response.body).to eq accepts.split(/,\s+/).first
          end
        end
      end

      it "passes link to :dump" do
        writer = RDF::NTriples::Writer
        RSpec::Mocks.expect_message(writer, :dump) do |repo, io, options|
          expect(options).to include(:link)
          link = options[:link]
          expect(link).to eq %(<foo>; rel="self")
        end
        get '/', {}, {"HTTP_ACCEPT" => 'application/n-triples', "HTTP_LINK" => %(<foo>; rel="self")}
      end

      context "with profile accept-param" do
        let(:header) {%(application/ld+json;profile="http://www.w3.org/ns/json-ld#compacted http://example.org/white-listed")}

        it "calls Writer.accept? with profile" do
          writer = JSON::LD::Writer
          expect(writer).to receive(:accept?).with(hash_including(profile: "http://www.w3.org/ns/json-ld#compacted http://example.org/white-listed"))
          get '/', {}, {"HTTP_ACCEPT" => header}
        end

        it "passes accept-params to :dump" do
          writer = JSON::LD::Writer
          RSpec::Mocks.expect_message(writer, :dump) do |repo, io, options|
            expect(options).to include(:accept_params)
            accept_params = options[:accept_params]
            expect(accept_params).to include(profile: "http://www.w3.org/ns/json-ld#compacted http://example.org/white-listed")
          end
          get '/', {}, {"HTTP_ACCEPT" => header}
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