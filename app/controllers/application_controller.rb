class ApplicationController < ActionController::Base

	before_action :nav_menu

	def nav_menu
		@pages = Page.all
	end

end
