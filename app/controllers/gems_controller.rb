require 'rubygems/specification'
require 'net/http'

class GemsController < ApplicationController
  before_filter :get_gem_details, :except => :index

  def index
    if request.post?
      extract_details_from_url
      redirect_to :action => 'show', :user => params[:gem][:user], :project => params[:gem][:project]
    end
  end

  def show
  end

  def check_gemspec
    # Get gemspec from github
    gemspec_path = "/#{@user}/#{@project}/tree/master/#{@project}.gemspec?raw=true"
    res = nil
    Net::HTTP.start('github.com') {|http|
      req = Net::HTTP::Get.new(gemspec_path)
      res = http.request(req)
    }
    if res.code == "200"
      @gemspec_file = res.body
      # Load gemspec
      @gemspec = nil
      Thread.new { @gemspec = eval("$SAFE = 3\n#{@gemspec_file}") }.join
      # Store spec in session
      session[:gemspec] ||= {}
      session[:gemspec]["#{@user}/#{@project}"] = @gemspec
    end
  rescue SyntaxError
    @syntax_error = true
  rescue
    nil
  ensure
    # Respond
    respond_to do |format|
      format.js
    end
  end
  
  def check_gem_in_remote_specfile
    @gemspec = session[:gemspec]["#{@user}/#{@project}"]
  end

  def status
    # Get spec from session
    @gemspec = session[:gemspec]["#{@user}/#{@project}"]
    # Work out gem URL
    @gem_url = "http://gems.github.com#{gem_path}"
    
    @built = gem_is_built?
    
    @in_spec_file = @built && gem_is_in_specfile?
    
    # Respond
    respond_to do |format|
      format.js
    end
  end

  protected

  def get_gem_details
    @user = params[:user]
    @project = params[:project]
  end
  
  def gem_name
    "#{@user}-#{@gemspec.name}"
  end
  
  def gem_path
    "/gems/#{gem_name}-#{@gemspec.version}.gem"
  end
  
  def extract_details_from_url
    if params[:gem][:url].to_s.match(%r{github\.com/([^/]+)/([^/]+)})
      params[:gem][:user] = $1
      params[:gem][:project] = $2
    end
  end

  def gem_is_built?
    session[:gemspec_status] ||= {}
    session[:gemspec_status]["#{@user}/#{@project}/#{@gemspec.version}"] ||= gem_available_on_server?
  end
  
  def gem_available_on_server?
    Net::HTTP.start('gems.github.com') {|http|
      req = Net::HTTP::Head.new(gem_path)
      response = http.request(req)
      return response.code == "200"
    }
  end
  
  def gem_is_in_specfile?
    fetcher = Gem::SpecFetcher.new
    specs = fetcher.load_specs(URI.parse('http://gems.github.com/'), 'specs')
    specs.any?{|(name, spec)| name == gem_name and spec.version.to_s == @gemspec.version.to_s }
  end
end
