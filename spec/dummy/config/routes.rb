Dummy::Application.routes.draw do

  scope "v1" do
    resources :the_models, except: [:new, :edit] do
      member do
        put 'connect'
      end
    end
  end

end
