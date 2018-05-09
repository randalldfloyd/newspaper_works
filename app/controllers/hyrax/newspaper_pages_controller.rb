# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work NewspaperPage`

module Hyrax
  class NewspaperPagesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::NewspaperPage

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::NewspaperPagePresenter
  end
end
