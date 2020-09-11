# frozen_string_literal: true

class Api::V1::CollaboratorsController < ApplicationController
  before_action :set_collaborator, only: :destroy
  before_action :set_company, only: [:index, :create]

  def index
    @collaborators = @company.collaborators
  end

  def create
    @collaborator = @company.collaborators.build(collaborator_params)

    if @collaborator.save
      render json: @collaborator, status: :created
    else
      render json: @collaborator.errors, status: :unprocessable_entity
    end
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

    def collaborator_params
      params.require(:collaborator).permit(:name, :email)
    end
end
