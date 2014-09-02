module RemedyView
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom,
      :partial => 'issues/remedy_ticket_form'

    render_on :view_issues_show_description_bottom,
      :partial => 'issues/remedy_tickets'
  end
end
