# Minimal release directories
# Inspired by https://github.com/capistrano/capistrano/blob/v3.4.0/lib/capistrano/tasks/deploy.rake
namespace :deploy do

  task :starting do
    invoke 'deploy:check'
  end

  task :updating => :new_release_path do
    invoke "deploy:create_release"
  end

  task :reverting do
    invoke 'deploy:revert_release'
  end

  task :publishing do
    invoke 'deploy:symlink:release'
  end

  task :finishing do
    invoke 'deploy:cleanup'
  end

  task :finishing_rollback do
    invoke 'deploy:cleanup_rollback'
  end

  desc 'Check required files and directories exist'
  task :check do
    invoke 'deploy:check:directories'
  end

  namespace :check do
    desc 'Check shared and release directories exist'
    task :directories do
      on release_roles :all do
        execute :mkdir, '-p', shared_path, releases_path
      end
    end
  end

  namespace :symlink do
    desc 'Symlink release to current'
    task :release do
      on release_roles :all do
        tmp_current_path = release_path.parent.join(current_path.basename)
        execute :ln, '-s', release_path, tmp_current_path
        execute :mv, tmp_current_path, current_path.parent
      end
    end
  end

  desc 'Clean up old releases'
  task :cleanup do
    on release_roles :all do |host|
      releases = capture(:ls, '-xtr', releases_path).split
      if releases.count >= fetch(:keep_releases)
        info t(:keeping_releases, host: host.to_s, keep_releases: fetch(:keep_releases), releases: releases.count)
        directories = (releases - releases.last(fetch(:keep_releases)))
        if directories.any?
          directories_str = directories.map do |release|
            releases_path.join(release)
          end.join(" ")
          execute :rm, '-rf', directories_str
        else
          info t(:no_old_releases, host: host.to_s, keep_releases: fetch(:keep_releases))
        end
      end
    end
  end

  desc 'Remove and archive rolled-back release.'
  task :cleanup_rollback do
    on release_roles(:all) do
      last_release = capture(:ls, '-xt', releases_path).split.first
      last_release_path = releases_path.join(last_release)
      if test "[ `readlink #{current_path}` != #{last_release_path} ]"
        execute :tar, '-czf',
          deploy_path.join("rolled-back-release-#{last_release}.tar.gz"),
        last_release_path
        execute :rm, '-rf', last_release_path
      else
        debug 'Last release is the current release, skip cleanup_rollback.'
      end
    end
  end

  task :create_release do
    on release_roles(:all) do
      execute :mkdir, '-p', release_path
    end
  end

  desc 'Revert to previous release timestamp'
  task :revert_release => :rollback_release_path

  task :new_release_path do
    set_release_path
  end

  task :rollback_release_path do
    on release_roles(:all) do
      releases = capture(:ls, '-xt', releases_path).split
      if releases.count < 2
        error t(:cannot_rollback)
        exit 1
      end
      last_release = releases[1]
      set_release_path(last_release)
      set(:rollback_timestamp, last_release)
    end
  end

  task :restart
  task :failed

end
