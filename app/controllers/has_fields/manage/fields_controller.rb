module HasFields::Manage
  class FieldsController < HasFields::ApplicationController
    before_filter :authenticate_user!
    before_filter :load_resource_and_scope
    before_filter :load_fields, :only => [:index, :edit, :manage]
    layout "application"

    def index
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_index", :layout => true }
        format.js { render "/has_fields/manage/fields/_index" }
      end
    end

    def show
      @field = HasFields::Field.find(params[:id])
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_show", :layout => true }
        format.js { render "/has_fields/manage/fields/_show" }
      end
    end
    
    def new
      @field = HasFields::Field.new
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_new", :layout => true }
        format.js { render "/has_fields/manage/fields/_new" }
      end
    end
    
    def create
      @field = HasFields::Field.new(params[:field])
      @field.send("#{@scope}_id=",@scope_object.id)
      if @field.save
        respond_to do |format|
          format.html { redirect_to "/#{@scope.pluralize}/#{@scope_object.id}/fields/manage/#{@field.id}/" }
          format.js { render "/has_fields/manage/fields/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          format.html { render :template => "/has_fields/manage/fields/_new", :layout => true }
          format.js { render "/has_fields/manage/fields/_new", :locals => {:edit => true} }
        end
      end
    end

    def edit
      @field = HasFields::Field.find(params[:id])
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_edit", :layout => true }
        format.js { render "/has_fields/manage/fields/_edit" }
      end
    end
    
    def update
      @field = HasFields::Field.find(params[:id])
      if @field.update_attributes(params[:field])
        respond_to do |format|
          format.html { redirect_to "/#{@scope.pluralize}/#{@scope_object.id}/fields/manage/#{@field.id}/" }
          format.js { render "/has_fields/fields/manage/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          format.html { render "/has_fields/fields/manage/_edit" }
          format.js { render "/has_fields/fields/manage/_edit", :locals => {:edit => true} }
        end
      end
    end
    
    protected

    def load_fields
      # find all fields applicable to the current user that are scoped by the supplied scope
      @fields_by_resource = Field.scoped_by(@scope_object).group_by(&:kind)
    end
    
    def load_resource_and_scope
      
      @scope = params[:scope].singularize
      # the scope object should be either the current user, a user from their org, or their org.
      @scope_object = @scope.classify.constantize.find(params[:scope_id])
      # to stop users accessing fields form other orgs
      if (@scope == "user" && @scope_object.organization_id != current_user.organization_id) ||
         (@scope == "organization" && @scope_object.id != current_user.organization_id) ||
         (@scope_object.respond_to?(:organnization_id) && @scope_object.organization_id != current_user.organization_id)
        redirect_to "/"
      end
    end
  end
end
