module DeviseHelper

  def devise_error_messages!
    return "" if resource.nil? || resource.errors.empty?

    message =  content_tag(:p, resource.errors.full_messages.first, :class => "alert alert-danger")

    html = <<-HTML
    <div id="error_explanation">
      #{message}
    </div>
    HTML

    html.html_safe
  end

end

