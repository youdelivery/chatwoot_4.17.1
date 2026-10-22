class Api::V1::Accounts::ConversationsWithOrdersController < Api::V1::Accounts::ConversationsController
  before_action :validate_order_filters, only: :index

  def index
    @order_statuses = policy_scope(Current.account.labels)
                      .where.not(title: ConversationsWithOrdersFinder::NON_ORDER_LABELS).pluck(:title)
    super
  end

  private

  def conversation_finder
    @conversation_finder ||= ConversationsWithOrdersFinder.new(Current.user, params)
  end

  def validate_order_filters
    %i[tiene_pedido persona_requerida].each do |key|
      next if params[key].nil? || %w[true false all].include?(params[key])

      render json: { error: "#{key} must be true, false or all" }, status: :bad_request
      return
    end
    value = params[:estado_pedido]
    return if value.nil? || (value.is_a?(String) && value.length <= 100 && !ConversationsWithOrdersFinder::NON_ORDER_LABELS.include?(value))

    render json: { error: 'Invalid estado_pedido' }, status: :bad_request
  end
end