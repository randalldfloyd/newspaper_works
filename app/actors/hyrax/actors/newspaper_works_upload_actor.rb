module Hyrax
  module Actors
    class NewspaperWorksUploadActor < Hyrax::Actors::BaseActor
      def create(env)
        # If NewspaperIssue, we might have a PDF to split...
        handle_issue_upload(env) if env.curation_concern.class == NewspaperIssue
        # pass to next actor
        next_actor.create(env)
      end

      def update(env)
        handle_issue_upload(env) if env.curation_concern.class == NewspaperIssue
        # pass to next actor
        next_actor.update(env)
      end

      def default_admin_set
        AdminSet.find_or_create_default_admin_set_id
      end

      def queue_job(work, paths, user, admin_set_id)
        NewspaperWorks::CreateIssuePagesJob.perform_later(
          work,
          paths,
          user,
          admin_set_id
        )
      end

      def handle_issue_upload(env)
        return unless env.attributes.keys.include? 'uploaded_files'
        upload_ids = filter_file_ids(env.attributes['uploaded_files'])
        return if upload_ids.empty?
        uploads = UploadedFile.find(upload_ids)
        paths = uploads.map(&method(:upload_path))
        paths = paths.select { |path| path.end_with?('.pdf') }
        return if paths.empty?
        work = env.curation_concern
        # must persist work to serialize job using it
        work.save!(validate: false)
        user = env.user.user_key
        env.attributes[:admin_set_id] ||= default_admin_set
        queue_job(work, paths, user, env.attributes[:admin_set_id])
      end

      # Given Hyrax::Upload object, return path to file on local filesystem
      def upload_path(upload)
        # so many layers to this onion:
        upload.file.file.file
      end

      def filter_file_ids(input)
        Array.wrap(input).select(&:present?)
      end
    end
  end
end
