class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from ArgumentError, with: :bad_request_response
  def index
      merchants = Merchant.sort_and_filter(params)
      render json: MerchantSerializer.new(merchants, {params: {action: "index"} } )
  end


  def show
      render json: MerchantSerializer.new(Merchant.find(params[:id]))
  end

  def update
      merchant = Merchant.find(params[:id])
      merchant.update(merchant_params)
      render json: MerchantSerializer.new(merchant)
  end

  def create
    begin
      new_merchant = Merchant.create!(merchant_params)
      render json: MerchantSerializer.new(new_merchant), status: :created
    rescue ActionController::ParameterMissing => exception
      render json: {
        message: "Invalid parameters",
        errors: ["Missing required merchant attributes"]
      }, status: :bad_request
    end

  end

  def destroy
    # begin
      merchant = Merchant.find(params[:id])
      merchant.destroy  
      head :no_content  
    # rescue ActiveRecord::RecordNotFound
#       head :not_found 
    # end
  end

  def find
    name = find_params[:name]
    if name.blank?
      raise ArgumentError, "Missing 'name' parameter"
    end    
    merchant = Merchant.filter_by_name(name)
    render json: MerchantSerializer.new(merchant || { data: {} }), status: merchant ? :ok : :not_found
  end

  private

  def find_params
    params.permit(:name)
  end

  def merchant_params
      params.require(:merchant).permit(:name)
  end

  def not_found_response(e)
    render json: ErrorSerializer.new(ErrorMessage.new(e.message, 404))
      .serialize_json, status: :not_found
  end

  def bad_request_response(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
