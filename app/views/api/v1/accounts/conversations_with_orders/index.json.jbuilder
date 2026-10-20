json.data do
  json.meta do
    json.mine_count @conversations_count[:mine_count]
    json.assigned_count @conversations_count[:assigned_count]
    json.unassigned_count @conversations_count[:unassigned_count]
    json.all_count @conversations_count[:all_count]
    json.order_statuses @order_statuses
  end
  json.payload do
    json.array! @conversations do |conversation|
      json.partial! 'api/v1/conversations/partials/conversation', formats: [:json], conversation: conversation
      json.tiene_pedido (conversation.cached_label_list_array - ConversationsWithOrdersFinder::NON_ORDER_LABELS).any?
    end
  end
end
