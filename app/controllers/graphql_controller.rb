class GraphqlController < AuthenticatedController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  UPDATE_SCOPES_HEADER = 'X-Shopify-Insufficient-Scopes'

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      # Query context goes here, for example:
      # current_user: current_user,
    }
    products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
    result = NextGenAuthAppDemoSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    if result.to_h['data']['testField']['errors'].present?
      # Use the helper method available in the ShopifyApp::Authenticated concern
      signal_access_token_required
    end
    render json: result
  rescue ActiveResource::ForbiddenAccess => e
    response.set_header(UPDATE_SCOPES_HEADER, true)
  rescue => e
    raise e unless Rails.env.development?
    handle_error_in_development e
  end

  private

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
