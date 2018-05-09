# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work NewspaperPage`
module Hyrax
  class NewspaperPageForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperPage
    self.required_fields = %i[height width]
    self.terms += [:resource_type]
  end
end
