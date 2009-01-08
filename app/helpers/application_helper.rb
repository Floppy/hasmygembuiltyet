module ApplicationHelper

  def periodically_call_remote(options = {})
    variable = options[:variable] ||= 'document.poller'
    frequency = options[:frequency] ||= 10
    "if(#{variable}) #{variable}.stop(); #{variable} = new PeriodicalExecuter(function() {#{remote_function(options)}}, #{frequency})"
  end

end
