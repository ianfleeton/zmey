# frozen_string_literal: true

module Admin
  # Provides button, link and icon helpers for the admin area.
  module ButtonsHelper
    def admin_submit_button(form)
      form.submit(
        t("helpers.admin.admin.admin_submit_button.save"),
        class: "btn btn-primary"
      )
    end

    def new_button(type, params = {})
      link_to(
        "#{icon_add} New".html_safe,
        new_polymorphic_path(type, params),
        class: "btn btn-outline-secondary",
        title: "New #{object_title(type)}"
      )
    end

    # Renders a button to view an object. If <tt>link</tt> is supplied then this
    # is used for the hyperlink, otherwise the link is determined from the
    # object.
    def view_button(object, link = nil)
      link_to(
        '<i class="far fa-eye"></i> View'.html_safe,
        link || polymorphic_path(object),
        class: "btn btn-outline-secondary",
        title: "View #{object_title(object)}"
      )
    end

    def edit_button(object)
      link_to(
        icon_edit,
        edit_polymorphic_path(object),
        class: "btn btn-outline-secondary",
        title: "Edit #{object_title(object)}"
      )
    end

    def delete_button(object)
      link_to(
        icon_delete,
        object,
        data: {confirm: "Are you sure?"},
        method: :delete,
        class: "btn btn-danger",
        title: "Delete #{object_title(object)}"
      )
    end

    # Provides a button to move the object up if it is not
    # already first in the list, or an empty string if it is.
    def move_up_button(path_helper, object)
      if object.first?
        "".html_safe
      else
        link_to(
          icon_up,
          send(path_helper, object),
          title: "Move Up",
          class: "btn btn-outline-secondary",
          method: "post"
        ).html_safe
      end
    end

    # Provides a button to move the object down if it is not
    # already last in the list, or an empty string if it is.
    def move_down_button(path_helper, object)
      if object.last?
        "".html_safe
      else
        link_to(
          icon_down,
          send(path_helper, object),
          title: "Move Down",
          class: "btn btn-outline-secondary",
          method: "post"
        ).html_safe
      end
    end

    def search_button
      button_tag(
        icon_search + " " + t(".search"),
        class: "btn btn-outline-secondary",
        data: {
          toggle: "modal",
          target: "#search-modal"
        }
      )
    end

    def icon_add
      '<i class="far fa-plus-circle"></i>'.html_safe
    end

    def icon_bottom
      '<i class="far fa-arrow-to-bottom"></i>'.html_safe
    end

    def icon_cloud_download
      '<i class="far fa-cloud-download"></i>'.html_safe
    end

    def icon_delete
      '<i class="far fa-trash-alt"></i>'.html_safe
    end

    def icon_down
      '<i class="far fa-arrow-down"></i>'.html_safe
    end

    def icon_download
      '<i class="far fa-download"></i>'.html_safe
    end

    def icon_edit
      '<i class="far fa-edit"></i>'.html_safe
    end

    def icon_file
      '<i class="far fa-file"></i>'.html_safe
    end

    def icon_print
      '<i class="far fa-print"></i>'.html_safe
    end

    def icon_remove
      '<i class="far fa-minus-circle"></i>'.html_safe
    end

    def icon_search
      '<i class="far fa-search"></i>'.html_safe
    end

    def icon_tags
      '<i class="far fa-tags"></i>'.html_safe
    end

    def icon_top
      '<i class="far fa-arrow-to-top"></i>'.html_safe
    end

    def icon_up
      '<i class="far fa-arrow-up"></i>'.html_safe
    end
  end
end
