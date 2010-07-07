class CommentsController < ApplicationController
  unloadable
  before_filter :find_issue, :only => [:index, :create ]
  before_filter :find_project, :authorize
  
  log_activity_streams :current_user, :name, :updated, :@issue, :subject, :create, :issues, {:indirect_object => :@journal,
            :indirect_object_name_method => :notes,
            :indirect_object_phrase => ' ' }
  
    
  def index
    @journals = @issue.journals.find(:all, 
                                          :include => [:user, :details], 
                                          :order => "#{Journal.table_name}.created_on DESC",
                                          :conditions => "notes!=''")
    # render :partial => "comment", :collection => @journals, :as => :journal
  end
  
  def j
    @issue.journals.first
  end
  
  def create
    @journal = @issue.init_journal(User.current, params[:comment])
    @journal.save!
    @journal.reload
    @issue.reload
    render :json => @issue.to_dashboard
  end
  
  private
    
  def find_issue
    @issue = Issue.find(params[:issue_id])
  end  
  
  def find_project
    @project = @issue.project
  end
end
