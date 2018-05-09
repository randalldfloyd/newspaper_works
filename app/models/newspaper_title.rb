# frozen_string_literal: true

# NewspaperTitle: object for a publication/title
class NewspaperTitle < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include NewspaperWorks::NewspaperCoreMetadata

  self.indexer = NewspaperTitleIndexer

  # containment/aggregation:
  self.valid_child_concerns = [NewspaperContainer, NewspaperIssue]

  # Validation and required fields:
  # self.required_fields = [:resource_type, :genre, :language, :held_by]
  validates :title, presence: {
    message: "A newspaper title a title (publication name).",
  }

  # validations below causing save failures
  # TODO: get them working || enforce validation elsewhere || remove

  # validates :type, presence: {
  #   message: 'A newspaper title requires a type.'
  # }

  # validates :genre, presence: {
  #   message: 'A newspaper title requires a genre.'
  # }

  self.human_readable_type = "Newspaper Title"

  # == Type-specific properties ==

  # - Edition
  property(
    :edition,
    predicate: ::RDF::Vocab::BIBO.edition,
    multiple: false,
  ) do |index|
    index.as :stored_searchable
  end

  # - Frequency
  property(
    :frequency,
    predicate: ::RDF::URI.new("http://www.rdaregistry.info/Elements/u/P60538"),
    multiple: true,
  ) do |index|
    index.as :stored_searchable
  end

  # Preceded by
  property(
    :preceded_by,
    predicate: ::RDF::URI.new("http://rdaregistry.info/Elements/u/P60261"),
    multiple: true,
  ) do |index|
    index.as :stored_searchable
  end

  # Succeeded by
  property(
    :succeeded_by,
    predicate: ::RDF::URI.new("http://rdaregistry.info/Elements/u/P60278"),
    multiple: true,
  ) do |index|
    index.as :stored_searchable
  end

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # relationship methods:
  def issues
    members.select { |v| v.instance_of?(NewspaperIssue) }
  end

  def containers
    members.select { |v| v.instance_of?(NewspaperContainer) }
  end
end
