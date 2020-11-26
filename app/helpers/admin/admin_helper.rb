module Admin::AdminHelper
  def admin_menu_links(links)
    links.map { |text, path| admin_menu_link(text, path) }.join.html_safe
  end

  def admin_menu_link(text, path)
    content_tag(
      :li,
      link_to(text, path, class: "nav-link"),
      current_page?(path) ? {class: "nav-item active"} : {class: "nav-item"}
    )
  end

  def page_header(title)
    content_tag(:div, content_tag(:h1, title), class: "page-header")
  end

  def breadcrumbs(crumbs, heading)
    content_tag(
      :nav,
      content_tag(
        :ol,
        crumbs.map { |k, v| content_tag(:li, link_to(k, v), class: "breadcrumb-item") }.join.html_safe +
        content_tag(:li, heading, class: "breadcrumb-item active"),
        class: "breadcrumb"
      ),
      "aria-label" => "breadcrumb"
    )
  end

  def editor(form, attribute, mode)
    textarea_id = "##{form.object_name}_#{attribute}"
    editor_id = "editor_#{attribute}"
    form_classes = ".new_#{form.object_name}, .edit_#{form.object_name}"
    form.text_area(attribute, class: "editor-textarea") +
      content_tag(
        "div", form.object.send(attribute), id: editor_id, class: "editor"
      ) + editor_javascript_tag(editor_id, form_classes, textarea_id, mode)
  end

  def editor_javascript_tag(editor_id, form_classes, textarea_id, mode)
    javascript_tag(
      "const #{editor_id} = ace.edit('#{editor_id}');
  #{editor_id}.getSession().setUseWorker(false);
  #{editor_id}.setTheme('ace/theme/github');
  #{editor_id}.setShowPrintMargin(false);
  #{editor_id}.getSession().setMode('ace/mode/#{mode}');
  #{editor_id}.getSession().setTabSize(2);
  #{editor_id}.getSession().setUseSoftTabs(true);
  #{editor_id}.getSession().setUseWrapMode(true);
  document.querySelector('#{form_classes}').addEventListener('submit', function() {
    const textarea = document.querySelector('#{textarea_id}');
    textarea.value = #{editor_id}.getSession().getValue();
  });
  "
    )
  end

  def dismissable_error_message(&block)
    render(
      partial: "admin/shared/dismissable_error_message",
      locals: {body: capture(&block)}
    )
  end

  protected

  def object_title(object)
    object.instance_of?(Array) ? object.last : object
  end
end
