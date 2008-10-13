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

  def status
    # Get spec from session
    @gemspec = session[:gemspec]["#{@user}/#{@project}"]
    # Work out gem URL
    @gem_path = "/gems/#{@user}-#{@gemspec.name}-#{@gemspec.version}.gem"
    @gem_url = "http://gems.github.com#{@gem_path}"
    # See if target of URL exists
    Net::HTTP.start('gems.github.com') {|http|
      req = Net::HTTP::Head.new(@gem_path)
      response = http.request(req)
      @built = (response.code == "200")
    }
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
  
  def extract_details_from_url
    if params[:gem][:url].to_s.match(%r{github\.com/([^/]+)/([^/]+)})
      params[:gem][:user] = $1
      params[:gem][:project] = $2
    end
  end

end
