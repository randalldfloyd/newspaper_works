class NewspaperPage < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include NewspaperWorks::ScannedMediaMetadata

  self.indexer = NewspaperPageIndexer

  # containment/aggregation:
  # self.valid_child_concerns = []

  # Validation and required fields:
  # self.required_fields = [:height, :width]
  validates :title, presence: { message: 'A newspaper page requires a title.' }

  self.human_readable_type = 'Newspaper Page'

  # == Type-specific properties ==

  # - Text Direction
  property(
      :text_direction,
      predicate: ::RDF::Vocab::OA.textDirection,
      multiple: false
  )

  # - Height
  property(
      :height,
      predicate: ::RDF::URI.new('http://dbpedia.org/ontology/height'),
      multiple: false
  )

  # - Width
  property(
      :width,
      predicate: ::RDF::URI.new('http://dbpedia.org/ontology/width'),
      multiple: false
  )

  # - Page Number
  property(
      :page_number,
      predicate: ::RDF::Vocab::SCHEMA.pagination,
      multiple: false
  )

  # - Section
  property(
      :section,
      predicate: ::RDF::Vocab::BIBO.section,
      multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # TODO: Add Reel number

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # relationship methods

  # get publication (transitive)
  def publication
    # try transitive relation via issue first:
    issues = self.issues
    if issues.length > 0
      return issues[0].publication
    end
    # fallback to trying to see if there is an issue-less container with title: 
    containers = self.containers
    if containers.length > 0
      return containers[0].publication
    end
  end

  def articles
    self.member_of.select { |v| v.instance_of?(NewspaperArticle) }
  end

  def issues
    self.member_of.select { |v| v.instance_of?(NewspaperIssue) }
  end

  def containers
    self.member_of.select { |v| v.instance_of?(NewspaperContainer) }
  end

end
