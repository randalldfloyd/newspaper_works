# frozen_string_literal: true

require "rails/generators"

module NewspaperWorks
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def register_worktypes
      inject_into_file "config/initializers/hyrax.rb", after: "Hyrax.config do |config|\n" do
        "  # Configuration generated by `rails g newspaper_works:install`\n" \
          "  config.register_curation_concern :newspaper_article\n" \
          "  config.register_curation_concern :newspaper_container\n" \
          "  config.register_curation_concern :newspaper_issue\n" \
          "  config.register_curation_concern :newspaper_page\n" \
          "  config.register_curation_concern :newspaper_title\n" \
          "  # == END GENERATED newspaper_works CONFIG =="
      end
    end

    def inject_routes
      inject_into_file "config/routes.rb", after: "Rails.application.routes.draw do\n" do
        "\n  mount NewspaperWorks::Engine => '/'\n"
      end
    end
  end
end
