# frozen_string_literal: true

class NewspaperContainer < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include NewspaperWorks::NewspaperCoreMetadata

  self.indexer = NewspaperContainerIndexer

  # containment/aggregation:
  self.valid_child_concerns = [NewspaperPage]

  # Validation and required fields:
  # self.required_fields = [:resource_type, :genre, :language, :held_by]
  validates :title, presence: { message: "A newspaper container requires a title." }

  self.human_readable_type = "Newspaper Container"

  # == Type-specific properties ==

  # TODO: DRY on the indexing of fields, the index block is repetative...

  #  - Type (TODO: make a behavior mixin for common fields)

  # - Extent
  property(
    :extent,
    predicate: ::RDF::Vocab::DC.extent,
    multiple: false,
  ) do |index|
    index.as :stored_searchable
  end

  # TODO: Reel #: https://github.com/samvera-labs/uri_selection_wg/issues/2
  # TODO: Titles on reel

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # relationship methods

  def publication
    result = member_of.select { |v| v.instance_of?(NewspaperTitle) }
    result[0] unless result.empty?
  end

  def pages
    members.select { |v| v.instance_of?(NewspaperPage) }
  end
end
