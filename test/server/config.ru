run WrittenDevApplication::Application.initialize!

WrittenDevApplication::Application.routes.draw do
  mount Specter::Engine => '/specter'
  root 'posts#show'
end
