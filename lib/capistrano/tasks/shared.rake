namespace :shared do

  task :setup do
    on roles(:app) do
      within shared_path do
        execute :mkdir, '-p', 'public/assets', 'tmp/cache'
      end
    end
  end

  task :setup_release do
    on roles(:app) do
      within release_path do
        execute :mkdir, '-p', 'public/assets', 'tmp/cache'
      end
    end
  end

  task :copy_assets do
    on roles(:app) do
      within release_path do
        execute :rsync, '--progress', "#{shared_path}/public/assets/", "#{release_path}/public/assets/"
        execute :rsync, "#{shared_path}/tmp/cache/", "#{release_path}/tmp/cache/"
      end
    end
  end

  task :update_assets do
    on roles(:app) do
      within release_path do
        execute :rsync, '--progress', "#{release_path}/public/assets/", "#{shared_path}/public/assets/"
        execute :rsync, "#{release_path}/tmp/cache/", "#{shared_path}/tmp/cache/"
      end
    end
  end
end
