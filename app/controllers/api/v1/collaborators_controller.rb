# frozen_string_literal: true

class Api::V1::CollaboratorsController < ApplicationController
  before_action :set_collaborator, only: [:show, :update, :destroy]
  before_action :set_company, only: [:index, :create]
  before_action :set_manager, only: :update

  rescue_from InvalidRequest, with: :invalid_request

  def index
    @collaborators = @company.collaborators
  end

  def create
    @collaborator = @company.collaborators.build(collaborator_params)
  def show
    @collaborators = FindCollaboratorsService.call!(collaborator: @collaborator,
                                                    info_type: params[:info_type])

    render :collaborators
  end

  def update
    ValidateManagerService.call!(collaborator: @collaborator, manager: @manager)

    @collaborator.update!(manager: @manager)
  end

  def destroy
    @collaborator.destroy

    head :no_content
  end

  private
    def set_collaborator
      @collaborator = Collaborator.find(params[:id])
    end

    def set_company
      @company = Company.find(params[:company_id])
    end

    def set_manager
      @manager = Collaborator.find(params[:manager_id])
    end

    def collaborator_params
      params.require(:collaborator).permit(:name, :email)
    end

    def invalid_request(exception)
      render json: { message: exception.message }, status: exception.status
    end
end
