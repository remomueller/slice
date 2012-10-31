Slice::Application.routes.draw do

  get "reports/index"

  resources :designs do
    member do
      get :copy
      get :print
      post :reorder
      get :report
      post :report
      get :report_print
    end
    collection do
      post :add_variable
      post :add_section
      post :variables
      post :selection
    end
  end

  resources :projects do
    member do
      post :remove_file
      get :report
      post :report
    end

    collection do
      get :splash
    end

    resources :contacts
    resources :documents
    resources :posts

    resources :sheets do
      collection do
        post :project_selection
      end
      member do
        post :send_email
        get :print
        post :remove_file
        get :audits
      end
    end

    get "sheet_emails/show"

    resources :variables do
      member do
        get :copy
        get :format_number
        post :add_grid_row
        get :typeahead
      end
      collection do
        post :add_option
        post :add_grid_variable
        post :options
      end
    end

  end

  # get "sheet_emails/show"

  resources :project_users do
    collection do
      get :accept
    end
  end

  resources :reports

  # resources :sheets do
  #   collection do
  #     post :project_selection
  #   end
  #   member do
  #     post :send_email
  #     get :print
  #     post :remove_file
  #     get :audits
  #   end
  # end

  resources :sheet_emails

  resources :sites do
    collection do
      post :selection
    end
  end

  resources :site_users do
    collection do
      get :accept
    end
  end

  resources :subjects

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users

  match "/about" => "application#about", as: :about

  root to: 'projects#splash'

end
