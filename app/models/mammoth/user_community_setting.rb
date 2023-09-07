module Mammoth
  class UserCommunitySetting < ApplicationRecord
    self.table_name = 'mammoth_user_community_settings'
    belongs_to :user, class_name: "Mammoth::User"

    def self.check_attribute(selected_filters)
      selected_filters.dig('location_filter').nil? || selected_filters.dig('source_filter').nil? || selected_filters.dig('communities_filter').nil?
    end

    def self.create_userTimelineSetting(user)
      userCommunitySettings = Mammoth::UserCommunitySetting.where(user_id: user.id)
      userCommunitySettings.destroy_all
      Mammoth::UserCommunitySetting.create!(
        user_id: user.id,
        selected_filters: {
          default_country: user.account.country,
          location_filter: {
            selected_countries: [],
            is_location_filter_turn_on: true
          },
          is_filter_turn_on: false,
          source_filter: {
            selected_media: [],
            selected_voices: [],
            selected_contributor_role: []
          },
          communities_filter: {
            selected_communities: []
          }
        }
      )
    end
  end
end