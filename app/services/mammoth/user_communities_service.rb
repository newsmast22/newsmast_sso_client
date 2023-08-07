class Mammoth::UserCommunitiesService < BaseService
  def initialize(params,current_user)
    @params = params
    @current_user = current_user
    @params.permit!
    if @params.include?(:is_virtual)
      @is_virtual = @params[:is_virtual]
    else
      @is_virtual = nil
    end  
  end

  def get_user_communities
    @user = Mammoth::User.find(@current_user.id)
    @communities = @user&.communities || []
    @communities_count = @communities.count 
    @user_communities = Mammoth::UserCommunity.find_by(user_id: @current_user.id,is_primary: true)
    @data = []
    
    unless @communities.empty?
      @communities.each do |community|
        @data << {
          id: community.id.to_s,
          user_id: @user.id.to_s,
          is_primary: community.id == (@user_communities&.community_id || 0) ? true : false,
          name: community.name,
          slug: community.slug,
          image_file_name: community.image_file_name,
          image_content_type: community.image_content_type,
          image_file_size: community.image_file_size,
          image_updated_at: community.image_updated_at,
          description: community.description,
          image_url: community.image.url,
          collection_id: community.collection.id,
          followers: Mammoth::UserCommunity.where(community_id: community.id).size,
          created_at: community.created_at,
          updated_at: community.updated_at
        }
      end

      @data = @data.sort_by {|h| [h[:is_primary] ? 0 : 1,h[:slug]]}

      if @params[:community_slug].present?
        new_community = Mammoth::Community.find_by(slug: @params[:community_slug])
        unless @data.any? { |obj| obj[:slug] == @params[:community_slug] }
          @data.prepend << {
            id: new_community.id.to_s,
            user_id: @user.id.to_s,
            is_primary:  false,
            name: new_community.name,
            slug: new_community.slug,
            image_file_name: new_community.image_file_name,
            image_content_type: new_community.image_content_type,
            image_file_size: new_community.image_file_size,
            image_updated_at: new_community.image_updated_at,
            description: new_community.description,
            image_url: new_community.image.url,
            collection_id: new_community.collection.id,
            followers: Mammoth::UserCommunity.where(community_id: new_community.id).size,
            created_at: new_community.created_at,
            updated_at: new_community.updated_at
          }
          @data = @data.sort_by {|h| [h[:slug] == new_community.slug ? 0 : 1,h[:slug]]}
        end
      end
      @data = @data.sort_by {|h| [h[:is_primary] ? 0 : 1,h[:slug]]}
      virtual_community
    end
    return @data
  end

  def virtual_community
    if @is_virtual == 'true' || @is_virtual.nil?
      @data.unshift( {
        id: @communities_count + 1,
        user_id: @user.id.to_s,
        is_primary: false,
        is_virtual: true,
        name: 'My Server - Newsmast',
        slug: 'my-server-newsmast',
        image_file_name: 'my-server-newsmast',
        image_content_type: nil,
        image_file_size: nil,
        image_updated_at: Time.now,
        description: "All posts from the user communities of Newsmast",
        image_url: "https://s3-eu-west-2.amazonaws.com/newsmast-staging/mammoth/communities/images/000/000/004/original/14a6c845a0e485ab.png",
        collection_id: nil,
        followers: nil,
        created_at: Time.now,
        updated_at: Time.now,
      } )
    end
  end
end