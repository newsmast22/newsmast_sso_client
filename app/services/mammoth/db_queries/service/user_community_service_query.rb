module Mammoth
  module DbQueries
    module Service
      class UserCommunityServiceQuery
        def initialize(max_id, current_user, current_account, current_community, page_no)
          @max_id = max_id
          @user = Mammoth::User.find(current_user.id)
          @account = current_account
          @community = current_community
          @community_slug = @community.nil? ? nil : @community.slug
          @page_no = page_no
        end

        def all_timeline
          load_and_filter_statuses(:user_community_all_timeline)
        end

        def recommended_timeline
          load_and_filter_statuses(:user_community_recommended_timeline)
        end

        private

        def load_and_filter_statuses(scope_name)
          return [] unless @community_slug

          @statuses = Mammoth::Status.public_send(scope_name, @max_id, @account, @user, @community, @page_no)
          @statuses = Mammoth::Status.includes(
            :reblog,
            :media_attachments,
            :active_mentions,
            :tags,
            :preloadable_poll,
            :status_stat,
            :conversation,
            account: [:user, :account_stat]
          ).where(id: @statuses.pluck(:id))

          @statuses
        end
      end
    end
  end
end