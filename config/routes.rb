ActionController::Routing::Routes.draw do |map|

  map.root :controller => "gems", :action => 'index'
  map.connect ':user/:project', :controller => "gems", :action => 'show'
  map.connect ':user/:project/check_gemspec', :controller => "gems", :action => 'check_gemspec'
  map.connect ':user/:project/status', :controller => "gems", :action => 'status'

end
