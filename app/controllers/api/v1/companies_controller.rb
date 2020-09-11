# frozen_string_literal: true

class Api::V1::CompaniesController < ApplicationController
  before_action :set_company, only: :show

  def index
    @companies = Company.all
  end

  def show
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      render :show, status: :created
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  private
    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(:name, collaborators_attributes: [:name, :email])
    end
end
