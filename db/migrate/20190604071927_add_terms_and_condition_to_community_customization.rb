class AddTermsAndConditionToCommunityCustomization < ActiveRecord::Migration
  def change
    add_column :community_customizations, :terms_and_condtions, :text
  end
end
