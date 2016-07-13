Rails.application.routes.draw do

  devise_for :users
  root 'rooms#index'

  get 'lti/config', to: 'lti#configuration', defaults: { format: 'xml' }
  post 'lti/launch', to: 'lti#launch'

  get 'oauth2/callback', to: 'oauth2#callback'

  get 'rooms/not_found', to: 'rooms#not_found', as: :room_not_found
  get 'rooms/:id/import/participants', to: 'rooms#import_participants', as: :room_import_participants
  get 'rooms/:room_id/participants/:id/grades/passback', to: 'participants#passback_grade', as: :passback_grade
  resources :rooms, except: [:new, :create, :edit, :destroy] do
    resources :participants, only: [:index]
    get 'submissions/who', to: 'submissions#who_submitted', as: :who_submitted
    get 'submissions/export', to: 'submissions#export'
    get 'submissions/beyond/:beyond_id', to: 'submissions#newest_submissions'
    resources :submissions
  end

  get 'rooms/:room_id/main', to: 'main_view#index', as: :view_submissions

  get 'status', to: 'status#status'

end
