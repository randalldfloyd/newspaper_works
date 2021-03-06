require 'active_support/core_ext/module/delegation'
require 'json'
require 'nokogiri'

module NewspaperWorks
  # Module for text extraction
  module TextExtraction
    # Class to obtain plain text and JSON word-coordinates from ALTO source
    class AltoReader
      attr_accessor :source, :doc_stream
      delegate :text, to: :doc_stream

      # SAX Document Stream class to gather text and word tokens from ALTO
      class AltoDocStream < Nokogiri::XML::SAX::Document
        attr_accessor :text, :words

        def initialize
          super
          # plain text buffer:
          @text = ''
          # list of word hash, containing word+coord:
          @words = []
        end

        # Return coordinates from String element attribute hash
        #
        # @param attrs [Hash] hash containing ALTO `String` element attributes.
        # @return [Array] Array of position x, y, width, height in px.
        def s_coords(attrs)
          height = (attrs['HEIGHT'] || 0).to_i
          width = (attrs['WIDTH'] || 0).to_i
          hpos = (attrs['HPOS'] || 0).to_i
          vpos = (attrs['VPOS'] || 0).to_i
          [hpos, vpos, width, height]
        end

        # Callback for element start, implementation of which ignores
        #   non-String elements.
        #
        # @param name [String] element name.
        # @param attrs [Array] Array of key, value pair Arrays.
        def start_element(name, attrs = [])
          values = attrs.to_h
          return if name != 'String'
          token = values['CONTENT']
          @text << token
          @words << {
            word: token,
            coordinates: s_coords(values)
          }
        end

        # Callback for element end, used here to manage endings of lines and
        #   blocks.
        #
        # @param name [String] element name.
        def end_element(name)
          @text << " " if name == 'String'
          @text << "\n" if name == 'TextBlock'
          @text << "\n" if name == 'TextLine'
        end

        # Callback for completion of parsing ALTO, used to normalize generated
        #   text content (strip unneeded whitespace incidental to output).
        def end_document
          # postprocess @text to remove trailing spaces on lines
          @text = @text.split("\n").map(&:strip).join("\n")
          # remove trailing whitespace at end of buffer
          @text.strip!
        end
      end

      # Construct with either path
      #
      # @param xml [String], and process document
      def initialize(xml)
        @source = isxml?(xml) ? xml : File.read(xml)
        @doc_stream = AltoDocStream.new
        parser = Nokogiri::XML::SAX::Parser.new(doc_stream)
        parser.parse(@source)
      end

      # Determine if source parameter is path or xml
      #
      # @param xml [String] either path to xml file or xml source
      # @return [true, false] true if string appears to be XML source, not path
      def isxml?(xml)
        xml.lstrip.start_with?('<')
      end

      # Output JSON flattened word coordinates
      #
      # @return [String] JSON serialization of flattened word coordinates
      def json
        words = {
          words: @doc_stream.words
        }
        JSON.generate(words)
      end
    end
  end
end
