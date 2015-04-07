module MessageHelper

  def message_with_context(message, context = nil)
    if context.nil? || context.empty?
      message
    else
      message + " #{context}"
    end
  end

end