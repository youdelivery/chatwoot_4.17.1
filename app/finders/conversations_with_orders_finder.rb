class ConversationsWithOrdersFinder < ConversationFinder
  NON_ORDER_LABELS = %w[persona_requerida esperandorespuesta].freeze
  # Read the same cached labels as the response, without a join or per-conversation query.
  LABEL_ROWS_SQL = <<~SQL.freeze
    unnest(string_to_array(COALESCE(conversations.cached_label_list, ''), ',')) AS conversation_label(name)
  SQL

  private

  def set_up
    super
    filter_by_order_presence
    filter_by_persona_required
    filter_by_order_status
  end

  def filter_by_order_presence
    return if params[:tiene_pedido].blank? || params[:tiene_pedido] == 'all'

    @conversations = @conversations.where(
      "EXISTS (SELECT 1 FROM #{LABEL_ROWS_SQL} WHERE btrim(name) NOT IN (?)) = ?",
      NON_ORDER_LABELS, params[:tiene_pedido] == 'true'
    )
  end

  def filter_by_persona_required
    return if params[:persona_requerida].blank? || params[:persona_requerida] == 'all'

    @conversations = @conversations.where(
      "EXISTS (SELECT 1 FROM #{LABEL_ROWS_SQL} WHERE btrim(name) = ?) = ?",
      'persona_requerida', params[:persona_requerida] == 'true'
    )
  end

  def filter_by_order_status
    return if params[:estado_pedido].blank? || params[:estado_pedido] == 'all'

    @conversations = @conversations.where("EXISTS (SELECT 1 FROM #{LABEL_ROWS_SQL} WHERE btrim(name) = ?)", params[:estado_pedido])
  end
end
