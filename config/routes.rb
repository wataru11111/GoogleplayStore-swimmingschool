Rails.application.routes.draw do
  # OneSignal通知用APIエンドポイント
  post 'api/notify_update', to: 'notifications#update_notice'

  devise_for :customers, skip: [:passwords], controllers: {
    registrations: "public/registrations",
    sessions: 'public/sessions'
  }
  devise_for :admins, skip: [:registrations, :passwords], controllers: {
    sessions: "admin_area/sessions"
  }

  namespace :admin_area do
    get '/' => "homes#top"
    resources :calendar, only: [:new, :index, :edit, :create, :update]
    resources :customers do
      member do
        post :password_reset # パスワードリセットルートをPOSTに設定
        get :history         # 履歴ページをGETリクエストで設定
        patch :change_status
      end
      resources :transfers, only: [:new, :create]
      resources :children do
        resources :transfers, only: [:new, :create]
      end
    end
    resources :day_searches, only: [:index] do
      collection do
        post :broadcast_sms
      end
    end
    resources :offs, only: [:index, :new, :create] # お休み一覧ページのルート
    resources :transfers, only: [:new, :create]
    resources :child, only: [:edit, :update] # 管理者用の子供編集ページ
    resources :settings, only: [:index, :update]# スケジュール管理
  end

  scope module: :public do
    root to: 'homes#top'

    get 'dates/confirmation' => "date#confirmation"
    get 'dates/completion' => "date#completion"

    resources :date, only: [:show, :index, :new, :create]
    
    resources :offs do
      member do
        get :show_absences    # お休み確認ページ
        get :edit_absence     # お休み変更ページ
        patch :update_absence # お休み更新アクション
        delete :destroy       # 削除アクション
      end
    end

    get '/calender/index' => "calendar#index"

    resources :child, only: [:new, :edit, :update, :create, :destroy]

    # マイページのルートに名前付きルートを追加
    get '/customers/show' => "customers#show", as: 'customers_show'
    get '/customers/information/edit' => "customers#edit"
    patch '/customers/information' => "customers#update"
    get 'customers/unsubscribe' => "customers#unsubscribe"
    patch 'customers/withdrawal' => "customers#withdrawal"
    get '/about' => "homes#about"

    resources :items, only: [:index, :show]
  end
end
