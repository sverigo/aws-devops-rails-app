Rails.application.routes.draw do
  
	root 'static_pages#welcome'

	get 'about_us', to: 'static_pages#about_us'

	resources :pages
end
