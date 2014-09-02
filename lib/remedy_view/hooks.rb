module RemedyView
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom,
      :partial => 'remedy_view/issue_remedy_ticket'
  end
end
