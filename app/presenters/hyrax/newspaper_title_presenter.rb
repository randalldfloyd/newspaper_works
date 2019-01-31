# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  class NewspaperTitlePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::NewspaperCorePresenter
    delegate :edition, :frequency, :preceded_by, :succeeded_by, to: :solr_document

    def members
      NewspaperTitle.find(solr_document.id).members
    end

    def member_publication_dates
      dates = []
      members.each do |issue|
        dates << issue.publication_date if issue.class == NewspaperIssue
      end
      dates
    end

    def publication_date_start
      solr_document["publication_date_start_dtsim"]
    end

    def publication_date_end
      solr_document["publication_date_end_dtsim"]
    end
  end
end
