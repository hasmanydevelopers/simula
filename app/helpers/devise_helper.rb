module DeviseHelper

  def devise_error_messages!
    return "" if resource.nil?
    return "" if resource.errors.empty?

    html = <<-HTML
    <p class="alert alert-danger">
      #{resource.errors.full_messages.first}
    </p>
    HTML

    html.html_safe
  end

end

