json.extract! message, :id, :category, :text, :from_at, :to_at, :created_at, :updated_at
json.url message_url(message, format: :json)
