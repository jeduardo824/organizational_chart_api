# frozen_string_literal: true

class Api::V1::CompaniesController < ApplicationController
  before_action :set_company, only: :show

  def index
    @companies = Company.all
  end

  def show
  end

  def create
    @company = Company.create!(company_params)

    render :show, status: :created
  end

  private
    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(:name, collaborators_attributes: [:name, :email])
    end
end
