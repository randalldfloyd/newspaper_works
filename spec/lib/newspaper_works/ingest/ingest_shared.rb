require 'spec_helper'

RSpec.shared_examples 'ingest adapter IO' do
  # define the path to the file we will use for multiple examples
  let(:path) do
    fixtures = File.join(NewspaperWorks::GEM_PATH, 'spec/fixtures/files')
    File.join(fixtures, 'page1.tiff')
  end
  # DRY for this matcher's use in multiple examples:
  let(:have_io_and_correct_filename) do
    have_attributes(
      filename: 'page1.tiff',
      io: an_object_responding_to(:read)
    )
  end

  describe "file loading" do
    # the first half of work done by ingest is done by load(); these
    # assertions test load() independent of work done.

    it "loads stream from path" do
      adapter = build(:newspaper_page_ingest)
      adapter.load(path)
      expect(adapter).to have_io_and_correct_filename
    end

    it "loads stream from a Pathname object" do
      adapter = build(:newspaper_page_ingest)
      adapter.load(Pathname.new(path))
      expect(adapter).to have_io_and_correct_filename
    end

    it "loads an File object" do
      adapter = build(:newspaper_page_ingest)
      File.open(path) do |file|
        adapter.load(file)
        expect(adapter).to have_io_and_correct_filename
      end
    end

    it "loads a StringIO with filename" do
      adapter = build(:newspaper_page_ingest)
      io = StringIO.new('File Content Here, Maybe')
      adapter.load(io, filename: 'page1.tiff')
      expect(adapter).to have_io_and_correct_filename
    end

    it "raises on missing explicit filename for StringIO" do
      adapter = build(:newspaper_page_ingest)
      io = StringIO.new('File Content Here, Maybe')
      expect { adapter.load(io) }.to raise_error(ArgumentError)
    end
  end
end
