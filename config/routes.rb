Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  post '/create', :to=> 'account#CreateUser', as: 'create'
  post '/login', :to=> 'account#LoginUser', as: 'LoginUser'
  post '/passwordreset', :to=> 'account#ResetPassword', as: 'passwordreset'
  post '/tweet', :to=> 'account#CreateTweet', as: 'tweet'
  
  get '/CreateFollow', :to=> 'account#CreateFollowing', as: 'CreateFollow' 
  get '/follows', :to=> 'account#Listfollowing', as: 'follows'
  get '/followers', :to=> 'account#Listfollowers', as: 'followers'
  get '/unfollow', :to=> 'account#unfollowing', as: 'unfollow'
  get '/usernameList', :to=> 'account#existingUserName', as: 'usernameList'
  get '/viewProfile', :to=> 'account#viewProfile', as: 'viewProfile'
  put '/updateProfile', :to=> 'account#updateProfile', as: 'updateProfile'
  get '/updatePassword', :to=> 'account#updatePassword', as: 'updatePassword'
  get '/removeFollow', :to=> 'account#unfollowing', as: 'removeFollow'
  get '/viewTweet', :to=> 'account#loadTweets', as: 'viewTweet'

  get '/allUsers', :to=> 'account#listAllUsers', as: 'allUsers'
  get '/likeTweet', :to=> 'account#AddLikesToTweet', as: 'likeTweet'
end
