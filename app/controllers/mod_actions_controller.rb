class ModActionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @mod_actions = ModAction.search(params[:search]).paginate(params[:page], :limit => params[:limit])
    respond_with(@mod_actions)
  end
end
