# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  class NewspaperTitleForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperTitle
    self.terms += %i[
      title
      resource_type
      genre
      language
      held_by
      issued
      place_of_publication
      alternative_title
    ]
    self.required_fields = %i[
      title
      resource_type
      genre
      language
      held_by
    ]
  end
end
