class StaticPagesController < ApplicationController

	def welcome
		@title = 'Добро пожаловать!'
	end

	def about_us
		@title = 'We test amazon deployment services'
	end

end
